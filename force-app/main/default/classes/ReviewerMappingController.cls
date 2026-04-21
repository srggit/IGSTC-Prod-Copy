public with sharing class ReviewerMappingController {
    
    public class ReviewerMappingWrapper {
        @AuraEnabled public String proposalId { get; set; }
        @AuraEnabled public String reviewerName { get; set; }
        
        public ReviewerMappingWrapper(String proposalId, String reviewerName) {
            this.proposalId = proposalId;
            this.reviewerName = reviewerName;
        }
    }
    
    public class GridData {
        @AuraEnabled public List<String> proposalIds { get; set; }
        @AuraEnabled public List<String> reviewerNames { get; set; }
        @AuraEnabled public List<Map<String, String>> gridRows { get; set; }
        
        public GridData() {
            this.proposalIds = new List<String>();
            this.reviewerNames = new List<String>();
            this.gridRows = new List<Map<String, String>>();
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static GridData getReviewerMarkingData(String campaignId, String proposalStage, String proposalCallYear) {
        GridData gridData = new GridData();
        
        System.debug('getReviewerMarkingData called with campaignId: ' + campaignId + ', proposalStage: ' + proposalStage);
        
        if (String.isBlank(campaignId)) {
            return gridData;
        }

        DateTime startDate;
        DateTime endDate;
        Integer yearValue = null;
        
        if (!String.isBlank(proposalCallYear)) {
            try {
                yearValue = Integer.valueOf(proposalCallYear);
            } catch (Exception e) {
                return gridData;
            }
        }

        List<Reviewer_Mapping__c> reviewerMappings = new List<Reviewer_Mapping__c>();
        
        // NEW LOGIC FOR YEARS > 2025
        if(yearValue != null && yearValue > 2025) {
            System.debug('-------------- USING NEW METHOD FOR YEARS > 2025 --------------');
            reviewerMappings = [
                SELECT Proposals__c, 
                Proposals__r.Campaign__r.Name, 
                Proposals__r.Proposal_Stages__c, 
                Proposal_Reviewer_ratings__c, 
                Proposals__r.Name, 
                Proposal_Count__c, 
                Reviewer__c, 
                Reviewer__r.Name, 
                Reviewer_Email__c 
                FROM Reviewer_Mapping__c 
                WHERE Proposals__c != null 
                AND Reviewer__c != null
                AND Proposals__r.Proposal_Stages__c != 'Draft'
                AND Proposals__r.Campaign__c = :campaignId
                AND Proposals__r.yearly_Call__r.Years__r.Name = :String.valueOf(yearValue)
                ORDER BY Proposals__c, Reviewer__r.Name
            ];
            System.debug('reviewerMappings size: ' + reviewerMappings.size());
        } 
        // EXISTING LOGIC FOR YEARS <= 2025
        else {
            System.debug('-------------- USING EXISTING METHOD FOR YEARS <= 2025 --------------');
            if (yearValue != null) {
                startDate = DateTime.newInstance(yearValue, 1, 1, 0, 0, 0);
                endDate = DateTime.newInstance(yearValue + 1, 1, 1, 0, 0, 0);
            }
            System.debug('startDate: ' + startDate);
            System.debug('endDate: ' + endDate);

            List<String> whereParts = new List<String>{
                'Proposals__c != null',
                'Reviewer__c != null',
                'Proposals__r.Proposal_Stages__c != \'Draft\'',
                'Proposals__r.Campaign__c = :campaignId'
            };
            
            if (!String.isBlank(proposalStage)) {
                whereParts.add('Proposals__r.Stage__c = :proposalStage');
            }
            if (yearValue != null) {
                whereParts.add('Proposals__r.CreatedDate >= :startDate');
                whereParts.add('Proposals__r.CreatedDate < :endDate');
            }

            String soql = 'SELECT Proposals__c, ' +
                'Proposals__r.Campaign__r.Name, ' +
                'Proposals__r.Proposal_Stages__c, ' +
                'Proposal_Reviewer_ratings__c, ' +
                'Proposals__r.Name, ' +
                'Proposal_Count__c, ' +
                'Reviewer__c, ' +
                'Reviewer__r.Name, ' +
                'Reviewer_Email__c ' +
                'FROM Reviewer_Mapping__c ' +
                'WHERE ' + String.join(whereParts, ' AND ') + ' ' +
                'ORDER BY Proposals__c, Reviewer__r.Name';

            reviewerMappings = Database.query(soql);
            System.debug('reviewerMappings size: ' + reviewerMappings.size());
        }
        
        // Collect unique proposal IDs and reviewer names
        Set<String> uniqueProposalIds = new Set<String>();
        Set<String> uniqueReviewerNames = new Set<String>();
        
        // Map to store proposal to reviewers mapping
        Map<String, Set<String>> proposalToReviewersMap = new Map<String, Set<String>>();
        // Map to store proposal ID to proposal name mapping
        Map<String, String> proposalIdToNameMap = new Map<String, String>();
        
        for (Reviewer_Mapping__c mapping : reviewerMappings) {
            String proposalId = mapping.Proposals__c;
            String proposalName = mapping.Proposals__r.Name;
            String reviewerName = mapping.Reviewer__r.Name;
            
            uniqueProposalIds.add(proposalId);
            uniqueReviewerNames.add(reviewerName);
            proposalIdToNameMap.put(proposalId, proposalName);
            
            if (!proposalToReviewersMap.containsKey(proposalId)) {
                proposalToReviewersMap.put(proposalId, new Set<String>());
            }
            proposalToReviewersMap.get(proposalId).add(reviewerName);
        }
        
        // Convert sets to sorted lists
        gridData.proposalIds = new List<String>(uniqueProposalIds);
        gridData.proposalIds.sort();
        
        gridData.reviewerNames = new List<String>(uniqueReviewerNames);
        gridData.reviewerNames.sort();
        
        // Build grid rows
        for (String proposalId : gridData.proposalIds) {
            Map<String, String> row = new Map<String, String>();
            row.put('proposalId', proposalId);
            row.put('proposalName', proposalIdToNameMap.get(proposalId));
            
            Set<String> assignedReviewers = proposalToReviewersMap.get(proposalId);
            if (assignedReviewers == null) {
                assignedReviewers = new Set<String>();
            }
            
            // Add column for each reviewer
            for (String reviewerName : gridData.reviewerNames) {
                if (assignedReviewers.contains(reviewerName)) {
                    row.put(reviewerName, '1');
                } else {
                    row.put(reviewerName, '');
                }
            }
            
            gridData.gridRows.add(row);
        }
        
        return gridData;
    }

    @AuraEnabled(cacheable=true)
    public static List<Campaign> getCampaignName(){
        return[
            SELECT Id, Name FROM Campaign  ORDER BY Name DESC
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getStageOptions() {
        List<String> stageList = new List<String>();
 
        try {
            Schema.DescribeFieldResult fieldResult = Application_Proposal__c.Stage__c.getDescribe();
 
            for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
                if (entry.isActive()) {
                    stageList.add(entry.getValue());
                }
            }
        } catch (Exception e) {
            System.debug('Error getting stage options: ' + e.getMessage());
            // Return default options if there's an error
            stageList.add('Stage 1');
            stageList.add('Stage 2');
        }
 
        return stageList;
    }

    @AuraEnabled(cacheable=true)
    public static List<Year__c> getCallYearOptions() {
        List<Year__c> yearList = [SELECT Id, Name FROM Year__c ORDER BY Name ASC];

        return yearList;
    }

    // ------------------------------------------------- PERCENTILE REPORT METHODS --------------------------------------------------------------- //
    public class RowData {
        @AuraEnabled public String proposalId;
        @AuraEnabled public String proposalName;
        @AuraEnabled public Map<String, Decimal> reviewerScores;
        @AuraEnabled public Decimal avgScore;
    }
    public class StageOption {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }

    public class CallTypeOption {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }

    public class TableWrapper {
        @AuraEnabled public List<String> reviewers;
        @AuraEnabled public List<RowData> rows;
    }

    /**
     * Picklist values for the proposal looked up from Reviewer_Mapping__c.Proposals__c (Proposals__r.Stage__c).
    */
    @AuraEnabled(cacheable=true)
    public static List<StageOption> getProposalStageFilterOptions() {
        List<StageOption> options = new List<StageOption>();
        StageOption allOpt = new StageOption();
        allOpt.label = 'All stages';
        allOpt.value = '';
        options.add(allOpt);

        try {
            Schema.DescribeFieldResult lookupDfr = Reviewer_Mapping__c.Proposals__c.getDescribe();
            if (lookupDfr.getReferenceTo().isEmpty()) {
                return options;
            }
            Schema.SObjectType proposalType = lookupDfr.getReferenceTo()[0];
            Map<String, Schema.SObjectField> fieldMap = proposalType.getDescribe().fields.getMap();
            if (!fieldMap.containsKey('Stage__c')) {
                return options;
            }
            Schema.DescribeFieldResult stageDfr = fieldMap.get('Stage__c').getDescribe();
            if (stageDfr.getType() != Schema.DisplayType.PICKLIST) {
                return options;
            }
            for (Schema.PicklistEntry pe : stageDfr.getPicklistValues()) {
                if (!pe.isActive()) {
                    continue;
                }
                StageOption o = new StageOption();
                o.label = pe.getLabel();
                o.value = pe.getValue();
                options.add(o);
            }
        } catch (Exception e) {
            System.debug('getProposalStageFilterOptions: ' + e.getMessage());
        }
        return options;
    }

    @AuraEnabled(cacheable=true)
    public static List<CallTypeOption> getCallTypeFilterOptions() {
        List<CallTypeOption> options = new List<CallTypeOption>();
        CallTypeOption allOpt = new CallTypeOption();
        allOpt.label = 'All Call Types';
        allOpt.value = '';
        options.add(allOpt);

        try {
            Set<Id> campaignIds = new Set<Id>();
            for (Reviewer_Mapping__c rec : [
                SELECT Proposals__r.Campaign__c
                FROM Reviewer_Mapping__c
                WHERE Proposals__r.Campaign__c != null
            ]) {
                campaignIds.add(rec.Proposals__r.Campaign__c);
            }

            if (campaignIds.isEmpty()) {
                return options;
            }

            for (Campaign c : [
                SELECT Id, Name
                FROM Campaign
                WHERE Id IN :campaignIds
                ORDER BY Name
            ]) {
                CallTypeOption o = new CallTypeOption();
                o.label = c.Name;
                o.value = c.Id;
                options.add(o);
            }
        } catch (Exception e) {
            System.debug('getCallTypeFilterOptions: ' + e.getMessage());
        }
        return options;
    }

    @AuraEnabled(cacheable=true)
    public static TableWrapper getReviewerMappingData(String stage, String campaignId, String callYearValue, Integer pageSize, Integer pageNumber) {

        Integer offsetVal = (pageNumber - 1) * pageSize;
        DateTime startDate;
        DateTime endDate;

        List<Reviewer_Mapping__c> data = new List<Reviewer_Mapping__c>();

        // Parse callYearValue to Integer for comparison
        Integer yearValue = null;
        if(callYearValue != null && callYearValue != ''){
            try {
                yearValue = Integer.valueOf(callYearValue);
            } catch (Exception e) {
                TableWrapper emptyWrap = new TableWrapper();
                emptyWrap.reviewers = new List<String>();
                emptyWrap.rows = new List<RowData>();
                return emptyWrap;
            }
        }

        if(yearValue != null && yearValue > 2025){
            System.debug('-------------- IF : EXECUTING NEW METHOD FOR YEARS > 2025 --------------');
            System.debug('yearValue : ' + yearValue);
            // New method for years > 2025 using yearly_Call.Years__c
            List<Reviewer_Mapping__c> data2026 = [
                SELECT Id, 
                Proposals__r.Id, 
                Proposals__r.Name, 
                Proposals__r.Stage__c, 
                Reviewer__r.Name, 
                Total_Score__c 
                FROM Reviewer_Mapping__c 
                WHERE Proposals__c != null 
                AND Proposals__r.Proposal_Stages__c != 'Draft'
                AND Proposals__r.yearly_Call__r.Years__r.Name = :String.valueOf(yearValue)
                ORDER BY Proposals__r.Name 
                LIMIT :pageSize OFFSET :offsetVal
            ];
            data.addAll(data2026);
            System.debug('data in IF Block : ' + data.size());
        }
        else{
            System.debug('-------------- ELSE : EXECUTING METHOD FOR YEARS <= 2025 --------------');
            System.debug('yearValue : ' + yearValue);
            // Keep year filter behavior aligned with ReviewerReport.getProposals (parse year -> CreatedDate range).
            if (yearValue != null) {
                startDate = DateTime.newInstance(yearValue, 1, 1, 0, 0, 0);
                endDate = DateTime.newInstance(yearValue + 1, 1, 1, 0, 0, 0);
            }

            List<String> whereParts = new List<String>();
            whereParts.add('Proposals__c != null');
            whereParts.add('Proposals__r.Proposal_Stages__c != \'Draft\'');  // ADDED THIS LINE

            if (!String.isBlank(stage)) {
                whereParts.add('Proposals__r.Stage__c = :stage');
            }
            if (!String.isBlank(campaignId)) {
                whereParts.add('Proposals__r.Campaign__c = :campaignId');
            }
            if (yearValue != null) {
                whereParts.add('Proposals__r.CreatedDate >= :startDate');
                whereParts.add('Proposals__r.CreatedDate < :endDate');
            }

            String soql =
                'SELECT Id, ' +
                'Proposals__r.Id, ' +
                'Proposals__r.Name, ' +
                'Proposals__r.Stage__c, ' +
                'Reviewer__r.Name, ' +
                'Total_Score__c ' +
                'FROM Reviewer_Mapping__c ' +
                'WHERE ' + String.join(whereParts, ' AND ') + ' ' +
                'ORDER BY Proposals__r.Name ' +
                'LIMIT :pageSize OFFSET :offsetVal';

            data = Database.query(soql);
            System.debug('data in ELSE Block : ' + data.size());
        }
        // Collect unique reviewers
        Set<String> reviewerSet = new Set<String>();
        Map<Id, RowData> proposalMap = new Map<Id, RowData>();

        for (Reviewer_Mapping__c rec : data) {

            // Null checks
            if (rec.Proposals__r == null || rec.Reviewer__r == null) {
                continue;
            }

            if (rec.Reviewer__r.Name == null) {
                continue;
            }

            reviewerSet.add(rec.Reviewer__r.Name);

            if (!proposalMap.containsKey(rec.Proposals__r.Id)) {
                RowData row = new RowData();
                row.proposalId = rec.Proposals__r.Id;
                row.proposalName = rec.Proposals__r.Name;
                row.reviewerScores = new Map<String, Decimal>();
                row.avgScore = 0;
                proposalMap.put(rec.Proposals__r.Id, row);
            }

            RowData existing = proposalMap.get(rec.Proposals__r.Id);

            // Safe put
            if (rec.Total_Score__c != null) {
                existing.reviewerScores.put(rec.Reviewer__r.Name, rec.Total_Score__c);
            }
        }

        // Calculate average
        for (RowData row : proposalMap.values()) {
            Decimal total = 0;
            Integer count = 0;

            for (Decimal score : row.reviewerScores.values()) {
                total += score;
                count++;
            }

            if (count > 0) {
                row.avgScore = total / count;
            }
        }

        TableWrapper wrapper = new TableWrapper();
        List<String> reviewerList = new List<String>(reviewerSet);
        reviewerList.sort();
        wrapper.reviewers = reviewerList;
        wrapper.rows = proposalMap.values();

        return wrapper;
    }
    

    
}