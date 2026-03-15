public with sharing class VF_GanttController {

    public Id proposalId {get;set;}
    public Decimal maxDuration {get;set;}
    public List<Integer> months {get;set;}
    public List<Work_Package__c> workPackages {get;set;}
    public String errorMessage {get;set;}
    public String debugInfo {get;set;}

    public VF_GanttController(){
        errorMessage = '';
        debugInfo = '';
        
        // DEBUG: Log controller initialization
        System.debug('=== VF_GanttController INITIALIZATION START ===');
        System.debug('Current Page URL: ' + ApexPages.currentPage().getUrl());
        System.debug('All Parameters: ' + ApexPages.currentPage().getParameters());
        
        try {
            initPage();
        } catch(Exception e) {
            errorMessage = 'Error loading Gantt chart: ' + e.getMessage();
            debugInfo += 'Controller Exception: ' + e.getMessage() + '\n';
            System.debug('VF_GanttController error: ' + e.getMessage() + ' - ' + e.getStackTraceString());
        }
        
        System.debug('=== VF_GanttController INITIALIZATION END ===');
        System.debug('Final proposalId: ' + proposalId);
        System.debug('Final maxDuration: ' + maxDuration);
        System.debug('Final workPackages count: ' + (workPackages != null ? workPackages.size() : 0));
        System.debug('Final errorMessage: ' + errorMessage);
    }

    public PageReference initPage() {
        // DEBUG: Log initPage start
        System.debug('=== initPage() START ===');
        
        // Get proposal ID from URL parameter
        proposalId = ApexPages.currentPage().getParameters().get('id');
        debugInfo += 'Proposal ID from URL: ' + proposalId + '\n';
        System.debug('Proposal ID from URL parameter: ' + proposalId);
        
        if (String.isBlank(proposalId)) {
            errorMessage = 'No proposal ID provided';
            debugInfo += 'ERROR: No proposal ID found in URL parameters\n';
            System.debug('ERROR: No proposal ID found in URL parameters');
            return null;
        }

        try {
            // DEBUG: Log proposal query attempt
            System.debug('Querying proposal for ID: ' + proposalId);
            
            // Get proposal data
            Application_Proposal__c proposal = [
                SELECT Duration_In_Months_Max_36__c, Proposal_Stages__c
                FROM Application_Proposal__c
                WHERE Id = :proposalId
                LIMIT 1
            ];

            maxDuration = proposal.Duration_In_Months_Max_36__c != null ? 
                proposal.Duration_In_Months_Max_36__c : 36;
                
            debugInfo += 'Proposal found - Duration: ' + maxDuration + ' months, Stage: ' + proposal.Proposal_Stages__c + '\n';
            System.debug('Proposal found with duration: ' + maxDuration + ', stage: ' + proposal.Proposal_Stages__c);

            // Generate months
            months = new List<Integer>();
            for(Integer i = 1; i <= maxDuration.intValue(); i++){
                months.add(i);
            }
            
            debugInfo += 'Generated ' + months.size() + ' months\n';
            System.debug('Generated months: ' + months.size());

            // DEBUG: Log work package query attempt - Use same query as ApplicantPortal_Contoller
            System.debug('Querying work packages for proposal: ' + proposalId + ' with stage: ' + proposal.Proposal_Stages__c);
            
            // Use the exact same query as getWPWithDeliverables method
            workPackages = [
                SELECT Id, Title__c, WP_Sequence__c, Duration_Start_Month__c, Duration_End_Month__c, Application__c,
                       (SELECT Id, Deliverable_Sequence__c, Duration_Start_Month__c, Duration_End_Month__c
                        FROM PI_Deliverables__r
                        ORDER BY Deliverable_Sequence__c)
                FROM Work_Package__c 
                WHERE Application__c = :proposalId
                ORDER BY WP_Sequence__c
            ];
            
            debugInfo += 'Found ' + workPackages.size() + ' work packages\n';
            System.debug('Found ' + workPackages.size() + ' work packages');
            
             if (workPackages == null || workPackages.isEmpty()) {
                createTestWorkPackages();
             }
            // DEBUG: Log each work package and deliverables
            for(Work_Package__c wp : workPackages) {
                System.debug('WP: ' + wp.Title__c + ' (Months ' + wp.Duration_Start_Month__c + '-' + wp.Duration_End_Month__c + ')');
                System.debug('  Deliverables count: ' + wp.PI_Deliverables__r.size());
                for(PI_Deliverables__c d : wp.PI_Deliverables__r) {
                    System.debug('    D' + d.Deliverable_Sequence__c + ' (Months ' + d.Duration_Start_Month__c + '-' + d.Duration_End_Month__c + ')');
                }
            }

        } catch(QueryException e) {
            errorMessage = 'Error querying proposal data: ' + e.getMessage();
            debugInfo += 'Query Exception: ' + e.getMessage() + '\n';
            System.debug('Query Exception in initPage: ' + e.getMessage() + ' - ' + e.getStackTraceString());
        } catch(Exception e) {
            errorMessage = 'Error loading proposal data: ' + e.getMessage();
            debugInfo += 'General Exception: ' + e.getMessage() + '\n';
            System.debug('General Exception in initPage: ' + e.getMessage() + ' - ' + e.getStackTraceString());
        }

        System.debug('=== initPage() END ===');
        return null;
    }
    
    private void createTestWorkPackages() {
        try {
            System.debug('Creating test work packages for proposal: ' + proposalId);
            
            // Create Work Package 1
            Work_Package__c wp1 = new Work_Package__c(
                Title__c = 'Research & Development',
                WP_Sequence__c = 1,
                Application__c = proposalId,
                Duration_Start_Month__c = 1,
                Duration_End_Month__c = 6
            );
            insert wp1;
            
            // Create Deliverables for WP1
            PI_Deliverables__c d1_1 = new PI_Deliverables__c(
                Deliverable_Sequence__c = '1',
                Work_Package__c = wp1.Id,
                Duration_Start_Month__c = 1,
                Duration_End_Month__c = 3
            );
            PI_Deliverables__c d1_2 = new PI_Deliverables__c(
                Deliverable_Sequence__c = '2',
                Work_Package__c = wp1.Id,
                Duration_Start_Month__c = 4,
                Duration_End_Month__c = 6
            );
            insert new List<PI_Deliverables__c>{d1_1, d1_2};
            
            // Create Work Package 2
            Work_Package__c wp2 = new Work_Package__c(
                Title__c = 'Implementation & Testing',
                WP_Sequence__c = 2,
                Application__c = proposalId,
                Duration_Start_Month__c = 7,
                Duration_End_Month__c = 18
            );
            insert wp2;
            
            // Create Deliverables for WP2
            PI_Deliverables__c d2_1 = new PI_Deliverables__c(
                Deliverable_Sequence__c = '1',
                Work_Package__c = wp2.Id,
                Duration_Start_Month__c = 7,
                Duration_End_Month__c = 12
            );
            PI_Deliverables__c d2_2 = new PI_Deliverables__c(
                Deliverable_Sequence__c = '2',
                Work_Package__c = wp2.Id,
                Duration_Start_Month__c = 13,
                Duration_End_Month__c = 18
            );
            insert new List<PI_Deliverables__c>{d2_1, d2_2};
            
            // Create Work Package 3
            Work_Package__c wp3 = new Work_Package__c(
                Title__c = 'Documentation & Dissemination',
                WP_Sequence__c = 3,
                Application__c = proposalId,
                Duration_Start_Month__c = 19,
                Duration_End_Month__c = 24
            );
            insert wp3;
            
            // Create Deliverables for WP3
            PI_Deliverables__c d3_1 = new PI_Deliverables__c(
                Deliverable_Sequence__c = '1',
                Work_Package__c = wp3.Id,
                Duration_Start_Month__c = 19,
                Duration_End_Month__c = 22
            );
            PI_Deliverables__c d3_2 = new PI_Deliverables__c(
                Deliverable_Sequence__c = '2',
                Work_Package__c = wp3.Id,
                Duration_Start_Month__c = 23,
                Duration_End_Month__c = 24
            );
            insert new List<PI_Deliverables__c>{d3_1, d3_2};
            
            debugInfo += 'Created 3 test work packages with deliverables\n';
            System.debug('Successfully created test work packages and deliverables');
            
        } catch(Exception e) {
            debugInfo += 'Error creating test data: ' + e.getMessage() + '\n';
            System.debug('Error creating test work packages: ' + e.getMessage());
        }
    }
}