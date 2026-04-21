trigger ApplicantProposalAssociationTrigger on Applicant_Proposal_Association__c (after insert) {
    if (Trigger.isAfter && Trigger.isInsert) {
        APATriggerHandler.afterInsert(Trigger.new);
    }
}