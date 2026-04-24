public with sharing class ProposalDocumentTriggerHandler {
    public static void afterInsert(List<Proposal_Document__c> newRecords) {
        Set<Id> idsToSync = new Set<Id>();
        for (Proposal_Document__c row : newRecords) {
            if (row.Id != null) {
                idsToSync.add(row.Id);
            }
        }
        SharePointFolderSyncQueueable.enqueue('PROPOSAL_DOC', idsToSync);
    }

    public static void afterUpdate(
        List<Proposal_Document__c> newRecords,
        Map<Id, Proposal_Document__c> oldMap
    ) {
        Set<Id> idsToSync = new Set<Id>();
        for (Proposal_Document__c row : newRecords) {
            idsToSync.add(row.Id);
            Proposal_Document__c oldRow = oldMap.get(row.Id);
            if (oldRow == null || row.Name != oldRow.Name) {
                idsToSync.add(row.Id);
            }
        }
        SharePointFolderSyncQueueable.enqueue('PROPOSAL_DOC', idsToSync);
    }
}