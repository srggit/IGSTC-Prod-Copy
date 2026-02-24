trigger TriggerOnProposal2 on Application_Proposal__c (after update) {

    if (Trigger.isAfter && Trigger.isUpdate) {
        ProposalExpenseHandler.createExpenseCategoryAndDetails(
            Trigger.new,
            Trigger.oldMap
        );
    }
}