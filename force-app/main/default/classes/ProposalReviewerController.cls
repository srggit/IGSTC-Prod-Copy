public with sharing class ProposalReviewerController {
    public class ReviewerWrapper {
        @AuraEnabled public Id reviewerId;
        @AuraEnabled public String reviewerName;
        @AuraEnabled public String reviewerEmail;
        @AuraEnabled public String matchedSkill;
    }
/******************Exact Matching(IN)**********************/
    // @AuraEnabled(cacheable=true)
    // public static List<ReviewerWrapper> getMatchingReviewers(Id proposalId){

    //     Application_Proposal__c proposal = [SELECT Id, KeyWords__c FROM Application_Proposal__c WHERE Id = :proposalId];
    //     if(String.isBlank(proposal.KeyWords__c)){
    //         return new List<ReviewerWrapper>();
    //     }
    //     List<String> keywords = new List<String>();
    //     for(String k : proposal.KeyWords__c.split(';')){
    //         keywords.add(k.trim());
    //     }

    //     Map<Id, ReviewerWrapper> reviewerMap = new Map<Id, ReviewerWrapper>();
    //     for(Reviewer_Skills__c rs : [SELECT Skill__c, Reviewer__r.Id,Reviewer__r.Name,Reviewer__r.Email__c FROM Reviewer_Skills__c WHERE Skill__c IN :keywords AND Reviewer__r.Active__c = true]){
    //         Id reviewerId = rs.Reviewer__r.Id;
    //         if(!reviewerMap.containsKey(reviewerId)){
    //             ReviewerWrapper rw = new ReviewerWrapper();
    //             rw.reviewerId = reviewerId;
    //             rw.reviewerName = rs.Reviewer__r.Name;
    //             rw.reviewerEmail = rs.Reviewer__r.Email__c;
    //             rw.matchedSkill = rs.Skill__c;
    //             reviewerMap.put(reviewerId, rw);
    //         }
    //         else{
    //             ReviewerWrapper existing = reviewerMap.get(reviewerId);
    //             existing.matchedSkill = existing.matchedSkill + ', ' + rs.Skill__c;
    //         }
    //     }
    //     return reviewerMap.values();
    // }

/******************Partial Matching(LIKE)**********************/
    // @AuraEnabled(cacheable=true)
    // public static List<ReviewerWrapper> getMatchingReviewers(Id proposalId){
    //     Application_Proposal__c proposal = [SELECT Id, KeyWords__c FROM Application_Proposal__c WHERE Id = :proposalId];

    //     if(String.isBlank(proposal.KeyWords__c)){
    //         return new List<ReviewerWrapper>();
    //     }
    //     // Prepare keyword list
    //     List<String> keywords = new List<String>();
    //     for(String k : proposal.KeyWords__c.split(';')){
    //         if(!String.isBlank(k)){
    //             keywords.add(k.trim());
    //         }
    //     }
    //     // Build dynamic LIKE conditions
    //     List<String> conditions = new List<String>();
    //     for(String k : keywords){
    //         conditions.add('Skill__c LIKE \'%' + String.escapeSingleQuotes(k) + '%\'');
    //     }
    //     String query = 'SELECT Skill__c, Reviewer__r.Id, Reviewer__r.Name, Reviewer__r.Email__c ' +'FROM Reviewer_Skills__c ' +'WHERE Reviewer__r.Active__c = true AND (' +String.join(conditions, ' OR ') + ')';
    //     List<Reviewer_Skills__c> skillResults = Database.query(query);

    //     // Map reviewers and merge skills
    //     Map<Id, ReviewerWrapper> reviewerMap = new Map<Id, ReviewerWrapper>();
    //     for(Reviewer_Skills__c rs : skillResults){
    //         Id reviewerId = rs.Reviewer__r.Id;
    //         if(!reviewerMap.containsKey(reviewerId)){
    //             ReviewerWrapper rw = new ReviewerWrapper();
    //             rw.reviewerId = reviewerId;
    //             rw.reviewerName = rs.Reviewer__r.Name;
    //             rw.reviewerEmail = rs.Reviewer__r.Email__c;
    //             rw.matchedSkill = rs.Skill__c;

    //             reviewerMap.put(reviewerId, rw);
    //         }
    //         else{
    //             ReviewerWrapper existing = reviewerMap.get(reviewerId);
    //             if(!existing.matchedSkill.contains(rs.Skill__c)){
    //                 existing.matchedSkill += ', ' + rs.Skill__c;
    //             }
    //         }
    //     }
    //     return reviewerMap.values();
    // }

/******************Contains**********************/
    @AuraEnabled(cacheable=true)
    public static List<ReviewerWrapper> getMatchingReviewers(Id proposalId){

        Application_Proposal__c proposal = [SELECT Id, KeyWords__c FROM Application_Proposal__c WHERE Id = :proposalId];
        if(String.isBlank(proposal.KeyWords__c)){
            return new List<ReviewerWrapper>();
        }
        String keywordText = proposal.KeyWords__c.toLowerCase();
        Map<Id, ReviewerWrapper> reviewerMap = new Map<Id, ReviewerWrapper>();
        List<Reviewer_Skills__c> skills = [SELECT Skill__c,Reviewer__r.Id,Reviewer__r.Name,Reviewer__r.Email__c FROM Reviewer_Skills__c WHERE Reviewer__r.Active__c = true];

        for(Reviewer_Skills__c rs : skills){
            if(keywordText.contains(rs.Skill__c.toLowerCase())){
                Id reviewerId = rs.Reviewer__r.Id;

                if(!reviewerMap.containsKey(reviewerId)){
                    ReviewerWrapper rw = new ReviewerWrapper();
                    rw.reviewerId = reviewerId;
                    rw.reviewerName = rs.Reviewer__r.Name;
                    rw.reviewerEmail = rs.Reviewer__r.Email__c;
                    rw.matchedSkill = rs.Skill__c;

                    reviewerMap.put(reviewerId, rw);
                }
                else{
                    ReviewerWrapper existing = reviewerMap.get(reviewerId);
                    existing.matchedSkill += ', ' + rs.Skill__c;
                }
            }
        }
        return reviewerMap.values();
    }
    
    // @AuraEnabled
    // public static void createReviewerMapping(Id proposalId, Id reviewerId){
    //     Reviewer_Mapping__c mapping = new Reviewer_Mapping__c( Proposals__c = proposalId,Reviewer__c = reviewerId);
    //     insert mapping;
    // }

    @AuraEnabled
    public static void createReviewerMapping(Id proposalId, List<Id> reviewerIds){
        List<Reviewer_Mapping__c> mappings = new List<Reviewer_Mapping__c>();
        for(Id reviewerId : reviewerIds){
            mappings.add(new Reviewer_Mapping__c(Proposals__c = proposalId,Reviewer__c = reviewerId));
        }
        if(!mappings.isEmpty()){
            insert mappings;
        }
    }
}