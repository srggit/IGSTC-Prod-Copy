@isTest
private class IndustrialFellowshipModelTest {
    
    @TestSetup
    static void setupTestData() {
        // Create Campaign
        Campaign camp = new Campaign(Name = 'Industrial Fellowship', EndDate = Date.today().addDays(30));
        insert camp;
        
        // Create Yearly Call
        Year__c yearRec = new Year__c(Name = '2025', Is_Active__c = true, Is_Current_Year__c = true);
        insert yearRec;
        
        YealyCall__c yearlyCall = new YealyCall__c(Year__c = '2025');
        insert yearlyCall;
        
        // Create Account
        Account acc = new Account(Name = 'Test Account', Country_Type__c = 'India');
        insert acc;
        
        // Create Contact
        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test@example.com',
            Login_Hash_Code__c = 'testHash123',
            AccountId = acc.Id
        );
        insert con;
        
        // Create Host Contact
        Contact hostCon = new Contact(
            FirstName = 'Host',
            LastName = 'Contact',
            Email = 'host@example.com',
            Host__c = true
        );
        insert hostCon;
        
        con.Host_Details__c = hostCon.Id;
        update con;
        
        // Create Application Proposal
        Application_Proposal__c proposal = new Application_Proposal__c(
            Campaign__c = camp.Id,
            Proposal_Stages__c = 'Draft',
            yearly_Call__c = yearlyCall.Id,
            Title_Of__c = 'Test IF Proposal',
            RecordTypeId = Utility.getProposalRecordType('Industrial Fellowship')
        );
        insert proposal;
        
        // Create Applicant Proposal Association
        Applicant_Proposal_Association__c apa = new Applicant_Proposal_Association__c(
            Contact__c = con.Id,
            Proposals__c = proposal.Id,
            Is_Coordinator__c = true
        );
        insert apa;
        
        // Create Education Details
        Education_Details__c edu = new Education_Details__c(
            Contact__c = con.Id,
            Applicant_Proposal_Association__c = apa.Id,
            Degree__c = 'PhD',
            Institution_Name__c = 'Test University',
            Start_Year__c = '2020',
            End_Year__c = '2024'
        );
        insert edu;
        
        // Create Achievement
        Achievement__c ach = new Achievement__c(
            Contact__c = con.Id,
            Awards_Honours__c = 'Test Award'
        );
        insert ach;
        
        // Create Employment Details
        Employment_Details__c emp = new Employment_Details__c(
            Contact__c = con.Id,
            Applicant_Proposal_Association__c = apa.Id,
            Organization_Name__c = 'Test Org',
            Position__c = 'Researcher',
            Start_Year__c = '2020',
            End_Year__c = '2024'
        );
        insert emp;
        
        // Create Publications
        Publications_Patents__c pub = new Publications_Patents__c(
            Contact__c = con.Id,
            Description__c = 'Test Publication'
        );
        insert pub;
        
        // Create Bank Details
        Bank_Details__c bank = new Bank_Details__c(
            Account__c = acc.Id,
            Bank_Name__c = 'Test Bank',
            Bank_Account_Number__c = '1234567890'
        );
        insert bank;
        
        // Create User Document
        User_Document__c ud = new User_Document__c(
            Contact__c = con.Id,
            Name = 'Test Document',
            Status__c = 'Pending'
        );
        insert ud;
        
        // Create ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'test.txt',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert cv;
        
        // Create ContentDocumentLink
        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = ud.Id,
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId,
            ShareType = 'V'
        );
        insert cdl;
    }
    
    @isTest
    static void testGetEduQualification() {
        Contact con = [SELECT Login_Hash_Code__c FROM Contact LIMIT 1];
        Applicant_Proposal_Association__c apa = [SELECT Id FROM Applicant_Proposal_Association__c LIMIT 1];
        
        IndustrialFellowshipModel model = new IndustrialFellowshipModel();
        
        Test.startTest();
        List<Education_Details__c> result = model.getEduQualification(con.Login_Hash_Code__c, apa.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testGetAchievementsDet() {
        Contact con = [SELECT Login_Hash_Code__c FROM Contact LIMIT 1];
        
        IndustrialFellowshipModel model = new IndustrialFellowshipModel();
        
        Test.startTest();
        Achievement__c result = model.getAchievementsDet(con.Login_Hash_Code__c);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testGetContactEmployement() {
        Contact con = [SELECT Login_Hash_Code__c FROM Contact LIMIT 1];
        Applicant_Proposal_Association__c apa = [SELECT Id FROM Applicant_Proposal_Association__c LIMIT 1];
        
        IndustrialFellowshipModel model = new IndustrialFellowshipModel();
        
        Test.startTest();
        Contact result = model.getContactEmployement(con.Login_Hash_Code__c, apa.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testGetContactDetailsFellowDet() {
        Contact con = [SELECT Login_Hash_Code__c FROM Contact LIMIT 1];
        
        IndustrialFellowshipModel model = new IndustrialFellowshipModel();
        
        Test.startTest();
        Contact result = model.getContactDetailsFellowDet(con.Login_Hash_Code__c);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testGetContactSingh() {
        Contact con = [SELECT Login_Hash_Code__c FROM Contact LIMIT 1];
        
        IndustrialFellowshipModel model = new IndustrialFellowshipModel();
        
        Test.startTest();
        Contact result = model.getContactSingh(con.Login_Hash_Code__c);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testGetProposalDet() {
        Contact con = [SELECT Login_Hash_Code__c FROM Contact LIMIT 1];
        
        IndustrialFellowshipModel model = new IndustrialFellowshipModel();
        
        Test.startTest();
        Contact result = model.getProposalDet(con.Login_Hash_Code__c);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testGetAccountBankDetails() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        IndustrialFellowshipModel model = new IndustrialFellowshipModel();
        
        Test.startTest();
        Account result = model.getAccountBankDetails(acc.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testGetContactHostInfo() {
        Contact con = [SELECT Id FROM Contact WHERE Host_Details__c != null LIMIT 1];
        
        Test.startTest();
        Contact result = IndustrialFellowshipModel.getContactHostInfo(con.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testGetHostProjectDetails() {
        Application_Proposal__c proposal = [SELECT Id FROM Application_Proposal__c LIMIT 1];
        
        Test.startTest();
        Application_Proposal__c result = IndustrialFellowshipModel.getHostProjectDetails(proposal.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testGetContactEduOtherDet() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        IndustrialFellowshipModel model = new IndustrialFellowshipModel();
        
        Test.startTest();
        List<Contact> result = model.getContactEduOtherDet(acc.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testGetAccountContactEduOtherDetList() {
        Application_Proposal__c proposal = [SELECT Id FROM Application_Proposal__c LIMIT 1];
        
        IndustrialFellowshipModel model = new IndustrialFellowshipModel();
        
        Test.startTest();
        List<IndustrialFellowshipModel.WrapperConsortiaContacts> result = 
            model.getAccountContactEduOtherDetList(proposal.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testGetEducationQualificationData() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        
        IndustrialFellowshipModel model = new IndustrialFellowshipModel();
        
        Test.startTest();
        List<Education_Details__c> result = model.getEducationQualificationData(con.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testGetEmploymentData() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        
        IndustrialFellowshipModel model = new IndustrialFellowshipModel();
        
        Test.startTest();
        List<Employment_Details__c> result = model.getEmploymentData(con.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testGetPublicationData() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        
        IndustrialFellowshipModel model = new IndustrialFellowshipModel();
        
        Test.startTest();
        List<Publications_Patents__c> result = model.getPublicationData(con.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testGetWorkshopDocUpload() {
        Contact con = [SELECT Login_Hash_Code__c FROM Contact LIMIT 1];
        
        IndustrialFellowshipModel model = new IndustrialFellowshipModel();
        
        Test.startTest();
        Contact result = model.getWorkshopDocUpload(con.Login_Hash_Code__c);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testGetDocUploadDet() {
        Contact con = [SELECT Login_Hash_Code__c FROM Contact LIMIT 1];
        
        IndustrialFellowshipModel model = new IndustrialFellowshipModel();
        
        Test.startTest();
        Contact result = model.getDocUploadDet(con.Login_Hash_Code__c);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testGetDocUploadDetPECFAR() {
        Contact con = [SELECT Login_Hash_Code__c FROM Contact LIMIT 1];
        
        IndustrialFellowshipModel model = new IndustrialFellowshipModel();
        
        Test.startTest();
        IndustrialFellowshipModel.WrapperDocGrant result = model.getDocUploadDetPECFAR(con.Login_Hash_Code__c);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        // WrapperDocGrant fields are private, can't access directly
    }
    
    @isTest
    static void testGetAllUserDoc() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        
        IndustrialFellowshipModel model = new IndustrialFellowshipModel();
        
        Test.startTest();
        List<IndustrialFellowshipModel.UserDocumentWrapper> result = model.getAllUserDoc(con.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testGetCampaignEndDate() {
        Campaign camp = [SELECT Name FROM Campaign LIMIT 1];
        
        IndustrialFellowshipModel model = new IndustrialFellowshipModel();
        
        Test.startTest();
        Campaign result = model.getCampaignEndDate(camp.Name);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }
}