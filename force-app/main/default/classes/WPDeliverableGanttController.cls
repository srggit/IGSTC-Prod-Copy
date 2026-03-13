public with sharing class WPDeliverableGanttController {
    
    @AuraEnabled(cacheable=true)
    public static ResponseWrapper getProposalData(String proposalId) {
        ResponseWrapper response = new ResponseWrapper();
        
        try {
            if (String.isBlank(proposalId)) {
                response.success = false;
                response.error = 'Proposal ID is required';
                return response;
            }
            
            // Get proposal details
            Application_Proposal__c proposal = [
                SELECT Id, Duration_In_Months_Max_36__c 
                FROM Application_Proposal__c 
                WHERE Id = :proposalId
                LIMIT 1
            ];
            
            if (proposal == null) {
                response.success = false;
                response.error = 'Proposal not found';
                return response;
            }
            
            // Get work packages with deliverables and account mappings
            List<Work_Package__c> workPackages = [
                SELECT Id, Title__c, WP_Sequence__c, Duration_Start_Month__c, Duration_End_Month__c, Application__c,
                    (SELECT Id, Title__c, Deliverable_Sequence__c, Duration_Start_Month__c, Duration_End_Month__c 
                     FROM PI_Deliverables__r 
                     ORDER BY Deliverable_Sequence__c),
                    (SELECT Id, Account__c FROM Account_Mapping__r)
                FROM Work_Package__c 
                WHERE Application__c = :proposalId
                ORDER BY WP_Sequence__c
            ];
            
            // Set max duration from proposal or default to 36
            response.maxDuration = proposal.Duration_In_Months_Max_36__c != null ? 
                Integer.valueOf(proposal.Duration_In_Months_Max_36__c) : 36;
            
            // Process work packages and get contacts for each
            List<WorkPackageWrapper> wpWrappers = new List<WorkPackageWrapper>();
            
            // Step 1: Collect all Account IDs from all Work Packages
            Map<Id, Set<Id>> workPackageAccountMap = new Map<Id, Set<Id>>();
            Set<Id> allAccountIds = new Set<Id>();
            
            for (Work_Package__c wp : workPackages) {
                Set<Id> wpAccountIds = new Set<Id>();
                if (wp.Account_Mapping__r != null) {
                    for (Account_Mapping__c am : wp.Account_Mapping__r) {
                        if (am.Account__c != null) {
                            wpAccountIds.add(am.Account__c);
                            allAccountIds.add(am.Account__c);
                        }
                    }
                }
                workPackageAccountMap.put(wp.Id, wpAccountIds);
            }
            
            // Step 2: Get all APA records for all accounts at once
            Map<Id, Set<Id>> accountContactMap = new Map<Id, Set<Id>>();
            if (!allAccountIds.isEmpty()) {
                List<Applicant_Proposal_Association__c> allApaList = [
                    SELECT Id, Contact__c, Contact__r.AccountId 
                    FROM Applicant_Proposal_Association__c 
                    WHERE Contact__r.AccountId IN :allAccountIds 
                    AND Is_Signatory__c = false
                    AND Proposals__c = :proposalId
                ];
                
                for (Applicant_Proposal_Association__c apa : allApaList) {
                    Id accountId = apa.Contact__r.AccountId;
                    Id contactId = apa.Contact__c;
                    
                    if (!accountContactMap.containsKey(accountId)) {
                        accountContactMap.put(accountId, new Set<Id>());
                    }
                    accountContactMap.get(accountId).add(contactId);
                }
            }
            
            // Step 3: Get all Contact records at once
            Set<Id> allContactIds = new Set<Id>();
            for (Set<Id> contactIds : accountContactMap.values()) {
                allContactIds.addAll(contactIds);
            }
            
            Map<Id, Contact> contactMap = new Map<Id, Contact>();
            if (!allContactIds.isEmpty()) {
                List<Contact> allContacts = [
                    SELECT Id, FirstName, LastName, Email, Phone 
                    FROM Contact 
                    WHERE Id IN :allContactIds
                ];
                
                for (Contact c : allContacts) {
                    contactMap.put(c.Id, c);
                }
            }
            
            // Step 4: Build Work Package wrappers with contacts (no more queries!)
            for (Work_Package__c wp : workPackages) {
                WorkPackageWrapper wpWrapper = new WorkPackageWrapper();
                wpWrapper.Id = wp.Id;
                wpWrapper.title = wp.Title__c;
                wpWrapper.wpSequence = wp.WP_Sequence__c;
                wpWrapper.durationStartMonth = wp.Duration_Start_Month__c;
                wpWrapper.durationEndMonth = wp.Duration_End_Month__c;
                wpWrapper.deliverables = wp.PI_Deliverables__r;
                
                // Get contacts for this Work Package using the maps we built
                Set<Id> wpAccountIds = workPackageAccountMap.get(wp.Id);
                Set<Id> wpContactIds = new Set<Id>();
                
                if (wpAccountIds != null) {
                    for (Id accountId : wpAccountIds) {
                        Set<Id> contactsForAccount = accountContactMap.get(accountId);
                        if (contactsForAccount != null) {
                            wpContactIds.addAll(contactsForAccount);
                        }
                    }
                }
                
                // Build contact list for this Work Package
                List<Contact> wpContacts = new List<Contact>();
                for (Id contactId : wpContactIds) {
                    Contact c = contactMap.get(contactId);
                    if (c != null) {
                        wpContacts.add(c);
                    }
                }
                
                // Sort contacts by LastName, FirstName
                wpContacts.sort();
                
                wpWrapper.contacts = wpContacts;
                wpWrappers.add(wpWrapper);
            }
            
            response.workPackages = wpWrappers;
            response.success = true;
            
        } catch (Exception e) {
            response.success = false;
            response.error = 'Error retrieving proposal data: ' + e.getMessage();
            System.debug('Error in getProposalData: ' + e.getMessage() + ' - ' + e.getStackTraceString());
        }
        
        return response;
    }
    
    // Wrapper classes for data structure
    public class ResponseWrapper {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String error;
        @AuraEnabled public Integer maxDuration;
        @AuraEnabled public List<WorkPackageWrapper> workPackages;
        
        public ResponseWrapper() {
            this.success = false;
            this.maxDuration = 36;
            this.workPackages = new List<WorkPackageWrapper>();
        }
    }
    
    public class WorkPackageWrapper {
        @AuraEnabled public Id Id;
        @AuraEnabled public String title;
        @AuraEnabled public Decimal wpSequence;
        @AuraEnabled public Decimal durationStartMonth;
        @AuraEnabled public Decimal durationEndMonth;
        @AuraEnabled public List<PI_Deliverables__c> deliverables;
        @AuraEnabled public List<Contact> contacts;
        
        public WorkPackageWrapper() {
            this.durationStartMonth = 1;
            this.durationEndMonth = 36;
            this.deliverables = new List<PI_Deliverables__c>();
            this.contacts = new List<Contact>();
        }
    }
}
