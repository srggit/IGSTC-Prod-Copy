public without sharing class WorkshopController2 {
    
    public string tabValues  {get;set;}
    public string thematicAreaList {get;set;}
    public string countrytype  {get;set;}
    public string countryCode  {get;set;}
    public string availingFellowship  {get;set;}
    public string pairedApplicant  {get;set;}
    public string participantType {get;set;}
    public string bankType {get;set;}
    public string participatingWorkshop {get;set;}
    // public string degree  {get;set;}
    public string specialization  {get;set;}
     
    public string presentingWorkshop  {get;set;} 
    public string currencyType2  {get;set;} 
    public string stage  {get;set;}
    public String ApplicantPortalSiteURL {get;set;}
    public string secondstage  {get;set;}
    public string emailVerified  {get;set;}
    public string proposalStage  {get;set;}
    public String candidateId {get;set;}
    public string campaigntype {get;set;}
    public string contactId {get;set;}
    public string financialConDetails {get;set;}
    public string gender {get;set;}
    public string nationality {get;set;}
    public string country {get;set;}
    public string available_followship {get;set;}
    public string associated_with_igstc {get;set;}
    // public String nature_of_Job{get;set;}
    public String expanseHead {get;set;}
    public String applicantName {get;set;}
    public String applicantEmail {get;set;}
    public boolean isPrimaryContact {get;set;}
    public boolean isCoordinator {get;set;}
    public string accountId {get;set;}
    public String projectId {get;set;}
    public string natureOfThesisWork {get;set;}
    public string natureOfPhDWork {get;set;}
    public string percentCGPA {get;set;}
    public string states {get;set;}
    public Date signDate {get;set;}
    public string campaignData {get;set;}
    public string currencyPickList  {get;set;}
    public Boolean partnerSubmission {get;set;}
    public List<proposalWrap> proposalWrapperList {get;set;}
    
    public WorkshopController2() {
        ApplicantPortalSiteURL = Constants.CANDIDATE_SITE ;
        list<Application_Portal_Tabs__c> cdTabs = [select name,Tab_Label__c,id,Controller_Name__c,Display_Order__c from Application_Portal_Tabs__c ORDER BY Display_Order__c];
        tabValues = JSON.serialize(cdTabs);
        thematicAreaList = JSON.serialize(fetchAllThematicArea());
        countrytype = JSON.serialize(Utility.getPicklistValues('Account' , 'Country_Type__c'));
        countryCode = JSON.serialize(Utility.getPicklistValues('Contact' , 'Country_Code__c'));
        natureOfThesisWork = JSON.serialize(Utility.getPicklistValues('Education_Details__c' , 'Nature_of_Thesis_Work__c'));
        natureOfPhDWork = JSON.serialize(Utility.getPicklistValues('Education_Details__c' , 'Nature_of_PhD_Work__c'));
        currencyType2 = JSON.serialize(Utility.getPicklistValues('Expense_Line_Item__c' , 'Currency_Type2__c'));
        availingFellowship = JSON.serialize(Utility.getPicklistValues('Application_Proposal__c' , 'Availing_any_other_fellowship_currently__c'));
        pairedApplicant = JSON.serialize(Utility.getPicklistValues('Application_Proposal__c' , 'Paired_Applicant_associated_with_IGSTC__c'));
        participantType = JSON.serialize(Utility.getPicklistValues('Participants__c' , 'Participant_Type__c'));
        bankType = JSON.serialize(Utility.getPicklistValues('Bank_Details__c' , 'Bank_Type__c'));
        participatingWorkshop = JSON.serialize(Utility.getPicklistValues('Participants__c' , 'Whether_Participant_is_presenting__c'));
        // degree = JSON.serialize(Utility.getPicklistValues('Education_Details__c' , 'Degree__c'));
        specialization = JSON.serialize(Utility.getPicklistValues('Education_Details__c' , 'Specialization__c'));
        percentCGPA = JSON.serialize(Utility.getPicklistValues('Education_Details__c' , 'Percentage_cgpa__c'));
        states = JSON.serialize(Utility.getPicklistValues('Contact' , 'States__c'));
        presentingWorkshop = JSON.serialize(Utility.getPicklistValues('Contact' , 'Presenting_Workshop__c'));
        financialConDetails = JSON.serialize([SELECT German_Academia__c,German_Institute__c,Indian__c,Indian_Institute__c FROM Financial_Overview_Conditions__c limit 1]);
        campaignData=JSON.serialize([SELECT Id,Name,Description,EndDate,Image_URL__c,RedirectPage__c,(select name,id from Attachments order by createdDate DESC),(SELECT Id,Campaign__c,Name,Description__c FROM Campaign_Guidlines__r) FROM Campaign]);
        stage = JSON.serialize(Utility.getPicklistValues('Application_Proposal__c' , 'Stage__c'));
        String rawId = ApexPages.currentPage().getParameters().get('id');
        if (String.isNotBlank(rawId)) {  
            Integer slashIndex = rawId.indexOf('/');
            candidateId = (slashIndex > -1) ? rawId.substring(0, slashIndex) : rawId;
        }
        gender = JSON.serialize(Utility.getPicklistValues('Contact' , 'Gender__c'));
        nationality = JSON.serialize(Utility.getPicklistValues('Contact' , 'Nationality__c'));
        country = JSON.serialize(Utility.getPicklistValues('Contact' , 'Country__c'));
        available_followship = JSON.serialize(Utility.getPicklistValues('Contact' , 'Availing_Fellowship__c'));
        available_followship = JSON.serialize(Utility.getPicklistValues('Contact' , 'Associated_with_IGSTC__c'));
        // nature_of_Job = JSON.serialize(Utility.getPicklistValues('Employment_Details__c' , 'Nature_of_Job__c'));
        expanseHead = JSON.serialize(Utility.getPicklistValues('Financial_Contribution__c' , 'Expanse_Head__c'));
        currencyPickList = JSON.serialize(Utility.getPicklistValues('Existing_Grants__c' , 'Currency__c'));
        signDate = System.today();
        system.debug('candidateId---'+candidateId);
        if(!string.isBlank(candidateId)){
            List<contact> applicantDetails = [SELECT Id,Email,Status__c,account.Is_Coordinator__c,name,Account.Id,Proposals__c,Proposals__r.Campaign__r.Name,Email_Verified__c,Is_Primary__c,Campaign__c,Login_Hash_Code__c,(SELECT Id, Proposals__r.Id, Proposals__r.Stage__c, Proposals__r.Proposal_Stages__c FROM Applicant_Proposal_Associations__r) FROM contact WHERE Login_hash_code__c =:candidateId];
            for(Contact conRec : applicantDetails){
                emailVerified = String.valueOf(conRec.Email_Verified__c);
            }
            // if(!string.isBlank(applicantDetails[0].Proposals__c)){
            //     Application_Proposal__c proposal = [SELECT Id,Name,Stage__c,Proposal_Stages__c FROM Application_Proposal__c where Id =: applicantDetails[0].Proposals__c];
            //     secondstage = proposal.stage__c;
            //     proposalStage = proposal.Proposal_Stages__c;
            // }
            proposalWrapperList = new List<proposalWrap>();

            if(!applicantDetails[0].Applicant_Proposal_Associations__r.isEmpty()){
                for(Applicant_Proposal_Association__c apa : applicantDetails[0].Applicant_Proposal_Associations__r) {
                    proposalWrap wrap = new proposalWrap();
                    wrap.apaId = apa.Id;
                    wrap.Id = apa.Proposals__r.Id;
                    wrap.proposalStage = apa.Proposals__r.Proposal_Stages__c;
                    // secondStage = apa.Proposals__r.Stage__c=='2nd Stage' ?'true':'false';
                    // System.debug('secondStage : -------- ' + secondStage);
                    proposalStage= apa.Proposals__r.Proposal_Stages__c;
                    System.debug('Stage = ' + proposalStage);
                    wrap.stage = apa.Proposals__r.Stage__c;
                    wrap.secondStage = (apa.Proposals__r.Stage__c == '2nd Stage');
                    proposalWrapperList.add(wrap);
                }
            }
            
            if(applicantDetails.size() >0){
                contactId = applicantDetails[0].Id;
                projectId = applicantDetails[0].Proposals__c;
                campaigntype = applicantDetails[0].Campaign__c;
                applicantName=applicantDetails[0].Name;
                applicantEmail=applicantDetails[0].Email;
                isPrimaryContact=applicantDetails[0].Is_Primary__c;
                accountId=applicantDetails[0].Account.Id;
                isCoordinator=applicantDetails[0].Account.Is_Coordinator__c;
                if(applicantDetails[0].Status__c == 'Submitted'){
                    partnerSubmission = true;
                }else {
                    partnerSubmission = false;
                }
                
            }
        }
    }
    
    public class proposalWrap {
        public String Id {get; set;}
        public String stage {get; set;}
        public String proposalStage {get; set;}
        public Boolean secondStage {get;set;}
        public String apaId {get;set;}
    }
    
    @RemoteAction
    public static List<Thematic_Area__c> fetchAllThematicArea(){
        return Proposal_Controller.fetchAllThematicArea();
        
    }
    
    // =================================== Coordinators_Page ===================================
    @RemoteAction
    public static List<Account> getPatnerDetails3(String applicantHashCode, String proposalId, String apaId){
        System.debug('======================== getPatnerDetails3() ===========================');
        System.debug('applicantHashCode : ' + applicantHashCode);
        System.debug('proposalId : ' + proposalId);
    
        String workshopRecordTypeId = Schema.SObjectType.Application_Proposal__c
            .getRecordTypeInfosByName()
            .get('Workshop')
            .getRecordTypeId();
        System.debug('workshopRecordTypeId : ' + workshopRecordTypeId);
    
        //CASE 1: USING PROPOSAL ID
        List<String> proposalIds = new List<String>();
        proposalIds.add(proposalId);
        System.debug('proposalIds : ' + proposalIds);

        if(proposalId != null && proposalId != ''){
            
            List<Applicant_Proposal_Association__c> apaListForPropsals = [
                SELECT Id, Name, Proposals__c, Contact__c, Proposals__r.RecordTypeId
                FROM Applicant_Proposal_Association__c
                WHERE Proposals__c = :proposalIds
                //AND Proposals__r.RecordTypeId = :workshopRecordTypeId
            ];
    
            Set<Id> contactIdSet = new Set<Id>();
            for(Applicant_Proposal_Association__c apa : apaListForPropsals){
                if(apa.Contact__c != null){
                    contactIdSet.add(apa.Contact__c);
                }
            }
    
            if(contactIdSet.isEmpty()){
                return new List<Account>();
            }
    
            List<Contact> lstContacts = [
                SELECT Id, AccountId
                FROM Contact
                WHERE Id IN :contactIdSet
            ];
    
            Set<Id> accountIdSet = new Set<Id>();
            for(Contact con : lstContacts){
                if(con.AccountId != null){
                    accountIdSet.add(con.AccountId);
                }
            }
    
            if(accountIdSet.isEmpty()){
                return new List<Account>();
            }
    
            return [
                SELECT Name, Id, Homepage_URL__c, Country_Type__c, Academia__c,
                       BillingStreet, BillingCity, BillingState, BillingPostalCode,
                       BillingCountry, Department__c, Industry__c,
                       (SELECT Salutation,Title, Name, FirstName, Id, LastName, Email, Phone, Department
                        FROM Contacts ORDER BY CreatedDate ASC)
                FROM Account
                WHERE Id IN :accountIdSet
                order by CreatedDate ASC
            ];
        }
    
        //CASE 2: USING HASHCODE
        else if(String.isNotBlank(applicantHashCode)){
    
            List<Contact> conList = [
                SELECT Id, AccountId
                FROM Contact
                WHERE Login_Hash_Code__c = :applicantHashCode
                LIMIT 1
            ];
    
            if(conList.isEmpty()){
                return new List<Account>();
            }
    
            Contact conRec = conList[0];
    
            if(conRec.AccountId == null){
                return new List<Account>();
            }
    
            return [
                SELECT Name, Id, Homepage_URL__c, Country_Type__c, Academia__c,
                       BillingStreet, BillingCity, BillingState, BillingPostalCode,
                       BillingCountry, Department__c, Industry__c,
                       (SELECT Salutation,Title, Name, FirstName, Id, LastName, Email, Phone, Department
                        FROM Contacts ORDER BY CreatedDate ASC)
                FROM Account
                WHERE Id = :conRec.AccountId
                ORDER BY CreatedDate ASC
            ];
        }
    
        return new List<Account>();
    }
    

    @RemoteAction
    public static Contact getcampaigntype(string hashcode){
        try{
            Contact conrec = [SELECT Id,Name,Campaign__c,Is_Primary__c from Contact where Login_Hash_Code__c=: hashcode];
            return conrec;
        }catch(exception e){
            return null;
        }
    }

    public String validFor; 
    
    @RemoteAction
    public static Map<String, List<String>> getFieldDependencies(String objectName, String controllingField, String dependentField){
        System.debug(' ============================ getFieldDependencies ==================================');
        Map<String, List<String>> controllingInfo = new Map<String, List<String>>();
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        System.debug(' objType : ' + objType);
        
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();
        
        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
        
        for(Schema.PicklistEntry currControllingValue : controllingValues)
        {
            System.debug('ControllingField: Label:' + currControllingValue.getLabel());
            controllingInfo.put(currControllingValue.getLabel(), new List<String>());
        }
        
        for(Schema.PicklistEntry currDependentValue : dependentValues){
            String jsonString = JSON.serialize(currDependentValue);
            
            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);
            
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
            
            System.debug('DependentField: Label:' + currDependentValue.getLabel() + ' ValidForInHex:' + hexString + ' JsonString:' + jsonString);
            
            Integer baseCount = 0;
            
            for(Integer curr : hexString.getChars())
            {
                Integer val = 0;
                
                if(curr >= 65)
                {
                    val = curr - 65 + 10;
                }
                else
                {
                    val = curr - 48;
                }
                
                if((val & 8) == 8)
                {
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 0].getLabel());
                    controllingInfo.get(controllingValues[baseCount + 0].getLabel()).add(currDependentValue.getLabel());
                }
                if((val & 4) == 4)
                {
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 1].getLabel());
                    controllingInfo.get(controllingValues[baseCount + 1].getLabel()).add(currDependentValue.getLabel());                    
                }
                if((val & 2) == 2)
                {
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 2].getLabel());
                    controllingInfo.get(controllingValues[baseCount + 2].getLabel()).add(currDependentValue.getLabel());                    
                }
                if((val & 1) == 1)
                {
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 3].getLabel());
                    controllingInfo.get(controllingValues[baseCount + 3].getLabel()).add(currDependentValue.getLabel());                    
                }
                
                baseCount += 4;
            }            
        } 
        System.debug('ControllingInfo: ' + controllingInfo);
        
        return controllingInfo;
    }
    
    class MyPickListInfo {
        public String active {get; set;}
        public String defaultValue {get; set;}
        public String label {get; set;}
        public String value {get; set;}
        public String validFor {get; set;}
    }

    public class insertApplicationWrapper {
        public String proposalId { get; set; }
        public Application_Proposal__c proposal { get; set; }
        public Applicant_Proposal_Association__c apa { get; set; }
        // Consider adding error fields if needed
        // public Boolean isSuccess { get; set; }
        // public String errorMessage { get; set; }
    }

    @RemoteAction
    public static insertApplicationWrapper insertCoordinatorsInformation2(
        List<Account> accList,
        List<Contact> conList,
        String proposalId,
        String yearlyCallId
    ){
        insertApplicationWrapper datawrapper = new insertApplicationWrapper();
        
        try {
            System.debug('------------------ insertCoordinatorsInformation2 --------------------');
            System.debug('accList : ' + accList);

            List<Id> conIds = new List<Id>();
            Applicant_Proposal_Association__c primaryAPA;
            Application_Proposal__c proposalRec;
 
            // ---------------- ACCOUNT UPSERT ----------------
            Map<String,String> accMap = new Map<String,String>();
 
            for(Account accRecord : accList){

                if(accRecord.Is_Coordinator__c){
                    accRecord.BillingState = accRecord.BillingState;
                }
                accMap.put(accRecord.Name, '');
            }
            upsert accList;
 
            for(Account acc : accList){
                accMap.put(acc.Name, acc.Id);
            }
 
            // ---------------- CONTACT UPSERT ----------------
            for(Contact conRecord : conList){
                conRecord.Proposals__c = null;
                conIds.add(conRecord.Id);
 
                if(String.isBlank(conRecord.LastName)){
                    conRecord.LastName = conRecord.FirstName;
                }
                if(accMap.containsKey(conRecord.AccountId)){
                    conRecord.AccountId = accMap.get(conRecord.AccountId);
                }
            }
            upsert conList;
 
            // =================================================
            // CASE 1: PROPOSAL EXISTS
            // =================================================
            if(!String.isBlank(proposalId)){
 
                proposalRec = [
                    SELECT Id
                    FROM Application_Proposal__c
                    WHERE Id = :proposalId
                    LIMIT 1
                ];
 
                // Find Primary APA (using APA.Is_Coordinator__c)
                for(Applicant_Proposal_Association__c apa : [
                    SELECT Id, Contact__c, Is_Coordinator__c
                    FROM Applicant_Proposal_Association__c
                    WHERE Proposals__c = :proposalId
                    AND Contact__c IN :conIds
                ]){
                    if(apa.Is_Coordinator__c == true){
                        primaryAPA = apa;
                        break;
                    }
                }
            }
            // =================================================
            // CASE 2: PROPOSAL DOES NOT EXIST
            // =================================================
            else{
 
                String workshopRecordTypeId = Schema.SObjectType.Application_Proposal__c
                    .getRecordTypeInfosByName()
                    .get('Workshop')
                    .getRecordTypeId();
 
                Campaign camp = [
                    SELECT Id
                    FROM Campaign
                    WHERE Name = 'Workshop'
                    LIMIT 1
                ];
 
                proposalRec = new Application_Proposal__c(
                    Proposal_Stages__c='Draft',
                    RecordTypeId = workshopRecordTypeId,
                    Campaign__c = camp.Id,
                    yearly_Call__c = yearlyCallId
                );
                insert proposalRec;
 
                List<Applicant_Proposal_Association__c> apaList = new List<Applicant_Proposal_Association__c>();
                Integer idx = 0;
                for(Contact c : conList){
                    Applicant_Proposal_Association__c apa = new Applicant_Proposal_Association__c(
                        Contact__c = c.Id,
                        Proposals__c = proposalRec.Id
                    );
                    apa.Is_Coordinator__c = (idx == 0);
                    apaList.add(apa);
                    if (idx == 0) primaryAPA = apa;
                    idx++;
                }
                insert apaList;
            }
 
            // ---------------- WRAPPER RESPONSE ----------------
            datawrapper.proposalId = proposalRec.Id;
            datawrapper.proposal   = proposalRec;
            datawrapper.apa        = primaryAPA;
 
            return datawrapper;
 
        } catch(Exception e){
            throw new AuraHandledException(
                e.getMessage() + ' @ line ' + e.getLineNumber()
            );
        }
    }


    // =================================== BasicDetails_Page =================================== //
    @RemoteAction
    public static Application_Proposal__c getBasicDetails(String proposalId){
        System.debug('-------------------- getBasicDetails() ---------------------');
        System.debug('proposalId : ' + proposalId);
        
        if(String.isBlank(proposalId)){
            return new Application_Proposal__c();
        }
        
        Map<String, Schema.RecordTypeInfo> rtMap =
            Schema.SObjectType.Application_Proposal__c.getRecordTypeInfosByName();
            
        if(!rtMap.containsKey('Workshop')){
            System.debug('Workshop RecordType not found');
            return new Application_Proposal__c();
        }
        
        String workshopRecordTypeId = rtMap.get('Workshop').getRecordTypeId();
        System.debug('workshopRecordTypeId : ' + workshopRecordTypeId);
        
        List<Application_Proposal__c> proposalList = [
            SELECT Id, Name, Acronym__c, Country_of_Venue__c, Thematic_Area__c, Campaign__c, 
                Title_Of__c, Title_In_German__c, Summary__c, Proposed_Venue__c, Proposed_Date__c, Workshop_Finish_Date__c, 
                Campaign__r.Result_Announcement_Date__c, RecordType_Name__c
            FROM Application_Proposal__c 
            WHERE Id = :proposalId
            AND RecordTypeId = :workshopRecordTypeId
            LIMIT 1
        ];
        
        if(proposalList.isEmpty()){
            return new Application_Proposal__c();
        }
        
        return proposalList[0];
    }

    @RemoteAction
    public static String insertBasicDetails2 (
        Application_Proposal__c applicantDetails,
        Integer day, Integer month, Integer year,
        Integer endday, Integer emdmonth, Integer endyear,
        String conId, String proposalId, String recordType
    ){
        System.debug('--------------- EXECUTING insertBasicDetails2() ------------------');
        System.debug('Incoming applicantDetails : ' + applicantDetails);
        
        if(String.isBlank(conId)){
            return 'ERROR: Contact Id missing';
        }
        
        if(String.isBlank(proposalId)){
            return 'ERROR: ProposalId Id missing';
        }
        
        if(day==0 && month==0 && year==0){
            // Skip
        }else{
            applicantDetails.Proposed_Date__c = Date.newInstance(year, month, day);
        }
        
        if(endday==0 && emdmonth==0 && endyear==0){
            // Skip
        }else{
            applicantDetails.Workshop_Finish_Date__c = Date.newInstance(endyear, emdmonth, endday);
        }
        
        applicantDetails.Id = proposalId;       
        
        update applicantDetails;
        
        System.debug('Updated Proposal : ' + applicantDetails);
        
        return 'SUCCESS';
    }

    // =================================== Proposal_Details =================================== //

    @RemoteAction
    public static Application_Proposal__c getProjectdetils(String proposalId){
        System.debug('-------------- getProjectdetils() ------------------');
        
        if(String.isBlank(proposalId))
            return new Application_Proposal__c();
        
        String workshopRecordTypeId = Schema.SObjectType.Application_Proposal__c.getRecordTypeInfosByName().get('Workshop').getRecordTypeId();
        System.debug('workshopRecordTypeId : ' + workshopRecordTypeId);
        
        Application_Proposal__c proposalRecord = [
            SELECT Name,id,Research_Approach_Objectives__c,Current_State_Of_The_Art__c,Project_Description__c,Expected_Deliverables__c,Equipment__c, RecordTypeId,
                Reasons_For_And_Benefits_Of_Cooperation__c,Criteria_For_Abandoning_The_Project__c,Innovative_Aspects__c,Research_Scholars__c,
                Necessity_Of_Funding__c,Background_Concept_Purpose__c,Specific_Need_For_the_Bilateral_Event__c,Privacy_Policy_Accepted__c,
                Basis_for_choosing_the_pairing_fellow__c,Tentative_plans_for_networking__c,Tentative_Start_Date__c,Tentative_End_Date__c,Availing_any_other_fellowship_currently__c,
                Availing_Other_Fellowship_Detail__c,Paired_Applicant_associated_with_IGSTC__c,Applicant_associated_with_IGSTC_Detail__c
            FROM Application_Proposal__c 
            WHERE Id = :proposalId
            // AND RecordTypeId = :workshopRecordTypeId
        ];
        System.debug('proposalRecord : ' + proposalRecord);
        
        return proposalRecord;
    }

    @RemoteAction
    public static String insertProjectDetails(Application_Proposal__c proposalDetails){
        try{
            System.debug('-------------- insertProjectDetails() ------------------');
            System.debug('proposalDetails : ' + proposalDetails);

            upsert proposalDetails;
            return 'Success';
        }catch(Exception e){
            return e.getMessage()+e.getLineNumber();
        }
    }

    // =================================== Participants =================================== //

    // NEW METHOD FOR WORKSHOP - TO GET EXISTING PROPOSAL DETAILS USING PROPOSALID
    @RemoteAction
    public static List<Participants__c> getParticipantDetails(String proposalId){
        System.debug('----------------------- getParticipantDetails() ---------------------------');
        
        if(String.isBlank(proposalId))
            return new List<Participants__c>();
        
        List<Participants__c> participantList = [
            SELECT Id, Name, Affiliation__c, Email__c, Organisation_Institute__c, Designation__c, 
                Participant_Type__c, Phone__c, Whether_Participant_is_presenting__c,
                Proposals__c
            FROM Participants__c
            WHERE Proposals__c = :proposalId
        ];
        System.debug('participantList : ' + participantList);
        
        return participantList;
    }

    // NEW METHOD FOR WORKSHOP - TO TAG PROPOSAL TO PARTICIPANTS USING PROPOSALID
    @RemoteAction
    public static String insertParticipants(List<Participants__c> allParticipantDetails, String proposalId){
        try{
            System.debug('----------------- insertParticipants() -------------------');
            
            System.debug('allParticipantDetails list : ' + allParticipantDetails);
            System.debug('proposalId : ' + proposalId);
            
            if(! allParticipantDetails.isEmpty()){
                for(Participants__c p : allParticipantDetails){
                    p.Proposals__c = proposalId;
                }
            }
            upsert allParticipantDetails;
            System.debug('------ PARTICIPANTS DATA INSERTED SUCCESSFULLY !!');
            return 'SUCCESS';
        }catch(Exception e){
            System.debug('The Error is  :'+e.getMessage());
            return e.getMessage() + e.getLineNumber();
        }
    } 

    // NEW METHOD FOR WORKSHOP - TO DELETE PARTICIPANTS USING PARTICIPANTID
    @RemoteAction
    public static String deleteParticipant(String participantId){
        try{
            System.debug('----------------- deleteParticipant() -------------------');
            System.debug('participantId : ' + participantId);
            
            delete new Participants__c(Id = participantId);
            System.debug('------ PARTICIPANT DATA DELETED SUCCESSFULLY !!');
            return 'Success';
        }catch(Exception e){
            System.debug('The Error is  :'+e.getMessage());
            return e.getMessage() + e.getLineNumber();
        }
    }

    // =================================== Financial_Details =================================== //
    @RemoteAction
    public static List<Expense_Head__c> getExpenseFromProposal(String proposalId){
        try{
            List<Expense_Head__c> expensehead = [
                SELECT Id,Name,Proposals__r.Total_funding_requested_from_IGSTC__c,Proposals__r.Country_of_Venue__c,
                    Proposals__r.Funding_from_other_sources_own_contrib__c,
                    (SELECT Id,Name,Expense_Head__c,Multiplier__c,Total_Expense__c,Total_ELI_Sum__c,Unit_Price__c,
                        Description__c,Currency_Type2__c From Expense_Line_Items__r) 
                        FROM Expense_Head__c 
                WHERE Proposals__c =: proposalId];
            System.debug('expensehead : ' + expensehead);
            return expensehead;
            
        }catch(Exception e){
            return null;
        }
    }

    @RemoteAction
    public static String saveExpenseDetails(List<Expense_Line_Item__c> listOfLineItem, Application_Proposal__c appRecord){
        try{
            System.debug('----------------- saveExpenseDetails() -------------------');
            System.debug('listOfLineItem : ' + listOfLineItem);
            System.debug('appRecord : ' + appRecord);
            
            appRecord.Total_funding_requested_from_IGSTC__c = String.valueOf(appRecord.Total_funding_requested_from_IGSTC__c);
            appRecord.Funding_from_other_sources_own_contrib__c = String.valueOf(appRecord.Funding_from_other_sources_own_contrib__c);
            upsert appRecord;
            upsert listOfLineItem;
            System.debug('------ EXPENSE DETAILS DATA INSERTED SUCCESSFULLY !!');
            return 'Success';
        }
        catch(Exception e){
            System.debug('The Error is  :'+e.getMessage());
            return e.getMessage() + e.getLineNumber();
        }
    }

    @RemoteAction
    public static String deleteExpenseLineItems(String lineItemId){
        try{
            System.debug('----------------- deleteExpenseLineItems() -------------------');
            System.debug('lineItemId : ' + lineItemId);
            
            delete new Expense_Line_Item__c(id=lineItemId);
            System.debug('------ EXPENSE LINE ITEM DATA DELETED SUCCESSFULLY !!');
            return 'Success';
        }catch(Exception e){
            System.debug('The Error is  :'+e.getMessage());
            return e.getMessage() + e.getLineNumber();
        }
    }

    // =================================== Curriculum_vitae =================================== //

    @RemoteAction
    public static List<Contact> checkEmail(String email, String contId) {
        List<Contact> conRec = new List<Contact>();
        try {
            if (String.isBlank(email)) {
                return conRec;
            }
            
            if (String.isNotBlank(contId)) {
                conRec = [
                    SELECT Id, FirstName, LastName, Email, Birthdate, MailingCountry, Account.Name, Nationality__c, 
                        Account_BillingCity__c, AccountName__c, Institution__c, Designation__c, Account.BillingStreet, 
                        Account.BillingCity, Account.BillingState, Account.BillingCountry, Account.BillingPostalCode, 
                        MobilePhone
                    FROM Contact
                    WHERE Email = :email
                    AND Id != :contId
                ];
            } else {
                conRec = [
                    SELECT Id, FirstName, LastName, Email, Birthdate, MailingCountry, Account.Name, Nationality__c, 
                        Account_BillingCity__c, AccountName__c, Institution__c, Designation__c, Account.BillingStreet, 
                        Account.BillingCity, Account.BillingState, Account.BillingCountry, Account.BillingPostalCode, 
                        MobilePhone
                    FROM Contact
                    WHERE Email = :email
                ];
            }
            return conRec;
        } catch (Exception e) {
            return new List<Contact>(); // never return null
        }
    }

    @RemoteAction
    public static void deleteEducationWorkshop(String eduId){
        delete new Education_Details__c(Id = eduId);
    }

    @RemoteAction
    public static void deleteEmploymentWorkshop(String empId){
        delete new Employment_Details__c(Id = empId);
    }

    @RemoteAction
    public static List<Contact> getCoordCVDetails(String hashCode, String apaId, String proposalId){
        try{
            System.debug('--------------- getCoordCVDetails() ---------------');

            List<Applicant_Proposal_Association__c> apaList = [
                SELECT Id, Contact__c
                FROM Applicant_Proposal_Association__c
                WHERE Proposals__c = :proposalId
            ];

            Set<Id> contactIdSet = new Set<Id>();
            Set<Id> apaIdSet = new Set<Id>();

            for(Applicant_Proposal_Association__c apa : apaList){
                contactIdSet.add(apa.Contact__c);
                apaIdSet.add(apa.Id);
            }
            System.debug('contactIdSet : -------> ' + contactIdSet);
            System.debug('apaIdSet : -------> ' + apaIdSet);

            List<Contact> conList = [
                SELECT Id,Name,FirstName,LastName,Is_Primary__c,Email,Actual_Position__c,MailingStreet,MailingCity,MailingState,MailingCountry,MailingPostalCode,Country__c,States__c,Account.Name,Publications_Patents__c,
                Account.BillingCountry,(select Id,Is_Coordinator__c from Applicant_Proposal_Associations__r where Proposals__c =:proposalId),
                (SELECT Name, Contact__c, Degree__c,Start_Year__c,End_Year__c,CGPA__c,End_Date__c,Start_Date__c,Institution_Name__c,Area_of_specialization__c,Percentage__c,Percentage_cgpa__c, Applicant_Proposal_Association__c FROM Education_Details__r WHERE Applicant_Proposal_Association__c IN :apaIdSet ORDER BY End_Year__c DESC),
                (SELECT Id, Contact__c, Organization_Name__c,Position__c,Start_Year__c,End_Year__c, Applicant_Proposal_Association__c FROM Employment_Details__r WHERE Applicant_Proposal_Association__c IN :apaIdSet ORDER BY End_Year__c DESC)
            FROM Contact 
            WHERE Id IN : contactIdSet];

            System.debug('conList size : ' + conList.size());
            System.debug('conList : ' + conList);

            /*
            Set<Id> apaIdSet = new Set<Id>();
            // for(Applicant_Proposal_Association__c apa  : apaListFromJs){
            //     apaIdSet.add(apa.Id);
            // }

            List<Applicant_Proposal_Association__c> apaList = [
                SELECT Id, Contact__c, Proposals__c FROM Applicant_Proposal_Association__c WHERE Proposals__c = :proposalId
            ];
            System.debug('apaList : ' + apaList);

            Set<Id> contactIdSet = new Set<Id>();
            for(Applicant_Proposal_Association__c apa : apaList){
                contactIdSet.add(apa.Contact__c);
                apaIdSet.add(apa.Id);
            }
            System.debug('contactIdSet : -------> ' + contactIdSet);

            List<Contact> conList = [
                SELECT Id,Name,FirstName,LastName,Is_Primary__c,Email,Actual_Position__c,MailingStreet,MailingCity,MailingState,MailingCountry,MailingPostalCode,Country__c,States__c,Account.Name,Publications_Patents__c,
                Account.BillingCountry,
                (SELECT Name,Degree__c,Start_Year__c,End_Year__c,CGPA__c,End_Date__c,Start_Date__c,Institution_Name__c,Area_of_specialization__c,Percentage__c,Percentage_cgpa__c, Applicant_Proposal_Association__c FROM Education_Details__r WHERE Applicant_Proposal_Association__c IN :apaIdSet ORDER BY End_Year__c DESC),
                (SELECT Id,Organization_Name__c,Position__c,Start_Year__c,End_Year__c, Applicant_Proposal_Association__c FROM Employment_Details__r WHERE Applicant_Proposal_Association__c IN :apaIdSet ORDER BY End_Year__c DESC)
            FROM Contact 
            WHERE Id IN : contactIdSet];

            System.debug('conList size : ' + conList.size());
            System.debug('conList : ' + conList);
            */

            return conList;
        }
        catch(Exception e){
            return null;
        }
    }

    @RemoteAction
    public static String SaveWorkshopContactDetails2(Contact conDataList, List<Education_Details__c> eduDetails, List<Employment_Details__c> empDetails){
        try{
            conDataList.MailingState = conDataList.State__c; //Added by Aman on 29 Aug'23. Put back the value of MailingState from State__c and see if it retains the value.
            upsert conDataList;
            upsert eduDetails;
            upsert empDetails;
            return 'success';
        }catch(Exception e){
            return e.getMessage();
        }
    }

    @RemoteAction
    public static String SaveWorkshopContactDetails(List<Contact> conDataList, List<Education_Details__c> eduDetails, List<Employment_Details__c> empDetails, String apaId, String proposalId){
        try{

            for(Contact con : conDataList){
                con.MailingState = con.State__c;
            }
            upsert conDataList;

            Map<Id, Applicant_Proposal_Association__c> contactIdWithAPA = new Map<Id, Applicant_Proposal_Association__c>();

            List<Applicant_Proposal_Association__c> apaList = [
                SELECT Id, Contact__c
                FROM Applicant_Proposal_Association__c
                WHERE Proposals__c = :proposalId
            ];

            for(Applicant_Proposal_Association__c apa : apaList){
                contactIdWithAPA.put(apa.Contact__c, apa);
            }

            if(! eduDetails.isEmpty()){
                for(Education_Details__c edu : eduDetails){
                    edu.Applicant_Proposal_Association__c = contactIdWithAPA.get(edu.Contact__c) != null ? contactIdWithAPA.get(edu.Contact__c).Id : null;
                }
                upsert eduDetails;
            }

            if(! empDetails.isEmpty()){
                for(Employment_Details__c emp : empDetails){
                    emp.Applicant_Proposal_Association__c = contactIdWithAPA.get(emp.Contact__c) != null ? contactIdWithAPA.get(emp.Contact__c).Id : null;
                }
                upsert empDetails;
            }
            
            return 'success';
        }catch(Exception e){
            return e.getMessage();
        }
    }

    // =================================== Meeting_Theme =================================== //

    // UPDATED METHOD FOR WORKSHOP USING PROPOSALID
   
/*    public static list<UserDocumentWrapper> getAllUserDoc(String proposalId) {
        try{
            System.debug('=============== getAllUserDoc ==================');
            System.debug('proposalId : ' + proposalId);
            
            List<UserDocumentWrapper> udWrapperList = new List<UserDocumentWrapper>();
            Map<String, ContentDocumentLink> userDocIdXcdLink = new Map<String, ContentDocumentLink>();
            Map<String, ContentDistribution> userDocIdXcDistrbtn = new Map<String, ContentDistribution>();
            
            Map<String, User_Document__c> idXUserDoc = new Map<String, User_Document__c>();
            Map<String,ContentDocumentLink> udIdXcdLink = New Map<String,ContentDocumentLink>();

            
            Id contactIdUsed;
            List<Applicant_Proposal_Association__c> apaList = [
                SELECT Id, Name, Proposals__c, Contact__c, Contact__r.Applicant_Host__c
                FROM Applicant_Proposal_Association__c
                WHERE Proposals__c = :proposalId
                AND Contact__r.Applicant_Host__c = 'Applicant'
            ];
            
            if (!apaList.isEmpty() && apaList[0].Contact__r.Applicant_Host__c != null) {
                contactIdUsed = apaList[0].Contact__c;
            } else {
                System.debug('No contacts found for the specified Application Proposal.');
            }
            
            
            
            List<User_Document__c> getUserDoc = [
                SELECT Name, Id, Status__c, Attachment_Name__c, 
                (SELECT Id FROM Attachments ORDER BY CreatedDate DESC) 
                FROM User_Document__c 
                WHERE (Proposals__c =:proposalId OR Contact__c =:contactIdUsed )
            ];
            System.debug('getUserDoc----'+getUserDoc);
            
            Set<string> userDocIdSet = new Set<string>();
            
            for(User_Document__c userDoc:getUserDoc){
                userDocIdSet.add(userDoc.id);
                idXUserDoc.put(userDoc.Id,userDoc);
            }
            
            List<ContentDocumentLink> allDocuments = [
                SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, IsDeleted, ShareType,
                ContentDocument.Title, ContentDocument.createdDate, ContentDocument.FileType 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId =: userDocIdSet 
                ORDER BY ContentDocument.CreatedDate];
            
            List<ContentDistribution> ContentDistrbtn = [
                SELECT DistributionPublicUrl,PdfDownloadUrl,RelatedRecordId 
                FROM ContentDistribution where RelatedRecordId 
                IN :userDocIdSet 
                ORDER BY createdDate
            ];
            System.debug('ContentDistrbtn---'+ContentDistrbtn);
            System.debug('allDocuments---'+allDocuments);
            
            Set<String> allDocId = new Set<String>();     
            
            for(ContentDocumentLink doc:allDocuments){
                system.debug('doc--'+doc.Id);
                userDocIdXcdLink.put(doc.LinkedEntityId,doc);
                allDocId.add(doc.ContentDocumentId);  
            }
            
            for(ContentDistribution doc:ContentDistrbtn){
                userDocIdXcDistrbtn.put(doc.RelatedRecordId,doc);
            }
            for(String userDocId:userDocIdSet){
                udIdXcdLink.put(userDocId,userDocIdXcdLink.get(userDocId));
            }
            
            Map<String,ContentDocumentLink> docNameXcVersion = new Map<String,ContentDocumentLink>();
            Map<String,ContentVersion> cdocIdXcVersion = new Map<String,ContentVersion>();
            
            ContentVersion[] cvs = [
                SELECT Id, Title, ContentDocumentId 
                FROM Contentversion
                WHERE isLatest = true 
                AND ContentDocumentId 
                IN :allDocId 
                ORDER BY CreatedDate desc
            ];
            System.debug('cvs--'+cvs);
            
            for(ContentVersion doc :cvs){
                cdocIdXcVersion.put(doc.ContentDocumentId,doc);
            }
            System.debug('cdocIdXcVersion--'+cdocIdXcVersion);
            
            for(string udId: userDocIdSet){
                system.debug('udId----------'+udId);
                UserDocumentWrapper udWrapper = New UserDocumentWrapper();
                udWrapper.userDocument = idXUserDoc.get(udId);
                System.debug('@@@@@'+userDocIdXcdLink.get(udId) );
                
                if(userDocIdXcdLink.get(udId) != null){
                    System.debug('@@@@@-----------'+cdocIdXcVersion.get(userDocIdXcdLink.get(udId).ContentDocumentId));
                    udWrapper.contentVersion = cdocIdXcVersion.get(userDocIdXcdLink.get(udId).ContentDocumentId) ;
                }
                if(userDocIdXcDistrbtn.get(udId) != null){
                    System.debug('@@@@@-----------'+userDocIdXcDistrbtn.get(udId));
                    udWrapper.ContentDistribution = userDocIdXcDistrbtn.get(udId) ;
                }
                system.debug('udWrapper---'+udWrapper);
                udWrapperList.add(udWrapper);
            }
            return udWrapperList;
        }catch(Exception e){
            //HandleBusinessException.captureError('CandidateDashboard_Helper', 'getAllUserDoc', e);
            system.debug(e.getLineNumber()+'-----get Message----'+e.getMessage());
            return null;
        }
    }*/

    public class UserDocumentWrapper{
        public User_Document__c userDocument;
        public ContentVersion contentVersion;
        public ContentDistribution ContentDistribution;
    }
     @RemoteAction
// UPDATED METHOD FOR WORKSHOP USING PROPOSALID 
    public static list<UserDocumentWrapper> getAllUserDoc(String proposalId) {
        try{
            System.debug('=============== getAllUserDoc ==================');
            System.debug('proposalId : ' + proposalId);
            List<UserDocumentWrapper> udWrapperList = new List<UserDocumentWrapper>();
            Map<String, ContentDocumentLink> userDocIdXcdLink = new Map<String, ContentDocumentLink>();
            Map<String, ContentDistribution> userDocIdXcDistrbtn = new Map<String, ContentDistribution>();
            Map<String, User_Document__c> idXUserDoc = new Map<String, User_Document__c>();
            Map<String,ContentDocumentLink> udIdXcdLink = New Map<String,ContentDocumentLink>();
            /*
Id contactIdUsed;
List<Application_Proposal__c> proposalList = [
SELECT Id, Name, 
(SELECT Id, Name, Applicant_Host__c 
FROM Contacts__r 
WHERE Applicant_Host__c = 'Applicant') 
FROM Application_Proposal__c WHERE Id =:proposalId
];
 
if (!proposalList.isEmpty() && !proposalList[0].Contacts__r.isEmpty()) {
contactIdUsed = proposalList[0].Contacts__r[0].Id;
} else {
System.debug('No contacts found for the specified Application Proposal.');
}
*/
            Id contactIdUsed;
            List<Applicant_Proposal_Association__c> apaList = [
                SELECT Id, Name, Proposals__c, Contact__c, Contact__r.Applicant_Host__c
                FROM Applicant_Proposal_Association__c
                WHERE Proposals__c = :proposalId
            ];
            if (!apaList.isEmpty() && apaList[0].Contact__r.Applicant_Host__c != null) {
                contactIdUsed = apaList[0].Contact__c;
            } else {
                System.debug('No contacts found for the specified Application Proposal.');
            }

            List<User_Document__c> getUserDoc = [
                SELECT Name, Id, Status__c, Attachment_Name__c, Applicant_Proposal_Association__c, Proposals__c, Contact__c, 
                (SELECT Id FROM Attachments ORDER BY CreatedDate DESC) 
                FROM User_Document__c 
                WHERE (Proposals__c =:proposalId OR Contact__c =:contactIdUsed )
            ];
            //System.debug('getUserDoc----'+getUserDoc);
            Set<string> userDocIdSet = new Set<string>();
            for(User_Document__c userDoc:getUserDoc){
                userDocIdSet.add(userDoc.id);
                idXUserDoc.put(userDoc.Id,userDoc);
            }
            List<ContentDocumentLink> allDocuments = [
                SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, IsDeleted, ShareType,
                ContentDocument.Title, ContentDocument.createdDate, ContentDocument.FileType 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId =: userDocIdSet 
                ORDER BY ContentDocument.CreatedDate];
            List<ContentDistribution> ContentDistrbtn = [
                SELECT DistributionPublicUrl,PdfDownloadUrl,RelatedRecordId 
                FROM ContentDistribution where RelatedRecordId 
                IN :userDocIdSet 
                ORDER BY createdDate
            ];
            //System.debug('ContentDistrbtn---'+ContentDistrbtn);
            //System.debug('allDocuments---'+allDocuments);
            Set<string> allDocId = New set<string>();     
            for(ContentDocumentLink doc:allDocuments){
                system.debug('doc--'+doc.Id);
                userDocIdXcdLink.put(doc.LinkedEntityId,doc);
                allDocId.add(doc.ContentDocumentId);  
            }
            for(ContentDistribution doc:ContentDistrbtn){
                userDocIdXcDistrbtn.put(doc.RelatedRecordId,doc);
            }
            for(string userDocId:userDocIdSet){
                udIdXcdLink.put(userDocId,userDocIdXcdLink.get(userDocId));
            }
            Map<String,ContentDocumentLink> docNameXcVersion = New Map<String,ContentDocumentLink>();
            Map<String,ContentVersion> cdocIdXcVersion = New Map<String,ContentVersion>();
            ContentVersion[] cvs = [
                SELECT Id, Title, ContentDocumentId 
                FROM Contentversion
                WHERE isLatest = true 
                AND ContentDocumentId 
                IN :allDocId 
                ORDER BY CreatedDate desc
            ];
            System.debug('cvs--'+cvs);
            for(ContentVersion doc :cvs){
                cdocIdXcVersion.put(doc.ContentDocumentId,doc);
            }
            System.debug('cdocIdXcVersion--'+cdocIdXcVersion);
            for(string udId: userDocIdSet){
                system.debug('udId----------'+udId);
                UserDocumentWrapper udWrapper = New UserDocumentWrapper();
                udWrapper.userDocument = idXUserDoc.get(udId);
                System.debug('@@@@@'+userDocIdXcdLink.get(udId) );
                if(userDocIdXcdLink.get(udId) != null){
                    System.debug('@@@@@-----------'+cdocIdXcVersion.get(userDocIdXcdLink.get(udId).ContentDocumentId));
                    udWrapper.contentVersion = cdocIdXcVersion.get(userDocIdXcdLink.get(udId).ContentDocumentId) ;
                }
                if(userDocIdXcDistrbtn.get(udId) != null){
                    System.debug('@@@@@-----------'+userDocIdXcDistrbtn.get(udId));
                    udWrapper.ContentDistribution = userDocIdXcDistrbtn.get(udId) ;
                }
                system.debug('udWrapper---'+udWrapper);
                udWrapperList.add(udWrapper);
            }
            return udWrapperList;
        }catch(Exception e){
            //HandleBusinessException.captureError('CandidateDashboard_Helper', 'getAllUserDoc', e);
            system.debug(e.getLineNumber()+'-----get Message----'+e.getMessage());
            return null;
        }
    }

    @RemoteAction
    public static String doCUploadAttachmentAa(String attachmentBody, String attachmentName, string cvId, String udId) {
        try {
            System.debug('=== Upload Start ===');
            System.debug('attachmentBody: ' + attachmentName);
            System.debug('cvId: ' + cvId);
            System.debug('udId: ' + udId);
            System.debug('attachmentBody length: ' + (attachmentBody != null ? attachmentBody.length() : 0));
            
            // FIX 1: Check if udId is provided and valid
            if (String.isBlank(udId)) {
                System.debug('ERROR: udId is null or blank');
                throw new AuraHandledException('User Document ID is required but was not provided');
            }
            
            // FIX 2: Verify the User_Document__c record exists before trying to update
            User_Document__c userDoc;
            try {
                userDoc = [SELECT Id, Status__c FROM User_Document__c WHERE Id = :udId LIMIT 1];
            } catch (Exception e) {
                System.debug('ERROR: User Document not found with Id: ' + udId);
                throw new AuraHandledException('User Document record not found');
            }
            
            // Update the status
            userDoc.Status__c = 'Uploaded';
            update userDoc;
            System.debug('User Document updated successfully');
            
            // Handle attachment creation/update
            if (String.isBlank(cvId)) {
                // Create new attachment
                Attachment aatt = new Attachment(
                    ParentId = udId, 
                    Name = attachmentName, 
                    Body = EncodingUtil.base64Decode(attachmentBody)
                );
                
                // FIX 3: Get owner safely
                Id ownerId = getOwnerIdOfRecord(udId);
                if (ownerId != null) {
                    aatt.OwnerId = ownerId;
                }
                
                insert aatt;
                System.debug('New attachment created: ' + aatt.Id);
                return aatt.Id;
            } else {
                // Append to existing attachment
                Attachment att = getAttachment(cvId);
                String newBody = '';
                if (att.Body != null) {
                    newBody = EncodingUtil.base64Encode(att.Body);
                }
                newBody += attachmentBody;
                att.Body = EncodingUtil.base64Decode(newBody);
                
                // FIX 3: Get owner safely
                Id ownerId = getOwnerIdOfRecord(udId);
                if (ownerId != null) {
                    att.OwnerId = ownerId;
                }
                
                update att;
                System.debug('Attachment updated: ' + att.Id);
                return att.Id;
            }
            
        } catch (Exception e) {
            System.debug('=== Upload Exception ===');
            System.debug('Error: ' + e.getMessage());
            System.debug('Line: ' + e.getLineNumber());
            System.debug('Stack: ' + e.getStackTraceString());
            throw new AuraHandledException('Upload failed: ' + e.getMessage());
        }
    }

    public static Id getOwnerIdOfRecord(Id recordId){
        
        String objectName = recordId.getSObjectType().getDescribe().getName();
        String ownerIdFieldName = 'OwnerId';
        
        // Build the dynamic SOQL query
        String queryString = 'SELECT ' + ownerIdFieldName + ' FROM ' + objectName + ' WHERE Id = \'' + recordId + '\' LIMIT 1';
        
        // Execute the dynamic SOQL query
        SObject[] queryResult = Database.query(queryString);
        
        // Get the OwnerId value from the query result
        Id ownerId = (Id)queryResult[0].get(ownerIdFieldName);
        return ownerId;
    }

    private static Attachment getAttachment(String attId) {
        list<Attachment> attachments = [SELECT Id, Body
                                        FROM Attachment 
                                        WHERE Id =: attId];
        if(attachments.isEmpty()) {
            Attachment a = new Attachment();
            return a;
        } else {
            return attachments[0];
        }
    }

    // ------------ WRAPPER CLASS ------------- //
    public class ProposalWithContactsDTO {
        public String Id;
        public String Name;
        public Boolean Privacy_Policy_Accepted;
        
        public List<ContactDTO> Contacts = new List<ContactDTO>();
    }
    
    public class ContactDTO {
        public String Id;
        public String Name;
        public AccountDTO Account;
        public Date Declaration_Sign_Date;
    }
    
    public class AccountDTO {
        public String Country_Type;
    }

    @RemoteAction
    public static ProposalWithContactsDTO getConsentCheckbox(String proposalId) {

        System.debug('------------- getConsentCheckbox(proposalId) ---------------');
        System.debug('proposalId : ' + proposalId);

        ProposalWithContactsDTO dto = new ProposalWithContactsDTO();

        try {
            Application_Proposal__c proposal = [
                SELECT Id, Name, Privacy_Policy_Accepted__c
                FROM Application_Proposal__c
                WHERE Id = :proposalId
                LIMIT 1
            ];

            dto.Id = proposal.Id;
            dto.Name = proposal.Name;
            dto.Privacy_Policy_Accepted = proposal.Privacy_Policy_Accepted__c;

            List<Contact> contacts = [SELECT Id,Name,Declaration_Sign_Date__c,Account.Country_Type__c FROM Contact 
                                        WHERE Id IN (SELECT Contact__c FROM Applicant_Proposal_Association__c WHERE Proposals__c = :proposalId)];

            for (Contact c : contacts) {
                ContactDTO cDto = new ContactDTO();
                cDto.Id = c.Id;
                cDto.Name = c.Name;
                cDto.Declaration_Sign_Date = c.Declaration_Sign_Date__c;

                AccountDTO accDto = new AccountDTO();
                accDto.Country_Type = c.Account.Country_Type__c;

                cDto.Account = accDto;
                dto.Contacts.add(cDto);
            }

            System.debug('dto ---> ' + dto);
            return dto;

        } catch (Exception e) {
            System.debug('Error in getConsentCheckbox: ' + e.getMessage());
            return dto;
        }
    }
    
    @RemoteAction
    public static String doCUploadAttachmentSignature(String attachmentBody, String attachmentName, string cvId, String udId) {
        system.debug('attachmentBody---'+attachmentName+'---attachmentId---'+cvId+'---cvId---'+udId);
        system.debug('cvId---'+cvId+'---udId---'+udId);
        if(cvId == ''){
            cvId = null;
        }
        if(udId == ''){
            udId = null;
        }
        User_Document__c userDocc = New User_Document__c();
        userDocc.Id = udId;
        userDocc.Status__c = 'Uploaded';
        system.debug('status ::'+userDocc);
        upsert userDocc;
        
        udId = userDocc.Id;

        Attachment a = new Attachment(parentId = udId, name=attachmentName, body = Blob.valueOf(attachmentBody));
        insert a;
        if(String.isBlank(attachmentBody) || String.isBlank(udId))
            return 'ERROR';
        if(String.isBlank(cvId)) {
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S';
            conVer.PathOnClient = '/'+System.now()+attachmentName;//'attachmentName';
            conVer.Title = attachmentName;
            conVer.VersionData = EncodingUtil.base64Decode(attachmentBody);
            conVer.isMajorVersion = false;
            insert conVer;
            
            ContentDistribution cdl = new ContentDistribution();
            cdl.ContentVersionId = conVer.Id;
            cdl.Name = 'PublicShare';
            cdl.RelatedRecordId = udId;
            insert cdl;
            system.debug('ContentDistribution----'+cdl);
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = udId;
            conDocLink.ContentDocumentId = conDoc;
            conDocLink.shareType = 'V';
            insert conDocLink;
            
            return conVer.Id;
            
        }else {
            List<ContentVersion> cvList = [SELECT Id, VersionData FROM ContentVersion WHERE Id = :cvId];
            if(!cvList.isEmpty()) {
                ContentVersion cVersion = cvList[0];
                if(cVersion.VersionData != null) {
                    String newBody = EncodingUtil.base64Encode(cVersion.VersionData);
                    newBody += attachmentBody;
                    cVersion.VersionData = EncodingUtil.base64Decode(newBody);
                    update cVersion;
                    return cVersion.Id;
                }
            }
        }
        return 'Success';
    }

    // =================================== Signature Of Coordinators =================================== //

    // NEW METHOD - FOR WORKSHOP
    @RemoteAction
    public static String upsertCheckbox(Application_Proposal__c proposalList, String hashcode, Integer year, Integer month, Integer day, String apaId){
        try{
            System.debug(' --------------- upsertCheckbox() ------------------- ');
            
            /*
            Contact userContact = [
                SELECT Id, Name, Declaration_Sign_Date__c, Login_Hash_Code__c 
                FROM Contact 
                WHERE Login_Hash_Code__c = :hashcode
            ];
            System.debug('userContact : ' + userContact);
            
            if (userContact == null) {
                return 'Error: Invalid hashcode (contact not found)';
            }
            
            Applicant_Proposal_Association__c apa = [
                SELECT Id, Contact__c, Proposals__c
                FROM Applicant_Proposal_Association__c
                WHERE Contact__c = :userContact.Id
                LIMIT 1
            ];
            System.debug('apa : ' + apa);
            
            if (apa == null || apa.Proposals__c == null) {
                return 'Error: No proposal found for this contact';
            }
            */

            // Updating Applicant_Proposal_Association__c record
            Applicant_Proposal_Association__c apa = new Applicant_Proposal_Association__c(
                Id = apaId,
                Applicant_Status__c = 'Submitted'
            );
            update apa;
            System.debug('apa UPDATED SUCCESSFULLY !!');
            

            Id proposalId = proposalList.Id;
            System.debug('proposalId : ' + proposalId);
            
            List<Contact> contactList = [
                SELECT Id, Name, Declaration_Sign_Date__c
                FROM Contact
                WHERE Id IN (
                    SELECT Contact__c
                    FROM Applicant_Proposal_Association__c
                    WHERE Proposals__c = :proposalId
                )
            ];
            System.debug('contactList Size : ' + contactList.size());
            System.debug('contactList : ' + contactList);
            
            if(! contactList.isEmpty()){
                for(Contact con : contactList){
                    if(year == 0 && month == 0 && day == 0){
                        
                    }else{
                        Date newDate = Date.newInstance(year,month,day);
                        con.Declaration_Sign_Date__c = newDate;
                    }
                }
            }
            update contactList;
            System.debug('contactList UPDATED SUCCESSFULLY !!');
            
            // Best Practice to query the records, else it will update the unpassed fields as null
            
            // Application_Proposal__c proposalToUpdate = [
            //     SELECT Id 
            //     FROM Application_Proposal__c
            //     WHERE Id = :proposalId
            //     LIMIT 1
            // ];
            // proposalToUpdate.Proposal_Stages__c = 'Draft';
            // proposalToUpdate.Submitted__c = true;
            
            // // Apply user-updated fields
            // proposalToUpdate.putAll(proposalList);
            
            // upsert proposalToUpdate;
            
            
            proposalList.Stage__c = '1st Stage';
            proposalList.Proposal_Stages__c = 'Submitted';
            proposalList.Submitted__c = true;
            
            upsert proposalList;
            System.debug('proposalList UPDATED SUCCESSFULLY !!');
            
            return 'success';
        }catch(Exception e){
            return e.getMessage() + e.getLineNumber();
        }
    } 

    @RemoteAction
    public static String saveAsDraftWorkshop(Application_Proposal__c proposalList, String projectId, Integer year, Integer month, Integer day){
        
        try{
            Contact userContact = [
                SELECT Id, Name, Declaration_Sign_Date__c, Login_Hash_Code__c 
                FROM Contact 
                WHERE Login_Hash_Code__c = :projectId
            ];
            System.debug('userContact : ' + userContact);
            
            if (userContact == null) {
                return 'Error: Invalid hashcode (contact not found)';
            }
            
            Applicant_Proposal_Association__c apa = [
                SELECT Id, Contact__c, Proposals__c
                FROM Applicant_Proposal_Association__c
                WHERE Contact__c = :userContact.Id
                LIMIT 1
            ];
            System.debug('apa : ' + apa);
            
            if (apa == null || apa.Proposals__c == null) {
                return 'Error: No proposal found for this contact';
            }
            
            Id proposalId = apa.Proposals__c;
            System.debug('proposalId : ' + proposalId);
            
            List<Contact> contactList = [
                SELECT Id, Name, Declaration_Sign_Date__c
                FROM Contact
                WHERE Id IN (
                    SELECT Contact__c
                    FROM Applicant_Proposal_Association__c
                    WHERE Proposals__c = :proposalId
                )
            ];
            System.debug('contactList Size : ' + contactList.size());
            System.debug('contactList : ' + contactList);
            
            if(! contactList.isEmpty()){
                for(Contact con : contactList){
                    if(year == 0 && month == 0 && day == 0){
                        
                    }else{
                        Date newDate = Date.newInstance(year,month,day);
                        con.Declaration_Sign_Date__c = newDate;
                    }
                }
            }
            update contactList;
            System.debug('contactList UPDATED SUCCESSFULLY !!');
            
            // Best Practice to query the records, else it will update the unpassed fields as null
            /*
                Application_Proposal__c proposalToUpdate = [
                SELECT Id 
                FROM Application_Proposal__c
                WHERE Id = :proposalId
                LIMIT 1
                ];
                proposalToUpdate.Proposal_Stages__c = 'Draft';
                proposalToUpdate.Submitted__c = true;

                // Apply user-updated fields
                proposalToUpdate.putAll(proposalList);

                upsert proposalToUpdate;
            */
            
            // proposalDetails.Stage__c = '1st Stage';
            proposalList.Proposal_Stages__c = 'Draft';
            proposalList.Submitted__c = true;
            
            upsert proposalList;
            System.debug('proposalList UPDATED SUCCESSFULLY !!');
            
            return 'success';
        }catch(Exception e){
            return e.getMessage() + e.getLineNumber();
        }
    } 
}