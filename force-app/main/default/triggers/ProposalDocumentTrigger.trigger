trigger ProposalDocumentTrigger on Proposal_Document__c (after insert, after update) {
    if (Trigger.isAfter && Trigger.isInsert) {
        ProposalDocumentTriggerHandler.afterInsert(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        ProposalDocumentTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }
}