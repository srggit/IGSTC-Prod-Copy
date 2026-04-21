public class APATriggerHandler {
    public static void afterInsert(List<Applicant_Proposal_Association__c> newRecords) {
        ProposalExpenseHandler.createExpenseCategoryAndDetailsForAPAInsert(newRecords);
    }
}