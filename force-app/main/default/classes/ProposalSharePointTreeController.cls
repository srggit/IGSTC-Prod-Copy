public with sharing class ProposalSharePointTreeController {

    public class TreeNode {
        @AuraEnabled public String key;
        @AuraEnabled public String label;
        @AuraEnabled public String nodeType;
        @AuraEnabled public String recordId;
        @AuraEnabled public String folderPath;
        @AuraEnabled public List<TreeNode> children;
    }

    @AuraEnabled(cacheable=true)
    public static List<TreeNode> getHierarchy(Id proposalId) {
        if (proposalId == null) {
            return new List<TreeNode>();
        }

        Application_Proposal__c proposal = [
            SELECT Id, Name, Record_Type_Name__c, CreatedDate, Campaign__r.Name
            FROM Application_Proposal__c
            WHERE Id = :proposalId
            LIMIT 1
        ];

        String yearSegment = String.valueOf(proposal.CreatedDate.year());
        String campaignSegment = proposal.Campaign__r != null
            ? proposal.Campaign__r.Name
            : proposal.Record_Type_Name__c;
        String rootPath = sanitizePathSegment(yearSegment)
            + '/' + sanitizePathSegment(campaignSegment)
            + '/' + sanitizePathSegment(proposal.Name);

        TreeNode proposalNode = new TreeNode();
        proposalNode.key = String.valueOf(proposal.Id);
        proposalNode.label = proposal.Name;
        proposalNode.nodeType = 'proposal';
        proposalNode.recordId = String.valueOf(proposal.Id);
        proposalNode.folderPath = rootPath;
        proposalNode.children = new List<TreeNode>();

        List<Applicant_Proposal_Association__c> apaList = getApas(proposalId);
        Map<Id, List<User_Document__c>> apaIdToUserDocs = getUserDocsByApa(proposalId, apaList);

        for (Applicant_Proposal_Association__c apa : apaList) {
            String apaPath = rootPath + '/Applicant_Proposal_Association/'
                + sanitizePathSegment(apa.Name);

            TreeNode apaNode = new TreeNode();
            apaNode.key = String.valueOf(apa.Id);
            apaNode.label = apa.Name;
            apaNode.nodeType = 'apa';
            apaNode.recordId = String.valueOf(apa.Id);
            apaNode.folderPath = apaPath;
            apaNode.children = new List<TreeNode>();

            List<User_Document__c> docs = apaIdToUserDocs.containsKey(apa.Id)
                ? apaIdToUserDocs.get(apa.Id)
                : new List<User_Document__c>();

            for (User_Document__c userDoc : docs) {
                TreeNode userDocNode = new TreeNode();
                userDocNode.key = String.valueOf(userDoc.Id);
                userDocNode.label = userDoc.Name;
                userDocNode.nodeType = 'userDoc';
                userDocNode.recordId = String.valueOf(userDoc.Id);
                userDocNode.folderPath = apaPath + '/User_Document/'
                    + sanitizePathSegment(userDoc.Name);
                userDocNode.children = new List<TreeNode>();
                apaNode.children.add(userDocNode);
            }

            proposalNode.children.add(apaNode);
        }

        for (Proposal_Document__c proposalDoc : getProposalDocs(proposalId)) {
            TreeNode proposalDocNode = new TreeNode();
            proposalDocNode.key = String.valueOf(proposalDoc.Id);
            proposalDocNode.label = proposalDoc.Name;
            proposalDocNode.nodeType = 'proposalDoc';
            proposalDocNode.recordId = String.valueOf(proposalDoc.Id);
            proposalDocNode.folderPath = rootPath + '/Proposal_Document/'
                + sanitizePathSegment(proposalDoc.Name);
            proposalDocNode.children = new List<TreeNode>();
            proposalNode.children.add(proposalDocNode);
        }

        return new List<TreeNode>{ proposalNode };
    }

    @AuraEnabled
    public static Map<String, List<Object>> getFolderContent(String folderPath) {
        if (String.isBlank(folderPath)) {
            return new Map<String, List<Object>>{
                'files' => new List<Object>(),
                'folders' => new List<Object>()
            };
        }
        return getFolderContentByPath(folderPath);
    }

    @AuraEnabled
    public static Map<String, Object> createFolder(String path) {
        String normalizedPath = normalizeDriveRelativePath(path);
        Integer splitAt = normalizedPath.lastIndexOf('/');
        String folderName = splitAt > -1 ? normalizedPath.substring(splitAt + 1) : normalizedPath;
        String parentPath = splitAt > -1 ? normalizedPath.substring(0, splitAt) : null;

        String parentId = String.isBlank(parentPath) ? null : getItemIdByPath(parentPath);
        SharePointService.FolderResult created = SharePointService.createFolder(folderName, parentId);
        return new Map<String, Object>{
            'Name' => created.name,
            'UniqueId' => created.id,
            'linkedUrl' => created.webUrl,
            'ServerRelativeUrl' => normalizedPath
        };
    }

    @AuraEnabled
    public static Map<String, Object> createFile(String base64, String fileName, String path) {
        Blob fileContents = EncodingUtil.base64Decode(base64);
        String normalizedPath = normalizeDriveRelativePath(path);
        String folderId = getItemIdByPath(normalizedPath);
        SharePointService.FileResult uploaded = SharePointService.uploadBlobFile(
            folderId,
            fileName,
            fileContents,
            null
        );
        String publicUrl = SharePointService.createAnonymousViewLink(uploaded.id);
        return new Map<String, Object>{
            'Name' => uploaded.name,
            'UniqueId' => uploaded.id,
            'linkedUrl' => String.isBlank(publicUrl) ? uploaded.webUrl : publicUrl,
            'ServerRelativeUrl' => normalizedPath + '/' + fileName
        };
    }

    @AuraEnabled
    public static String deleteFileSP(String path) {
        deleteItemByPath(path);
        return 'Success';
    }

    @AuraEnabled
    public static String deleteFolderInsideSite(String path) {
        deleteItemByPath(path);
        return 'Success';
    }

    private static List<Applicant_Proposal_Association__c> getApas(Id proposalId) {
        Map<String, Schema.SObjectField> apaFieldMap =
            Applicant_Proposal_Association__c.SObjectType.getDescribe().fields.getMap();

        String relationField = apaFieldMap.containsKey('Proposals__c') ? 'Proposals__c' : 'Proposal__c';
        String soql = 'SELECT Id, Name FROM Applicant_Proposal_Association__c'
            + ' WHERE ' + relationField + ' = :proposalId ORDER BY Name';

        return (List<Applicant_Proposal_Association__c>) Database.query(soql);
    }

    private static Map<Id, List<User_Document__c>> getUserDocsByApa(
        Id proposalId,
        List<Applicant_Proposal_Association__c> apas
    ) {
        Map<Id, List<User_Document__c>> result = new Map<Id, List<User_Document__c>>();
        for (Applicant_Proposal_Association__c apa : apas) {
            result.put(apa.Id, new List<User_Document__c>());
        }
        if (apas.isEmpty()) {
            return result;
        }

        Set<Id> apaIds = new Map<Id, Applicant_Proposal_Association__c>(apas).keySet();
        Map<String, Schema.SObjectField> userDocFields =
            User_Document__c.SObjectType.getDescribe().fields.getMap();

        String relationField = null;
        if (userDocFields.containsKey('Applicant_Proposal_Association__c')) {
            relationField = 'Applicant_Proposal_Association__c';
        } else if (userDocFields.containsKey('Proposal_Id__c')) {
            relationField = 'Proposal_Id__c';
        } else if (userDocFields.containsKey('Proposals__c')) {
            relationField = 'Proposals__c';
        }

        if (String.isBlank(relationField)) {
            return result;
        }

        String soql;
        List<User_Document__c> docs;
        if (relationField == 'Applicant_Proposal_Association__c') {
            soql = 'SELECT Id, Name, Applicant_Proposal_Association__c'
                + ' FROM User_Document__c WHERE Applicant_Proposal_Association__c IN :apaIds'
                + ' ORDER BY Name';
            docs = Database.query(soql);

            for (User_Document__c d : docs) {
                Id apaId = (Id) d.get('Applicant_Proposal_Association__c');
                if (result.containsKey(apaId)) {
                    result.get(apaId).add(d);
                }
            }
        } else {
            soql = 'SELECT Id, Name FROM User_Document__c WHERE '
                + relationField + ' = :proposalId ORDER BY Name';
            docs = Database.query(soql);

            if (!apas.isEmpty()) {
                Id firstApaId = apas[0].Id;
                result.put(firstApaId, docs);
            }
        }
        return result;
    }

    private static List<Proposal_Document__c> getProposalDocs(Id proposalId) {
        Map<String, Schema.SObjectField> proposalDocFields =
            Proposal_Document__c.SObjectType.getDescribe().fields.getMap();

        String relationField = proposalDocFields.containsKey('Proposals__c')
            ? 'Proposals__c'
            : 'Proposal__c';

        String soql = 'SELECT Id, Name FROM Proposal_Document__c'
            + ' WHERE ' + relationField + ' = :proposalId ORDER BY Name';
        return (List<Proposal_Document__c>) Database.query(soql);
    }

    private static String sanitizePathSegment(String value) {
        String v = String.isBlank(value) ? 'Unnamed' : value.trim();
        return v.replace('/', '-');
    }

    private static SharePoint_Config__mdt getConfig() {
        return [
            SELECT Drive_Id__c
            FROM SharePoint_Config__mdt
            WHERE DeveloperName = 'igstc'
            LIMIT 1
        ];
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
            throw new AuraHandledException('Path cannot be blank.');
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

    private static HttpResponse callGraph(String method, String path, String body, String contentType) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SharePoint_Graph_API' + path);
        req.setMethod(method);
        req.setHeader('Content-Type', String.isBlank(contentType) ? 'application/json' : contentType);
        req.setTimeout(30000);
        if (String.isNotBlank(body)) {
            req.setBody(body);
        }
        return new Http().send(req);
    }

    private static String getItemIdByPath(String itemPath) {
        String normalized = normalizeDriveRelativePath(itemPath);
        String driveId = getConfig().Drive_Id__c;
        String graphPath = '/v1.0/drives/' + driveId + '/root:/' + encodePathForGraph(normalized);
        HttpResponse res = callGraph('GET', graphPath, null, 'application/json');
        if (res.getStatusCode() == 200) {
            Map<String, Object> parsed =
                (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) parsed.get('id');
        }
        throw new AuraHandledException(
            'Failed to resolve SharePoint path: ' + normalized + ' | '
            + res.getStatusCode() + ' ' + res.getBody()
        );
    }

    private static Map<String, List<Object>> getFolderContentByPath(String folderPath) {
        String normalized = normalizeDriveRelativePath(folderPath);
        String driveId = getConfig().Drive_Id__c;
        String graphPath = '/v1.0/drives/' + driveId + '/root:/'
            + encodePathForGraph(normalized) + ':/children';
        HttpResponse res = callGraph('GET', graphPath, null, 'application/json');
        if (res.getStatusCode() != 200) {
            throw new AuraHandledException(
                'Failed to list folder content: ' + normalized + ' | '
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
                String childPath = normalized + '/' + name;

                Map<String, Object> item = new Map<String, Object>{
                    'Name' => name,
                    'UniqueId' => (String) raw.get('id'),
                    'linkedUrl' => (String) raw.get('webUrl'),
                    'ServerRelativeUrl' => childPath
                };

                if (raw.containsKey('folder')) {
                    folders.add(item);
                } else {
                    files.add(item);
                }
            }
        }

        return new Map<String, List<Object>>{
            'files' => files,
            'folders' => folders
        };
    }

    private static void deleteItemByPath(String itemPath) {
        String normalized = normalizeDriveRelativePath(itemPath);
        String driveId = getConfig().Drive_Id__c;
        String graphPath = '/v1.0/drives/' + driveId + '/root:/' + encodePathForGraph(normalized);
        HttpResponse res = callGraph('DELETE', graphPath, null, 'application/json');
        if (res.getStatusCode() != 204) {
            throw new AuraHandledException(
                'Failed to delete item: ' + normalized + ' | '
                + res.getStatusCode() + ' ' + res.getBody()
            );
        }
    }
}