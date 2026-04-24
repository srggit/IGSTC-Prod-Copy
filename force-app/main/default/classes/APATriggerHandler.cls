public class APATriggerHandler {
    public static void afterInsert(List<Applicant_Proposal_Association__c> newRecords) {
        ProposalExpenseHandler.createExpenseCategoryAndDetailsForAPAInsert(newRecords);

        Set<Id> apaIds = new Set<Id>();
        for (Applicant_Proposal_Association__c recordItem : newRecords) {
            if (recordItem.Id != null) {
                apaIds.add(recordItem.Id);
            }
        }
        SharePointFolderSyncQueueable.enqueue('APA', apaIds);
    }
}