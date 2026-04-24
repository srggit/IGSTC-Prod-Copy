public with sharing class UserDocumentTriggerHandler {
    public static void afterInsert(List<User_Document__c> newRecords) {
        Set<Id> idsToSync = new Set<Id>();
        for (User_Document__c row : newRecords) {
            if (row.Id != null) {
                idsToSync.add(row.Id);
            }
        }
        SharePointFolderSyncQueueable.enqueue('USER_DOC', idsToSync);
    }

    public static void afterUpdate(
        List<User_Document__c> newRecords,
        Map<Id, User_Document__c> oldMap
    ) {
        Set<Id> idsToSync = new Set<Id>();
        for (User_Document__c row : newRecords) {
            User_Document__c oldRow = oldMap.get(row.Id);
            if (oldRow == null || row.Name != oldRow.Name) {
                idsToSync.add(row.Id);
            }
        }
        SharePointFolderSyncQueueable.enqueue('USER_DOC', idsToSync);
    }
}