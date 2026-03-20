trigger ApplicationProposalTrigger on Application_Proposal__c (after update) {
    
    /*
    // Set to store Proposal IDs where Expected_Deliverables__c has changed
    Set<Id> proposalIdsWithChangedDeliverables = new Set<Id>();
    
    // Check if Expected_Deliverables__c field has changed
    for (Application_Proposal__c proposal : Trigger.new) {
        Application_Proposal__c oldProposal = Trigger.oldMap.get(proposal.Id);
        
        // Only proceed if Expected_Deliverables__c has changed and is not null
        if (proposal.Expected_Deliverables__c != oldProposal.Expected_Deliverables__c) {
            proposalIdsWithChangedDeliverables.add(proposal.Id);
        }
    }
    
    // If there are proposals with changed deliverables, update their APA records
    if (!proposalIdsWithChangedDeliverables.isEmpty()) {
        KeywordFormatter.updateAPAExpectedDeliverables(proposalIdsWithChangedDeliverables);
    }
	*/
}