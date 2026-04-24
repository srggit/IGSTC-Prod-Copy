public class SharePointService {

    // ══════════════════════════════════════════════════════════
    // CUSTOM EXCEPTION
    // ══════════════════════════════════════════════════════════
    public class SharePointException extends Exception {}

    // ══════════════════════════════════════════════════════════
    // WRAPPER CLASSES
    // ══════════════════════════════════════════════════════════

    // Folder response wrapper
    public class FolderResult {
        public String  id;
        public String  name;
        public String  webUrl;
        public String  parentId;
        public Boolean isNew;
    }

    // File response wrapper
    public class FileResult {
        public String id;
        public String name;
        public String webUrl;
        public Long   size;
        public String mimeType;
    }

    // List item wrapper
    public class ListItem {
        public String              id;
        public String              webUrl;
        public Map<String, Object> fields;
    }

    // List fetch result wrapper
    public class ListResult {
        public List<ListItem> items;
        public Integer        totalCount;
        public String         nextLink;
    }

    // ══════════════════════════════════════════════════════════
    // LOAD CONFIG FROM CUSTOM METADATA
    // ══════════════════════════════════════════════════════════
    private static SharePoint_Config__mdt CONFIG {
        get {
            if (CONFIG == null) {
                CONFIG = [
                    SELECT Site_Id__c, Drive_Id__c, Site_Hostname__c,
                           Site_Name__c, List_Id__c
                    FROM   SharePoint_Config__mdt
                    WHERE  DeveloperName = 'igstc'
                    LIMIT  1
                ];
            }
            return CONFIG;
        }
        set;
    }

    // ══════════════════════════════════════════════════════════
    // CORE HTTP HELPER — all callouts go through here
    // ══════════════════════════════════════════════════════════
    private static HttpResponse callGraph(
        String method,
        String path,
        String body,
        String contentType
    ) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SharePoint_Graph_API' + path);
        req.setMethod(method);
        req.setHeader('Content-Type', String.isBlank(contentType)
            ? 'application/json'
            : contentType);
        req.setTimeout(30000);

        if (String.isNotBlank(body)) {
            req.setBody(body);
        }

        HttpResponse res = new Http().send(req);
        System.debug('Graph API [' + method + '] ' + path
            + ' → ' + res.getStatusCode());

        return res;
    }

    // ══════════════════════════════════════════════════════════
    // ░░░░░░░░░░░░░░  1. CREATE FOLDER  ░░░░░░░░░░░░░░░░░░░░░
    // ══════════════════════════════════════════════════════════

    /**
     * Creates a folder at Drive root or inside a parent folder.
     *
     * @param folderName     Name of the folder to create
     * @param parentFolderId Parent folder ID (null = Drive root)
     * @return               FolderResult with id, name, webUrl
     *
     * Usage:
     *   // Root level
     *   FolderResult root = SharePointService.createFolder('PRPSL-001', null);
     *
     *   // Sub-folder
     *   FolderResult sub = SharePointService.createFolder('Aadhar Copy', root.id);
     */
    public static FolderResult createFolder(String folderName, String parentFolderId) {
        if (String.isBlank(folderName)) {
            throw new SharePointException('Folder name cannot be blank.');
        }

        String driveId = CONFIG.Drive_Id__c;

        String path = String.isBlank(parentFolderId)
            ? '/v1.0/drives/' + driveId + '/root/children'
            : '/v1.0/drives/' + driveId + '/items/' + parentFolderId + '/children';

        String body = JSON.serialize(new Map<String, Object>{
            'name'                              => folderName,
            'folder'                            => new Map<String, Object>(),
            '@microsoft.graph.conflictBehavior' => 'rename'
        });

        HttpResponse res = callGraph('POST', path, body, 'application/json');

        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            Map<String, Object> parsed =
                (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

            FolderResult result  = new FolderResult();
            result.id            = (String)  parsed.get('id');
            result.name          = (String)  parsed.get('name');
            result.webUrl        = (String)  parsed.get('webUrl');
            result.isNew         = res.getStatusCode() == 201;

            Map<String, Object> parentRef =
                (Map<String, Object>) parsed.get('parentReference');
            if (parentRef != null) {
                result.parentId = (String) parentRef.get('id');
            }

            System.debug('Folder created → ' + result.name + ' | ID: ' + result.id);
            return result;
        }

        throw new SharePointException(
            'createFolder failed [' + folderName + ']: '
            + res.getStatusCode() + ' ' + res.getBody()
        );
    }

    /**
     * Resolves a folder by drive-relative path (e.g. Proposals/Two_Plus_Two/IGSTC-07991).
     */
    public static FolderResult getFolderByPath(String folderPath) {
        String normalizedPath = normalizeDriveRelativePath(folderPath);
        String driveId = CONFIG.Drive_Id__c;
        String path = '/v1.0/drives/' + driveId + '/root:/' + encodePathForGraph(normalizedPath);

        HttpResponse res = callGraph('GET', path, null, 'application/json');
        if (res.getStatusCode() == 200) {
            Map<String, Object> parsed =
                (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            FolderResult result  = new FolderResult();
            result.id            = (String) parsed.get('id');
            result.name          = (String) parsed.get('name');
            result.webUrl        = (String) parsed.get('webUrl');
            result.isNew         = false;
            Map<String, Object> parentRef =
                (Map<String, Object>) parsed.get('parentReference');
            if (parentRef != null) {
                result.parentId = (String) parentRef.get('id');
            }
            return result;
        }

        throw new SharePointException(
            'getFolderByPath failed [' + normalizedPath + ']: '
            + res.getStatusCode() + ' ' + res.getBody()
        );
    }

    /**
     * Lists immediate files/folders under a drive-relative path.
     * Returns a map with keys: files, folders (legacy-friendly shape).
     */
    public static Map<String, List<Object>> getFolderContentByPath(String folderPath) {
        String normalizedPath = normalizeDriveRelativePath(folderPath);
        String driveId = CONFIG.Drive_Id__c;
        String path = '/v1.0/drives/' + driveId + '/root:/'
            + encodePathForGraph(normalizedPath) + ':/children';

        HttpResponse res = callGraph('GET', path, null, 'application/json');
        if (res.getStatusCode() != 200) {
            throw new SharePointException(
                'getFolderContentByPath failed [' + normalizedPath + ']: '
                + res.getStatusCode() + ' ' + res.getBody()
            );
        }

        Map<String, Object> parsed =
            (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        List<Object> rawItems = (List<Object>) parsed.get('value');

        List<Object> files = new List<Object>();
        List<Object> folders = new List<Object>();
        if (rawItems != null) {
            for (Object rawObj : rawItems) {
                Map<String, Object> raw = (Map<String, Object>) rawObj;
                String name = (String) raw.get('name');
                String itemPath = normalizedPath + '/' + name;

                Map<String, Object> item = new Map<String, Object>{
                    'Name'              => name,
                    'UniqueId'          => (String) raw.get('id'),
                    'linkedUrl'         => (String) raw.get('webUrl'),
                    'ServerRelativeUrl' => itemPath
                };

                if (raw.containsKey('folder')) {
                    folders.add(item);
                } else {
                    files.add(item);
                }
            }
        }

        return new Map<String, List<Object>>{
            'files'   => files,
            'folders' => folders
        };
    }

    /**
     * Creates a folder at a full drive-relative path.
     */
    public static FolderResult createFolderByPath(String fullFolderPath) {
        String normalizedPath = normalizeDriveRelativePath(fullFolderPath);
        Integer splitAt = normalizedPath.lastIndexOf('/');
        String folderName = splitAt > -1 ? normalizedPath.substring(splitAt + 1) : normalizedPath;
        String parentPath = splitAt > -1 ? normalizedPath.substring(0, splitAt) : null;

        String parentId = null;
        if (!String.isBlank(parentPath)) {
            parentId = getFolderByPath(parentPath).id;
        }

        return createFolder(folderName, parentId);
    }

    /**
     * Uploads a blob file into a folder resolved by drive-relative path.
     */
    public static FileResult uploadBlobFileByPath(
        String folderPath,
        String fileName,
        Blob fileBlob,
        String contentType
    ) {
        FolderResult folder = getFolderByPath(folderPath);
        return uploadBlobFile(folder.id, fileName, fileBlob, contentType);
    }

    /**
     * Creates an anonymous "anyone with link" URL for a file/folder.
     * Returns null if the tenant policy blocks anonymous links.
     */
    public static String createAnonymousViewLink(String itemId) {
        if (String.isBlank(itemId)) {
            throw new SharePointException('itemId is required.');
        }

        String driveId = CONFIG.Drive_Id__c;
        String path = '/v1.0/drives/' + driveId + '/items/' + itemId + '/createLink';
        String body = JSON.serialize(new Map<String, Object>{
            'type' => 'view',
            'scope' => 'anonymous'
        });

        HttpResponse res = callGraph('POST', path, body, 'application/json');
        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            Map<String, Object> parsed =
                (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            Map<String, Object> linkObj =
                (Map<String, Object>) parsed.get('link');
            return linkObj == null ? null : (String) linkObj.get('webUrl');
        }

        // Common when tenant policy disallows anonymous links.
        if (res.getStatusCode() == 400 || res.getStatusCode() == 403) {
            System.debug('Anonymous link blocked by policy: ' + res.getBody());
            return null;
        }

        throw new SharePointException(
            'createAnonymousViewLink failed [' + itemId + ']: '
            + res.getStatusCode() + ' ' + res.getBody()
        );
    }

    /**
     * Deletes a file/folder by full drive-relative path.
     */
    public static void deleteItemByPath(String itemPath) {
        String normalizedPath = normalizeDriveRelativePath(itemPath);
        String driveId = CONFIG.Drive_Id__c;
        String path = '/v1.0/drives/' + driveId + '/root:/'
            + encodePathForGraph(normalizedPath);

        HttpResponse res = callGraph('DELETE', path, null, 'application/json');
        if (res.getStatusCode() != 204) {
            throw new SharePointException(
                'deleteItemByPath failed [' + normalizedPath + ']: '
                + res.getStatusCode() + ' ' + res.getBody()
            );
        }
    }

    /**
     * Creates full nested folder structure for a Proposal.
     * PRPSL-001
     *    └── Aadhar Copy
     *    └── PAN Card
     *    └── Bank Statement
     *
     * @param proposalNumber   e.g. PRPSL-001
     * @param categoryNames    List of sub-folder names
     * @return                 Map of categoryName → FolderResult
     */
    public static Map<String, FolderResult> createProposalFolderStructure(
        String       proposalNumber,
        List<String> categoryNames
    ) {
        Map<String, FolderResult> resultMap = new Map<String, FolderResult>();

        // 1. Create root proposal folder
        FolderResult rootFolder = createFolder(proposalNumber, null);
        resultMap.put(proposalNumber, rootFolder);
        System.debug('Root folder: ' + proposalNumber + ' → ' + rootFolder.id);

        // 2. Create each category sub-folder
        Set<String> created = new Set<String>();
        for (String category : categoryNames) {
            if (String.isBlank(category) || created.contains(category)) continue;

            FolderResult subFolder = createFolder(category, rootFolder.id);
            resultMap.put(category, subFolder);
            created.add(category);
            System.debug('Sub-folder: ' + category + ' → ' + subFolder.id);
        }

        return resultMap;
    }

    // ══════════════════════════════════════════════════════════
    // ░░░░░░░░░░░░░░  2. UPLOAD FILE  ░░░░░░░░░░░░░░░░░░░░░░░
    // ══════════════════════════════════════════════════════════

    /**
     * Uploads a small file (< 4MB) into a specific folder.
     *
     * @param folderId     Target folder ID
     * @param fileName     File name with extension e.g. document.pdf
     * @param fileBody     File content as String (JSON, CSV, plain text)
     * @param contentType  MIME type e.g. application/json, text/csv
     * @return             FileResult with id, name, webUrl
     *
     * Usage:
     *   FileResult f = SharePointService.uploadFile(
     *       folderId, 'data.json',
     *       JSON.serialize(myData), 'application/json'
     *   );
     */
    public static FileResult uploadFile(
        String folderId,
        String fileName,
        String fileBody,
        String contentType
    ) {
        if (String.isBlank(folderId))   throw new SharePointException('folderId is required.');
        if (String.isBlank(fileName))   throw new SharePointException('fileName is required.');
        if (String.isBlank(fileBody))   throw new SharePointException('fileBody is required.');

        String driveId = CONFIG.Drive_Id__c;
        String path    = '/v1.0/drives/' + driveId
                       + '/items/' + folderId
                       + ':/' + fileName + ':/content';

        HttpResponse res = callGraph('PUT', path, fileBody,
            String.isBlank(contentType) ? 'application/octet-stream' : contentType);

        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            Map<String, Object> parsed =
                (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

            FileResult result  = new FileResult();
            result.id          = (String) parsed.get('id');
            result.name        = (String) parsed.get('name');
            result.webUrl      = (String) parsed.get('webUrl');
            result.size        = (Long)   parsed.get('size');

            Map<String, Object> fileObj =
                (Map<String, Object>) parsed.get('file');
            if (fileObj != null) {
                result.mimeType = (String) fileObj.get('mimeType');
            }

            System.debug('File uploaded → ' + result.name
                + ' | URL: ' + result.webUrl);
            return result;
        }

        throw new SharePointException(
            'uploadFile failed [' + fileName + ']: '
            + res.getStatusCode() + ' ' + res.getBody()
        );
    }

    /**
     * Uploads a Blob/Attachment (binary) file using Base64 encoding.
     *
     * @param folderId   Target folder ID
     * @param fileName   File name with extension
     * @param fileBlob   Blob content (from Attachment, ContentVersion etc.)
     * @param contentType MIME type
     * @return           FileResult
     *
     * Usage:
     *   ContentVersion cv = [SELECT VersionData, Title, FileExtension
     *                        FROM ContentVersion WHERE Id = :cvId];
     *   FileResult f = SharePointService.uploadBlobFile(
     *       folderId,
     *       cv.Title + '.' + cv.FileExtension,
     *       cv.VersionData,
     *       'application/pdf'
     *   );
     */
    public static FileResult uploadBlobFile(
        String folderId,
        String fileName,
        Blob   fileBlob,
        String contentType
    ) {
        if (String.isBlank(folderId)) throw new SharePointException('folderId is required.');
        if (String.isBlank(fileName)) throw new SharePointException('fileName is required.');
        if (fileBlob == null)         throw new SharePointException('fileBlob is required.');

        String driveId = CONFIG.Drive_Id__c;
        String path    = '/v1.0/drives/' + driveId
                       + '/items/' + folderId
                       + ':/' + fileName + ':/content';

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SharePoint_Graph_API' + path);
        req.setMethod('PUT');
        req.setHeader('Content-Type',
            String.isBlank(contentType) ? 'application/octet-stream' : contentType);
        req.setBodyAsBlob(fileBlob);
        req.setTimeout(30000);

        HttpResponse res = new Http().send(req);

        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            Map<String, Object> parsed =
                (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

            FileResult result = new FileResult();
            result.id         = (String) parsed.get('id');
            result.name       = (String) parsed.get('name');
            result.webUrl     = (String) parsed.get('webUrl');
            result.size       = (Long)   parsed.get('size');

            System.debug('Blob uploaded → ' + result.name);
            return result;
        }

        throw new SharePointException(
            'uploadBlobFile failed [' + fileName + ']: '
            + res.getStatusCode() + ' ' + res.getBody()
        );
    }

    /**
     * Uploads Salesforce ContentVersion file into a SharePoint folder.
     * Convenience wrapper around uploadBlobFile.
     *
     * @param contentVersionId   Salesforce ContentVersion record Id
     * @param folderId           Target SharePoint folder ID
     * @return                   FileResult
     *
     * Usage:
     *   FileResult f = SharePointService.uploadContentVersion(cvId, folderId);
     */
    public static FileResult uploadContentVersion(Id contentVersionId, String folderId) {
        ContentVersion cv = [
            SELECT Id, Title, FileExtension, VersionData, FileType
            FROM   ContentVersion
            WHERE  Id = :contentVersionId
            LIMIT  1
        ];

        String fileName    = cv.Title + '.' + cv.FileExtension;
        String contentType = resolveMimeType(cv.FileExtension);

        return uploadBlobFile(folderId, fileName, cv.VersionData, contentType);
    }

    // ══════════════════════════════════════════════════════════
    // ░░░░░░░░░░░░░░  3. FETCH LIST  ░░░░░░░░░░░░░░░░░░░░░░░░
    // ══════════════════════════════════════════════════════════

    /**
     * Fetches all items from a SharePoint List.
     *
     * @param listId   SharePoint List ID (uses CONFIG.List_Id__c if blank)
     * @return         ListResult with items and totalCount
     *
     * Usage:
     *   ListResult result = SharePointService.fetchListItems(null);
     *   for (ListItem item : result.items) {
     *       System.debug(item.fields.get('Title'));
     *   }
     */
    public static ListResult fetchListItems(String listId) {
        String siteId  = CONFIG.Site_Id__c;
        String useList = String.isBlank(listId) ? CONFIG.List_Id__c : listId;

        String path = '/v1.0/sites/' + siteId
                    + '/lists/' + useList
                    + '/items?expand=fields&$top=100';

        HttpResponse res = callGraph('GET', path, null, 'application/json');

        if (res.getStatusCode() == 200) {
            return parseListResponse(res.getBody());
        }

        throw new SharePointException(
            'fetchListItems failed: '
            + res.getStatusCode() + ' ' + res.getBody()
        );
    }

    /**
     * Fetches list items with OData filter.
     *
     * @param listId     SharePoint List ID
     * @param filterExpr OData filter string
     * @return           ListResult
     *
     * Usage:
     *   // Fetch items where Title equals PRPSL-001
     *   ListResult r = SharePointService.fetchListItemsFiltered(
     *       null, "fields/Title eq 'PRPSL-001'"
     *   );
     */
    public static ListResult fetchListItemsFiltered(String listId, String filterExpr) {
        String siteId  = CONFIG.Site_Id__c;
        String useList = String.isBlank(listId) ? CONFIG.List_Id__c : listId;

        String encodedFilter = EncodingUtil.urlEncode(filterExpr, 'UTF-8');
        String path = '/v1.0/sites/' + siteId
                    + '/lists/' + useList
                    + '/items?expand=fields&$filter='
                    + encodedFilter + '&$top=100';

        HttpResponse res = callGraph('GET', path, null, 'application/json');

        if (res.getStatusCode() == 200) {
            return parseListResponse(res.getBody());
        }

        throw new SharePointException(
            'fetchListItemsFiltered failed: '
            + res.getStatusCode() + ' ' + res.getBody()
        );
    }

    /**
     * Fetches list items for a specific Proposal.
     *
     * @param proposalNumber  e.g. PRPSL-001
     * @return                ListResult
     *
     * Usage:
     *   ListResult r = SharePointService.fetchListByProposal('PRPSL-001');
     */
    public static ListResult fetchListByProposal(String proposalNumber) {
        return fetchListItemsFiltered(null, 'fields/Title eq \'' + proposalNumber + '\'');
    }

    /**
     * Adds a new item to a SharePoint List.
     *
     * @param listId   SharePoint List ID (uses CONFIG if blank)
     * @param fields   Map of column name → value
     * @return         Created ListItem
     *
     * Usage:
     *   ListItem item = SharePointService.addListItem(null, new Map<String,Object>{
     *       'Title'        => 'PRPSL-001',
     *       'Email'        => 'john@example.com',
     *       'SalesforceId' => '0065g000001XyZA'
     *   });
     */
    public static ListItem addListItem(String listId, Map<String, Object> fields) {
        String siteId  = CONFIG.Site_Id__c;
        String useList = String.isBlank(listId) ? CONFIG.List_Id__c : listId;

        String path = '/v1.0/sites/' + siteId
                    + '/lists/' + useList + '/items';

        String body = JSON.serialize(new Map<String, Object>{
            'fields' => fields
        });

        HttpResponse res = callGraph('POST', path, body, 'application/json');

        if (res.getStatusCode() == 201) {
            return parseListItem(
                (Map<String, Object>) JSON.deserializeUntyped(res.getBody())
            );
        }

        throw new SharePointException(
            'addListItem failed: '
            + res.getStatusCode() + ' ' + res.getBody()
        );
    }

    /**
     * Updates an existing SharePoint List item.
     *
     * @param listId     SharePoint List ID
     * @param itemId     Item ID to update
     * @param fields     Fields to update
     *
     * Usage:
     *   SharePointService.updateListItem(null, '3', new Map<String,Object>{
     *       'Status' => 'Approved'
     *   });
     */
    public static void updateListItem(
        String listId,
        String itemId,
        Map<String, Object> fields
    ) {
        String siteId  = CONFIG.Site_Id__c;
        String useList = String.isBlank(listId) ? CONFIG.List_Id__c : listId;

        String path = '/v1.0/sites/' + siteId
                    + '/lists/' + useList
                    + '/items/' + itemId + '/fields';

        HttpResponse res = callGraph('PATCH', path,
            JSON.serialize(fields), 'application/json');

        if (res.getStatusCode() != 200) {
            throw new SharePointException(
                'updateListItem failed [' + itemId + ']: '
                + res.getStatusCode() + ' ' + res.getBody()
            );
        }

        System.debug('List item updated → ' + itemId);
    }

    // ══════════════════════════════════════════════════════════
    // ░░░░░░░░░  4. FUTURE METHOD WRAPPERS (for Triggers) ░░░░
    // ══════════════════════════════════════════════════════════

    /**
     * @future wrapper — create folders + upload summary + sync list
     * Call this from trigger since triggers cannot do direct callouts.
     */
    @future(callout=true)
    public static void processProposalAsync(Id proposalId) {
        try {
            // 1. Query Application Proposal
            Application_Proposal__c proposal = [
                SELECT Id, Name, Record_Type_Name__c, Stage__c
                FROM   Application_Proposal__c
                WHERE  Id = :proposalId
                LIMIT  1
            ];

            String proposalFolderName = String.isNotBlank(proposal.Name)
                ? proposal.Name
                : String.valueOf(proposal.Id);

            // 2. Query Document Categories dynamically
            // (field API names can vary across orgs)
            Schema.DescribeSObjectResult docDescribe =
                Proposal_Document__c.SObjectType.getDescribe();
            Map<String, Schema.SObjectField> docFieldMap = docDescribe.fields.getMap();

            String categoryField;
            if (docFieldMap.containsKey('Category_Name__c')) {
                categoryField = 'Category_Name__c';
            } else if (docFieldMap.containsKey('Name')) {
                categoryField = 'Name';
            } else {
                throw new SharePointException(
                    'No category field found on Proposal_Document__c.'
                );
            }

            String relationField;
            if (docFieldMap.containsKey('Proposals__c')) {
                relationField = 'Proposals__c';
            } else if (docFieldMap.containsKey('Proposal__c')) {
                relationField = 'Proposal__c';
            } else {
                throw new SharePointException(
                    'No proposal relation field found on Proposal_Document__c.'
                );
            }

            String docSoql = 'SELECT Id, ' + categoryField
                + ' FROM Proposal_Document__c'
                + ' WHERE ' + relationField + ' = :proposalId'
                + ' ORDER BY ' + categoryField;
            List<SObject> docs = Database.query(docSoql);

            List<String> categories = new List<String>();
            for (SObject d : docs) {
                String categoryValue = (String) d.get(categoryField);
                if (String.isNotBlank(categoryValue)) {
                    categories.add(categoryValue);
                }
            }

            // ── STEP A: Create Folder Structure ──
            Map<String, FolderResult> folders =
                createProposalFolderStructure(proposalFolderName, categories);

            FolderResult rootFolder = folders.get(proposalFolderName);

            // ── STEP B: Upload JSON Summary File ──
            Map<String, Object> summary = new Map<String, Object>{
                'proposalName'   => proposal.Name,
                'salesforceId'   => proposal.Id,
                'recordTypeName' => proposal.Record_Type_Name__c,
                'stage'          => proposal.Stage__c,
                'categories'     => categories,
                'processedAt'    => Datetime.now().format('yyyy-MM-dd HH:mm:ss')
            };

            FileResult summaryFile = uploadFile(
                rootFolder.id,
                'proposal_summary.json',
                JSON.serializePretty(summary),
                'application/json'
            );

            // ── STEP C: Add to SharePoint List ──
            ListItem listEntry = addListItem(null, new Map<String, Object>{
                'Title'          => proposalFolderName,
                'SalesforceId'   => String.valueOf(proposal.Id),
                'RecordTypeName' => proposal.Record_Type_Name__c,
                'Stage'          => proposal.Stage__c,
                'FolderURL'      => rootFolder.webUrl,
                'SummaryFileURL' => summaryFile.webUrl
            });

            System.debug('List item created → ID: ' + listEntry.id);

            // ── STEP D: Save SharePoint data back to Salesforce ──
            // Save folder IDs back to Proposal_Document__c records
            for (SObject doc : docs) {
                String categoryValue = (String) doc.get(categoryField);
                FolderResult f = folders.get(categoryValue);
                if (f != null && docFieldMap.containsKey('SharePoint_Folder_Id__c')) {
                    doc.put('SharePoint_Folder_Id__c', f.id);
                }
            }
            if (!docs.isEmpty() && docFieldMap.containsKey('SharePoint_Folder_Id__c')) {
                update docs;
            }

            // Save root folder on Application_Proposal__c if fields exist
            Map<String, Schema.SObjectField> proposalFieldMap =
                Application_Proposal__c.SObjectType.getDescribe().fields.getMap();
            Boolean shouldUpdateProposal = false;

            if (proposalFieldMap.containsKey('SharePoint_Folder_Id__c')) {
                proposal.put('SharePoint_Folder_Id__c', rootFolder.id);
                shouldUpdateProposal = true;
            }
            if (proposalFieldMap.containsKey('SharePoint_Folder_URL__c')) {
                proposal.put('SharePoint_Folder_URL__c', rootFolder.webUrl);
                shouldUpdateProposal = true;
            }

            if (shouldUpdateProposal) {
                update proposal;
            }

            System.debug('processProposalAsync complete for: '
                + proposalFolderName);

        } catch (Exception e) {
            System.debug('ERROR processProposalAsync: '
                + e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    // ══════════════════════════════════════════════════════════
    // PRIVATE HELPERS
    // ══════════════════════════════════════════════════════════

    private static ListResult parseListResponse(String responseBody) {
        Map<String, Object> parsed =
            (Map<String, Object>) JSON.deserializeUntyped(responseBody);

        ListResult result  = new ListResult();
        result.items       = new List<ListItem>();
        result.nextLink    = (String) parsed.get('@odata.nextLink');

        List<Object> rawItems = (List<Object>) parsed.get('value');
        if (rawItems != null) {
            for (Object raw : rawItems) {
                result.items.add(
                    parseListItem((Map<String, Object>) raw)
                );
            }
        }

        result.totalCount = result.items.size();
        return result;
    }

    private static ListItem parseListItem(Map<String, Object> raw) {
        ListItem item  = new ListItem();
        item.id        = (String) raw.get('id');
        item.webUrl    = (String) raw.get('webUrl');
        item.fields    = new Map<String, Object>();

        Map<String, Object> rawFields =
            (Map<String, Object>) raw.get('fields');
        if (rawFields != null) {
            item.fields = rawFields;
        }

        return item;
    }

    private static String resolveMimeType(String extension) {
        Map<String, String> mimeMap = new Map<String, String>{
            'pdf'  => 'application/pdf',
            'png'  => 'image/png',
            'jpg'  => 'image/jpeg',
            'jpeg' => 'image/jpeg',
            'doc'  => 'application/msword',
            'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            'xls'  => 'application/vnd.ms-excel',
            'xlsx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'txt'  => 'text/plain',
            'csv'  => 'text/csv',
            'json' => 'application/json'
        };
        String ext = String.isBlank(extension)
            ? '' : extension.toLowerCase();
        return mimeMap.containsKey(ext)
            ? mimeMap.get(ext)
            : 'application/octet-stream';
    }

    private static String normalizeDriveRelativePath(String inputPath) {
        String p = String.isBlank(inputPath) ? '' : inputPath.trim();
        while (p.startsWith('/')) {
            p = p.substring(1);
        }
        while (p.endsWith('/')) {
            p = p.substring(0, p.length() - 1);
        }
        if (String.isBlank(p)) {
            throw new SharePointException('Path cannot be blank.');
        }
        return p;
    }

    private static String encodePathForGraph(String driveRelativePath) {
        List<String> encodedSegments = new List<String>();
        for (String segment : driveRelativePath.split('/')) {
            encodedSegments.add(
                EncodingUtil.urlEncode(segment, 'UTF-8').replace('+', '%20')
            );
        }
        return String.join(encodedSegments, '/');
    }
}