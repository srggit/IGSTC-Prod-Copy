public with sharing class SharePointFolderSyncQueueable implements Queueable, Database.AllowsCallouts {
    private String syncType;
    private List<Id> recordIds;

    public SharePointFolderSyncQueueable(String syncType, List<Id> recordIds) {
        this.syncType = syncType;
        this.recordIds = recordIds == null ? new List<Id>() : recordIds;
    }

    public static void enqueue(String syncType, Set<Id> ids) {
        if (ids == null || ids.isEmpty()) {
            return;
        }
        System.enqueueJob(new SharePointFolderSyncQueueable(syncType, new List<Id>(ids)));
    }

    public void execute(QueueableContext qc) {
        if (recordIds.isEmpty()) {
            return;
        }

        if (syncType == 'PROPOSAL') {
            processProposalRecords();
        } else if (syncType == 'APA') {
            processApaRecords();
        } else if (syncType == 'USER_DOC') {
            processUserDocuments();
        } else if (syncType == 'PROPOSAL_DOC') {
            processProposalDocuments();
        }
    }

    private void processProposalRecords() {
        Set<Id> proposalIds = new Set<Id>(recordIds);
        Map<Id, Application_Proposal__c> proposalById = getProposalById(proposalIds);
        for (Application_Proposal__c proposal : proposalById.values()) {
            try {
                ensureFolderPath(getProposalRootPath(proposal));
            } catch (Exception e) {
                System.debug('SharePoint PROPOSAL folder sync failed: ' + e.getMessage());
            }
        }
    }

    private void processApaRecords() {
        Map<String, Schema.SObjectField> apaFields =
            Applicant_Proposal_Association__c.SObjectType.getDescribe().fields.getMap();
        String proposalRelField = apaFields.containsKey('Proposals__c') ? 'Proposals__c' : 'Proposal__c';

        String soql = 'SELECT Id, Name, ' + proposalRelField
            + ' FROM Applicant_Proposal_Association__c WHERE Id IN :recordIds';
        List<SObject> apaRows = Database.query(soql);

        Set<Id> proposalIds = new Set<Id>();
        for (SObject row : apaRows) {
            Id proposalId = (Id) row.get(proposalRelField);
            if (proposalId != null) {
                proposalIds.add(proposalId);
            }
        }

        Map<Id, Application_Proposal__c> proposalById = getProposalById(proposalIds);
        for (SObject row : apaRows) {
            try {
                Id proposalId = (Id) row.get(proposalRelField);
                Application_Proposal__c proposal = proposalById.get(proposalId);
                if (proposal == null) {
                    continue;
                }

                String path = getProposalRootPath(proposal)
                    + '/Applicant_Proposal_Association/'
                    + sanitizePathSegment((String) row.get('Name'));
                ensureFolderPath(path);
            } catch (Exception e) {
                System.debug('SharePoint APA folder sync failed: ' + e.getMessage());
            }
        }
    }

    private void processUserDocuments() {
        Map<String, Schema.SObjectField> userDocFields =
            User_Document__c.SObjectType.getDescribe().fields.getMap();

        String apaRelField = userDocFields.containsKey('Applicant_Proposal_Association__c')
            ? 'Applicant_Proposal_Association__c'
            : null;
        String proposalRelField = userDocFields.containsKey('Proposals__c')
            ? 'Proposals__c'
            : (userDocFields.containsKey('Proposal_Id__c') ? 'Proposal_Id__c' : null);

        List<String> selectParts = new List<String>{ 'Id', 'Name' };
        if (apaRelField != null) {
            selectParts.add(apaRelField);
        }
        if (proposalRelField != null && proposalRelField != apaRelField) {
            selectParts.add(proposalRelField);
        }

        String soql = 'SELECT ' + String.join(selectParts, ', ')
            + ' FROM User_Document__c WHERE Id IN :recordIds';
        List<SObject> userDocRows = Database.query(soql);

        Set<Id> apaIds = new Set<Id>();
        Set<Id> proposalIds = new Set<Id>();
        for (SObject row : userDocRows) {
            if (apaRelField != null && row.get(apaRelField) != null) {
                apaIds.add((Id) row.get(apaRelField));
            }
            if (proposalRelField != null && row.get(proposalRelField) != null) {
                proposalIds.add((Id) row.get(proposalRelField));
            }
        }

        Map<String, Schema.SObjectField> apaFields =
            Applicant_Proposal_Association__c.SObjectType.getDescribe().fields.getMap();
        String apaToProposalField = apaFields.containsKey('Proposals__c') ? 'Proposals__c' : 'Proposal__c';

        Map<Id, SObject> apaById = new Map<Id, SObject>();
        if (!apaIds.isEmpty()) {
            String apaSoql = 'SELECT Id, Name, ' + apaToProposalField
                + ' FROM Applicant_Proposal_Association__c WHERE Id IN :apaIds';
            for (SObject apaRow : Database.query(apaSoql)) {
                apaById.put((Id) apaRow.get('Id'), apaRow);
                if (apaRow.get(apaToProposalField) != null) {
                    proposalIds.add((Id) apaRow.get(apaToProposalField));
                }
            }
        }

        Map<Id, Application_Proposal__c> proposalById = getProposalById(proposalIds);

        for (SObject row : userDocRows) {
            try {
                Id resolvedProposalId;
                String apaName;

                if (apaRelField != null && row.get(apaRelField) != null) {
                    Id apaId = (Id) row.get(apaRelField);
                    SObject apaRow = apaById.get(apaId);
                    if (apaRow != null) {
                        resolvedProposalId = (Id) apaRow.get(apaToProposalField);
                        apaName = (String) apaRow.get('Name');
                    }
                }
                if (resolvedProposalId == null && proposalRelField != null && row.get(proposalRelField) != null) {
                    resolvedProposalId = (Id) row.get(proposalRelField);
                }

                Application_Proposal__c proposal = proposalById.get(resolvedProposalId);
                if (proposal == null) {
                    continue;
                }

                String path = getProposalRootPath(proposal);
                if (!String.isBlank(apaName)) {
                    path += '/Applicant_Proposal_Association/' + sanitizePathSegment(apaName);
                }
                path += '/User_Document/' + sanitizePathSegment((String) row.get('Name'));

                ensureFolderPath(path);
            } catch (Exception e) {
                System.debug('SharePoint User_Document folder sync failed: ' + e.getMessage());
            }
        }
    }

    private void processProposalDocuments() {
        Map<String, Schema.SObjectField> proposalDocFields =
            Proposal_Document__c.SObjectType.getDescribe().fields.getMap();
        String proposalRelField = proposalDocFields.containsKey('Proposals__c') ? 'Proposals__c' : 'Proposal__c';

        String soql = 'SELECT Id, Name, ' + proposalRelField
            + ' FROM Proposal_Document__c WHERE Id IN :recordIds';
        List<SObject> proposalDocRows = Database.query(soql);

        Set<Id> proposalIds = new Set<Id>();
        for (SObject row : proposalDocRows) {
            if (row.get(proposalRelField) != null) {
                proposalIds.add((Id) row.get(proposalRelField));
            }
        }

        Map<Id, Application_Proposal__c> proposalById = getProposalById(proposalIds);
        for (SObject row : proposalDocRows) {
            try {
                Id proposalId = (Id) row.get(proposalRelField);
                Application_Proposal__c proposal = proposalById.get(proposalId);
                if (proposal == null) {
                    continue;
                }

                String path = getProposalRootPath(proposal)
                    + '/Proposal_Document/'
                    + sanitizePathSegment((String) row.get('Name'));
                ensureFolderPath(path);
            } catch (Exception e) {
                System.debug('SharePoint Proposal_Document folder sync failed: ' + e.getMessage());
                System.debug('Error line: ' + e.getLineNumber());
                
            }
        }
    }

    private static Map<Id, Application_Proposal__c> getProposalById(Set<Id> proposalIds) {
        if (proposalIds.isEmpty()) {
            return new Map<Id, Application_Proposal__c>();
        }
        return new Map<Id, Application_Proposal__c>([
            SELECT Id, Name, Record_Type_Name__c, CreatedDate, Campaign__r.Name
            FROM Application_Proposal__c
            WHERE Id IN :proposalIds
        ]);
    }

    private static String getProposalRootPath(Application_Proposal__c proposal) {
        String yearSegment = String.valueOf(proposal.CreatedDate.year());
        String campaignSegment = proposal.Campaign__r != null
            ? proposal.Campaign__r.Name
            : proposal.Record_Type_Name__c;

        return sanitizePathSegment(yearSegment)
            + '/' + sanitizePathSegment(campaignSegment)
            + '/' + sanitizePathSegment(proposal.Name);
    }

    private static void ensureFolderPath(String fullPath) {
        String normalized = normalizeDriveRelativePath(fullPath);
        List<String> segments = normalized.split('/');

        String currentPath = '';
        String parentId = null;
        for (String segment : segments) {
            currentPath = String.isBlank(currentPath) ? segment : currentPath + '/' + segment;
            String existingId = tryGetItemIdByPath(currentPath);
            if (!String.isBlank(existingId)) {
                parentId = existingId;
                continue;
            }

            SharePointService.FolderResult created = SharePointService.createFolder(segment, parentId);
            parentId = created.id;
        }
    }

    private static String tryGetItemIdByPath(String itemPath) {
        String normalized = normalizeDriveRelativePath(itemPath);
        String driveId = getConfig().Drive_Id__c;
        String path = '/v1.0/drives/' + driveId + '/root:/' + encodePathForGraph(normalized);
        HttpResponse res = callGraph('GET', path, null, 'application/json');
        if (res.getStatusCode() == 200) {
            Map<String, Object> parsed =
                (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) parsed.get('id');
        }
        return null;
    }

    private static SharePoint_Config__mdt getConfig() {
        return [
            SELECT Drive_Id__c
            FROM SharePoint_Config__mdt
            WHERE DeveloperName = 'igstc'
            LIMIT 1
        ];
    }

    private static HttpResponse callGraph(
        String method,
        String path,
        String body,
        String contentType
    ) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SharePoint_Graph_API' + path);
        req.setMethod(method);
        req.setHeader(
            'Content-Type',
            String.isBlank(contentType) ? 'application/json' : contentType
        );
        req.setTimeout(30000);
        if (String.isNotBlank(body)) {
            req.setBody(body);
        }
        return new Http().send(req);
    }

    private static String normalizeDriveRelativePath(String inputPath) {
        String p = String.isBlank(inputPath) ? '' : inputPath.trim();
        while (p.startsWith('/')) {
            p = p.substring(1);
        }
        while (p.endsWith('/')) {
            p = p.substring(0, p.length() - 1);
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

    private static String sanitizePathSegment(String value) {
        String v = String.isBlank(value) ? 'Unnamed' : value.trim();
        return v.replace('/', '-');
    }
}