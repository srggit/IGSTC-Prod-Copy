@isTest
public class Proposal_Controller_Test {    
   /* @isTest
    public static void testCoverage(){
        Proposal_Controller.firstTestMethod1();
        Proposal_Controller.firstTestMethod2();
	    Proposal_Controller.firstTestMethod3();
        Proposal_Controller.firstTestMethod4();
	    Proposal_Controller.firstTestMethod5();
        Proposal_Controller.firstTestMethod6();
	    Proposal_Controller.firstTestMethod7();
        Proposal_Controller.firstTestMethod07();
        Proposal_Controller.firstTestMethod8();
	    Proposal_Controller.firstTestMethod9();
        Proposal_Controller.firstTestMethod10();
	    Proposal_Controller.firstTestMethod11();
        Proposal_Controller.firstTestMethod22();
    }*/
    
    @isTest
    public static void testGetApplicantDetails() {    
        // 1. Create Contact
        Contact con = new Contact(LastName = 'Test User',Email =' karthikke129+test@gmail.com',Login_Hash_Code__c = 'HASH123');
        insert con;        
        // 2. Get RecordType
        Id rtId = [SELECT Id FROM RecordType WHERE SobjectType = 'Application_Proposal__c' AND DeveloperName = 'Two_Plus_Two' LIMIT 1].Id;        
        // 3. Create Proposal
        Application_Proposal__c proposal = new Application_Proposal__c(RecordTypeId = rtId,Title_Of__c = 'Test Title');
        insert proposal;        
        // 4. Link proposal to contact (Direct lookup case)
        con.Proposals__c = proposal.Id;
        update con;
        
        // 5. Create APA record (junction object)
        Applicant_Proposal_Association__c apa = new Applicant_Proposal_Association__c(Contact__c = con.Id,Proposals__c = proposal.Id,Is_Coordinator__c = true);
        insert apa;        
        Test.startTest();        
        // ===============================
        // CASE 1: With apaId
        // ===============================
        Proposal_Controller.insertApplicationWrapper result1 = Proposal_Controller.getApplicantDetails('HASH123', apa.Id);        
         // ===============================
        // CASE 2: Without apaId (direct proposal from Contact)
        // ===============================
        Proposal_Controller.insertApplicationWrapper result2 = Proposal_Controller.getApplicantDetails('HASH123', null);        
        // ===============================
        // CASE 3: Remove direct lookup → use junction object
        // ===============================
        con.Proposals__c = null;
        update con;        
        Proposal_Controller.insertApplicationWrapper result3 = Proposal_Controller.getApplicantDetails('HASH123', null);        
         // ===============================
        // CASE 4: No data → expect null
        // ===============================
        Contact con2 = new Contact(LastName = 'No Proposal User',Login_Hash_Code__c = 'HASH999',Email =' karthikke129+test2@gmail.com');
        insert con2;        
        Proposal_Controller.insertApplicationWrapper result4 = Proposal_Controller.getApplicantDetails('HASH999', null);        
        Test.stopTest();
    }
    
    @isTest
    public static void testThematicAreaMethods() {
        // STEP 1: Create Thematic Areas
        Thematic_Area__c ta1 = new Thematic_Area__c(Name = 'Theme A',Is_Active__c = true);
        Thematic_Area__c ta2 = new Thematic_Area__c(Name = 'Theme B',Is_Active__c = false);        
        insert new List<Thematic_Area__c>{ta1, ta2};        
        // STEP 2: Create Proposal (if required)
        Application_Proposal__c proposal = new Application_Proposal__c(Title_Of__c = 'Test Title');
        insert proposal;        
        // STEP 3: Create Application_Thematic_Area__c
        Application_Thematic_Area__c appTheme = new Application_Thematic_Area__c(Thematic_Area__c = ta1.Id,Application__c = proposal.Id);
        insert appTheme;        
        // ===============================
        // SINGLE startTest()
        // ===============================
        Test.startTest();        
        // Test fetch
        List<Thematic_Area__c> result = Proposal_Controller.fetchAllThematicArea();        
        // Test delete
        Proposal_Controller.deleteThematicArea(appTheme.Id);        
        Test.stopTest();        
       
      
}
    
    @isTest
    public static void testInsertAccountAndContact() {        
        // Create Account & Contact
        Account acc = new Account(Name = 'Test Account');
        Contact con = new Contact(LastName = 'Test Contact',Email = 'karthikke129+testtttt@gmail.com');        
        List<Account> accList = new List<Account>{acc};
        List<Contact> conList = new List<Contact>{con};        
        Test.startTest();        
        String result = Proposal_Controller.insertAccount(accList, conList);   
		String result2 = Proposal_Controller.insertAccountAndContact(acc, conList);        

        Test.stopTest();        
       
    }
    
    @isTest
    public static void testInsertConsortiaDetailPage() {        
        // ===============================
        // STEP 1: Create Proposal (ProjectId)
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(Title_Of__c = 'Test Proposal');
        insert proposal;        
        // ===============================
        // STEP 2: Prepare Wrapper Data
        // ===============================        
        // Company 1
        Account comp1 = new Account(Name = 'Company A',Website = 'www.companya.com',Country_Type__c = 'India');
        Contact c1 = new Contact(LastName = 'Contact A1',Email = 'karthikke129+test@gmail.com');
        Contact c2 = new Contact(LastName = 'Contact A2',Email = 'karthikke129+test2@gmail.com');
        // Wrapper 1
        Proposal_Controller.ConsortiaDetails cd1 = new Proposal_Controller.ConsortiaDetails();
        cd1.company = comp1;
        cd1.partnerDetails = new List<Contact>{c1, c2};        
        
        // Company 2
        Account comp2 = new Account(Name = 'Company B',Website = 'www.companyb.com',Country_Type__c = 'Germany');
        Contact c3 = new Contact(LastName = 'Contact B1',Email = 'karthikke129+test3@gmail.com');        
        // Wrapper 2
        Proposal_Controller.ConsortiaDetails cd2 = new Proposal_Controller.ConsortiaDetails();
        cd2.company = comp2;
        cd2.partnerDetails = new List<Contact>{c3};        
        
        List<Proposal_Controller.ConsortiaDetails> inputList = new List<Proposal_Controller.ConsortiaDetails>{cd1, cd2};        
        // ===============================
        // EXECUTE METHOD
        // ===============================
        Test.startTest();        
        String result = Proposal_Controller.insertConsortiaDetailPage(inputList,proposal.Id);        
        Test.stopTest();        
        
    }
    
    @isTest
    public static void testGetPatnerDetails() {        
        // ===============================
        // STEP 1: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(Title_Of__c = 'Test Proposal');
        insert proposal;        
        // ===============================
        // STEP 2: Create Accounts
        // ===============================
        Account acc1 = new Account(Name = 'Coordinator Account');
        Account acc2 = new Account(Name = 'Partner Account');
        insert new List<Account>{acc1, acc2};        
        // ===============================
        // STEP 3: Create Contacts
        // ===============================
        Contact con1 = new Contact(LastName = 'Coordinator Contact',AccountId = acc1.Id,Email = 'karthikke129+test@gmail.com');
        Contact con2 = new Contact(LastName = 'Partner Contact',AccountId = acc2.Id,Email = 'karthikke129+test@gmail.com');
        insert new List<Contact>{con1, con2};        
        // ===============================
        // STEP 4: Create APA Records
        // ===============================
        Applicant_Proposal_Association__c apa1 = new Applicant_Proposal_Association__c(Contact__c = con1.Id,Proposals__c = proposal.Id,Is_Coordinator__c = true);
        Applicant_Proposal_Association__c apa2 = new Applicant_Proposal_Association__c(Contact__c = con2.Id,Proposals__c = proposal.Id,Is_Coordinator__c = false);
        insert new List<Applicant_Proposal_Association__c>{apa1, apa2};
        // ===============================
        // EXECUTE METHOD
        // ===============================
        Test.startTest();        
        List<Account> result = Proposal_Controller.getPatnerDetails(proposal.Id);        
        Test.stopTest();        
        
    }
    
    @isTest
    public static void testGetSinglePatnerDetails() {        
        // ===============================
        // STEP 1: Create Account
        // ===============================
        Account acc = new Account(Name = 'Test Account');
        insert acc;        
        // ===============================
        // STEP 2: Create Contact
        // ===============================
        Contact con = new Contact(LastName = 'Test Contact',Email = 'karthikke129+test@gmail.com',Login_Hash_Code__c = 'HASH123SINGLE',AccountId = acc.Id);
        insert con;        
        // ===============================
        // EXECUTE METHOD
        // ===============================
        Test.startTest();    
        Contact result = Proposal_Controller.getSinglePatnerDetails('HASH123SINGLE');    
        Test.stopTest();        
        
    }
    
    @isTest
    public static void testGetPatnerDetails3() {        
        // STEP 1: Get Workshop RecordType
        Id workshopRtId = [SELECT Id FROM RecordType WHERE SobjectType = 'Application_Proposal__c' AND DeveloperName = 'Workshop'LIMIT 1].Id;        
        // STEP 2: Create Proposal
        Application_Proposal__c proposal = new Application_Proposal__c(RecordTypeId = workshopRtId,Title_Of__c = 'Workshop Proposal');
        insert proposal;        
        // STEP 3: Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;        
        // STEP 4: Create Contact
        Contact con = new Contact(LastName = 'Test Contact',Email = 'karthikke129+test@gmail.com',Login_Hash_Code__c = 'HASH123',AccountId = acc.Id);
        insert con;        
        // STEP 5: Create APA
        Applicant_Proposal_Association__c apa = new Applicant_Proposal_Association__c(Contact__c = con.Id,Proposals__c = proposal.Id);
        insert apa;        
        // ===============================
        // SINGLE startTest()
        // ===============================
        Test.startTest();        
        // CASE 1: proposalId = NULL
        List<Account> result1 = Proposal_Controller.getPatnerDetails3('HASH123', null);  
        
        // CASE 2: proposalId NOT NULL
        List<Account> result2 = Proposal_Controller.getPatnerDetails3('HASH123', proposal.Id);       
		
        Test.stopTest();        
               
    }
    
    @isTest
    public static void testGetPatnerDetails2() {    
        // ===============================
        // STEP 1: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(Title_Of__c = 'Test Proposal');
        insert proposal;    
        // ===============================
        // STEP 2: Create Accounts
        // ===============================
        Account acc1 = new Account(Name = 'Proposal Account',Proposals__c = proposal.Id);   
        Account acc2 = new Account(Name = 'Contact Account');    
        insert new List<Account>{acc1, acc2};    
        // ===============================
        // STEP 3: Create Contacts
        // ===============================    
        // Case 1: With Proposal
        Contact con1 = new Contact(LastName = 'With Proposal',Login_Hash_Code__c = 'HASHP1',Email ='karthikke129+test@gmail.com',AccountId = acc1.Id,Proposals__c = proposal.Id);
        // Case 2: Without Proposal
        Contact con2 = new Contact(LastName = 'Without Proposal',Email ='karthikke129+test2@gmail.com',Login_Hash_Code__c = 'HASHP2',AccountId = acc2.Id);    
        insert new List<Contact>{con1, con2};    
        // ===============================
        // EXECUTE METHOD
        // ===============================
        Test.startTest();    
        // CASE 1: Proposal exists
        List<Account> result1 = Proposal_Controller.getPatnerDetails2('HASHP1');    
        // CASE 2: No Proposal → fallback logic
        List<Account> result2 = Proposal_Controller.getPatnerDetails2('HASHP2');   
		
        Test.stopTest();    
        
}
    
   @isTest
    public static void testDeleteContact() {        
        // STEP 1: Create Contact
        Contact con = new Contact(LastName = 'Delete Me',Email = 'karthikke129+test@gmail.com');
        insert con;        
        Test.startTest();        
        // Execute method
        Proposal_Controller.deleteContact(con.Id);        
        Test.stopTest();        
        
}
    
    @isTest
    public static void testDeleteAccountAndContactDetails() {        
        // STEP 1: Create Account
        Account acc = new Account(Name = 'Delete Account');
        insert acc;        
        // STEP 2: Create Contacts linked to Account
        Contact con1 = new Contact(LastName = 'Contact 1',Email = 'karthikke129+test@gmail.com',AccountId = acc.Id);
        Contact con2 = new Contact(LastName = 'Contact 2',Email = 'karthikke129+test2@gmail.com',AccountId = acc.Id);
        insert new List<Contact>{con1, con2};        
        // Prepare contactId list
        List<String> contactIds = new List<String>{con1.Id, con2.Id};             
        Test.startTest();        
        // Execute method
       
		String result = Proposal_Controller.insertPartnerInformation(acc); 
        //Proposal_Controller.deleteContact(con1.Id);
        Proposal_Controller.deleteAccountDetails(acc.Id, contactIds);    
       
        

        Test.stopTest();        
        
}
    
    @isTest
    public static void testInsertContactDetails() {        
        // ===============================
        // STEP 1: Create Contact
        // ===============================
         Application_Proposal__c proposal = new Application_Proposal__c(Title_Of__c = 'Test Proposal');
        insert proposal;        
        
        Contact con = new Contact(LastName = 'Test Contact',Email = 'karthikke129+test@gmail.com',Login_Hash_Code__c = 'HASHCURR',Proposals__c=proposal.Id);        
        List<Contact> contactList = new List<Contact>{con};
           
        // ===============================
        // STEP 2: Create Child Records
        // (NO Name field because AutoNumber)
        // ===============================        
        Education_Details__c edu = new Education_Details__c();        
        Employment_Details__c emp = new Employment_Details__c();        
        Publications_Patents__c pub = new Publications_Patents__c();        
        List<Education_Details__c> eduList = new List<Education_Details__c>{edu};
        List<Employment_Details__c> empList = new List<Employment_Details__c>{emp};
        List<Publications_Patents__c> pubList = new List<Publications_Patents__c>{pub};        
        // ===============================
        // EXECUTE METHOD
        // ===============================
        Test.startTest();        
        String result = Proposal_Controller.insertContactDetails(contactList,eduList,empList,pubList);     
        String result3 = Proposal_Controller.insertCurriculumDetails(
            new List<Contact>{con},
            new List<Education_Details__c>{edu},
            new List<Employment_Details__c>{emp},
            new List<Publications_Patents__c>{pub}
        );
         List<Contact> result2 =
            Proposal_Controller.getCurriculumDetails('HASHCURR');
         
        String result4 = Proposal_Controller.LogoutApplicant('HASHCURR');

        
        Test.stopTest();        
        
    }
    
    @isTest
    public static void testGetContactDetails() {
        
        // ===============================
        // STEP 1: Create Yearly Call (if required)
        // ===============================
        YealyCall__c yc = new YealyCall__c();
        insert yc;        
        // ===============================
        // STEP 2: Create Proposal
        // ===============================
        Id rtId = [SELECT Id FROM RecordType WHERE SobjectType = 'Application_Proposal__c' AND DeveloperName = 'Industrial_Fellowships'LIMIT 1].Id;
        Application_Proposal__c proposal = new Application_Proposal__c(Title_Of__c = 'Test Proposal',RecordTypeId = rtId,yearly_Call__c = yc.Id);
        insert proposal;        
        // ===============================
        // STEP 3: Create Contact
        // ===============================
        Contact con = new Contact(LastName = 'Test Contact',Login_Hash_Code__c = 'HASHCONTACT',Email = 'karthikke129+test@gmail.com');
        insert con;        
        // ===============================
        // STEP 4: Create Child Records
        // ===============================        
        // Education (AutoNumber → no Name)
        Education_Details__c edu = new Education_Details__c(Contact__c = con.Id);
        // Employment
        Employment_Details__c emp = new Employment_Details__c(Contact__c = con.Id);        
        // Publications
        Publications_Patents__c pub = new Publications_Patents__c(Contact__c = con.Id);        
        insert new List<SObject>{edu, emp, pub};        
        // ===============================
        // STEP 5: Attachment
        // ===============================
        Attachment att = new Attachment(Name = 'Test File',ParentId = con.Id,Body = Blob.valueOf('Test Data'));
        insert att;        
        // ===============================
        // STEP 6: APA (Junction)
        // ===============================
        Applicant_Proposal_Association__c apa = new Applicant_Proposal_Association__c(Contact__c = con.Id,Proposals__c = proposal.Id);
        insert apa;        
        // ===============================
        // EXECUTE METHOD
        // ===============================
        Test.startTest();        
        Contact result = Proposal_Controller.getContactDetails('HASHCONTACT');        
        Test.stopTest();        
        
    }
    
    @isTest
    public static void testGetCvDetails() {        
        // Create Contact
        Contact con = new Contact(LastName = 'CV Test',Email = 'karthikke129+test@gmail.com');
        insert con;        
        // Create child records (AutoNumber → no Name)
        Education_Details__c edu = new Education_Details__c(Contact__c = con.Id);
        Employment_Details__c emp = new Employment_Details__c(Contact__c = con.Id);        
        Publications_Patents__c pub = new Publications_Patents__c(Contact__c = con.Id);        
        insert new List<SObject>{edu, emp, pub};        
        Test.startTest();        
        Contact result = Proposal_Controller.getCvDetails(con.Id);        
        Test.stopTest();        
       
        
}
    
    @isTest
    public static void testGetCompanyApplicantDetails() {        
        // Create Account
        Account acc = new Account(Name = 'Company Test');
        insert acc;        
        // Create Contact linked to Account
        Contact con = new Contact(LastName = 'Applicant',Login_Hash_Code__c = 'HASHCOMPANY',AccountId = acc.Id,Email='karthikke129+test@gmail.com');
        insert con;        
        Test.startTest();        
        Account result = Proposal_Controller.getCompanyApplicantDetails('HASHCOMPANY');        
        Test.stopTest();        
        
}
    
    @isTest
    public static void testInsertApplicant() {        
        // Create Account
        Account acc = new Account(Name = 'Insert Applicant',NumberOfEmployees = 50);        
        Test.startTest();        
        Account result = Proposal_Controller.insertApplicant(acc);        
        Test.stopTest();        
        
}
    
    @isTest
    public static void testGetProjectDetailsDetails() {    
        // ===============================
        // STEP 1: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(Title_Of__c = 'Test Proposal');
        insert proposal;        
        // ===============================
        // STEP 2: Create Account
        // ===============================
        Account acc = new Account(Name = 'Test Account',BillingCountry = 'India');
        insert acc;        
        // ===============================
        // STEP 3: Create Contact
        // ===============================
        Contact con = new Contact(LastName = 'Test Contact',AccountId = acc.Id,Email = 'karthikke129+test@gmail.com',Login_Hash_Code__c = 'HASHPROJECT');
        insert con;        
        // ===============================
        // STEP 4: Create APA
        // ===============================
        Applicant_Proposal_Association__c apa = new Applicant_Proposal_Association__c(Contact__c = con.Id,Proposals__c = proposal.Id);
        insert apa;        
        // ===============================
        // STEP 5: Create Financial Contribution
        // ===============================
        Financial_Contribution__c fc = new Financial_Contribution__c(Account__c = acc.Id);
        insert fc;        
        // ===============================
        // EXECUTE METHOD
        // ===============================
        Test.startTest();        
        List<Applicant_Proposal_Association__c> result =Proposal_Controller.getProjectDetailsDetails(proposal.Id);
        Test.stopTest();
        
       
    }
    
    @isTest
    public static void testInsertFinancialDetails_Success() {    
        // ===============================
        // STEP 1: Create Parent Data (if required)
        // ===============================
        Account Acc = new Account(Name = 'Test Account',BillingCountry = 'India');
        insert Acc;    
        // ===============================
        // STEP 2: Create Financial Record
        // ===============================
        Financial_Contribution__c fc = new Financial_Contribution__c(Account__c=Acc.Id);
        
        List<Financial_Contribution__c> fcList = new List<Financial_Contribution__c>{fc};
        
        // ===============================
        // EXECUTE METHOD
        // ===============================
        Test.startTest();        
        String result = Proposal_Controller.insertFinancialDetails(fcList);        
        Test.stopTest();        
      
     
    }
    
    @isTest
    public static void testInsertProjectDetails_Success() {    
        // ===============================
        // STEP 1: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(Title_Of__c = 'Test Project');        
        // ===============================
        // EXECUTE METHOD
        // ===============================
        Test.startTest();    
        String result = Proposal_Controller.insertProjectDetails(proposal);    
        Test.stopTest();        
             
       
}
    
    @isTest
    public static void testGetProjectdetils() {        
        // ===============================
        // STEP 1: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(Title_Of__c = 'Test Project');
        insert proposal;        
        // ===============================
        // EXECUTE METHOD
        // ===============================
        Test.startTest();        
        // CASE 1: Valid proposalId
        Application_Proposal__c result1 = Proposal_Controller.getProjectdetils(proposal.Id);
        // CASE 2: Blank proposalId
        Application_Proposal__c result2 = Proposal_Controller.getProjectdetils(null);
        Test.stopTest();        
        
    }
    
    @isTest
    public static void testDoCUploadAttachment() {        
        // ===============================
        // STEP 1: Create Parent Record (udId)
        // ===============================
        Account acc = new Account(Name = 'File Test Account');
        insert acc;        
        // Base64 string
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf('Test File Content'));        
        Test.startTest();        
        // ===============================
        // CASE 1: ERROR (blank body)
        // ===============================
        String errorResult = Proposal_Controller.doCUploadAttachment(null, 'file.txt', null, acc.Id);        
        System.assertEquals('ERROR', errorResult);        
        // ===============================
        // CASE 2: NEW FILE UPLOAD
        // ===============================
        String newCvId = Proposal_Controller.doCUploadAttachment(base64Data,'file.txt',null,acc.Id);        
               
        // Verify ContentVersion created
        ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :newCvId];        
               
        // ===============================
        // CASE 3: UPDATE EXISTING FILE
        // ===============================
        String updatedCvId = Proposal_Controller.doCUploadAttachment(base64Data,'file.txt',newCvId,acc.Id);        
        Test.stopTest();        
       
 }
    
	@isTest
    public static void testCreateUserDocument() {    
        // ===============================
        // STEP 1: Create Contact
        // ===============================
        Contact con = new Contact(LastName = 'Test User',Email = 'karthikke129+test@gmail.com');
        insert con;    
        // ===============================
        // STEP 2: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(Title_Of__c = 'Test Proposal');
        insert proposal;    
        // ===============================
        // EXECUTE METHOD
        // ===============================
        Test.startTest();    
        String udId = Proposal_Controller.createUserDocument(null,con.Id,proposal.Id,null);    
        Test.stopTest();        
        
}

    @isTest
    public static void testCreateUserDocumentPecfarDoc() {        
        // ===============================
        // STEP 1: Create Contact
        // ===============================
        Contact con = new Contact(LastName = 'Test User 2',Email = 'karthikke129+test@gmail.com');
        insert con;        
        // ===============================
        // STEP 2: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(Title_Of__c = 'Test Proposal 2');
        insert proposal;
        // ===============================
        // EXECUTE METHOD
        // ===============================
        Test.startTest();        
        String udId = Proposal_Controller.createUserDocumentPecfarDoc(null,con.Id,proposal.Id,null);
        Test.stopTest();        
        
}
    
    @isTest
    public static void testGetWorkPackageDetails() {        
        // ===============================
        // STEP 1: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(Title_Of__c = 'WP Proposal');
        insert proposal;        
        // ===============================
        // STEP 2: Create Account
        // ===============================
        Account acc = new Account(Name = 'WP Account',Proposals__c = proposal.Id);
        insert acc;        
        // ===============================
        // STEP 3: Create Contact
        // ===============================
        Contact con = new Contact(LastName = 'WP Contact',Login_Hash_Code__c = 'HASHWP',AccountId = acc.Id,Email = 'karthikke129+test@gmail.com',Proposals__c = proposal.Id);
        insert con;        
        // ===============================
        // STEP 4: (Optional) Create Work Package
        // ===============================
        Work_Package__c wp = new Work_Package__c(Account__c = acc.Id);
        insert wp;        
        // ===============================
        // EXECUTE METHOD
        // ===============================
        Test.startTest();        
        List<Account> result = Proposal_Controller.getWorkPackageDetails('HASHWP');        
        Test.stopTest();        
        
}
    
    @isTest
    public static void testGetProjectDetailsForPI() {        
        // ===============================
        // STEP 1: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(Title_Of__c = 'PI Proposal');
        insert proposal;        
        // ===============================
        // STEP 2: Create Account
        // ===============================
        Account acc = new Account(Name = 'PI Account',Proposals__c = proposal.Id);
        insert acc;        
        // ===============================
        // STEP 3: Create Contact
        // ===============================
        Contact con = new Contact(LastName = 'PI Contact',Login_Hash_Code__c = 'HASHPI',AccountId = acc.Id,Email = 'karthikke129+test@gmail.com',Proposals__c = proposal.Id);
        insert con;        
        // ===============================
        // STEP 4: Create Deliverable
        // ===============================
          Work_Package__c wp = new Work_Package__c(Account__c = acc.Id);
        insert wp;
        PI_Deliverables__c pi = new PI_Deliverables__c(Work_Package__c=wp.Id,Title__c = 'Deliverable 1',Account__c = acc.Id,Due_Date__c = Date.today());
        insert pi;        
        // ===============================
        // EXECUTE METHOD
        // ===============================
        Test.startTest();        
        List<Account> result = Proposal_Controller.getProjectDetailsForPI('HASHPI');        
        Test.stopTest();        
        
}
    
    @isTest
    public static void testInsertDeliverables() {        
        // ===============================
        // STEP 1: Create Account
        // ===============================
        Account acc = new Account(Name = 'PI Account Insert');
        insert acc;        
        // ===============================
        // STEP 2: Create Wrapper Data
        // ===============================
        Proposal_Controller.PiWrapper wrap = new Proposal_Controller.PiWrapper();     
        List<Proposal_Controller.PiWrapper> wrapList = new List<Proposal_Controller.PiWrapper>{wrap};        
        // ===============================
        // EXECUTE METHOD
        // ===============================
        Test.startTest();        
        String result = Proposal_Controller.insertDeliverables(wrapList);        
        Test.stopTest();
        
       
}

	@isTest
    public static void testGetApplicantDetailsForGrant_New() {        
        // Create Proposal
        Application_Proposal__c proposal = new Application_Proposal__c(Title_Of__c = 'Grant Proposal');
        insert proposal;        
        // Create Account
        Account acc = new Account(Name = 'Grant Account',Proposals__c = proposal.Id);
        insert acc;        
        // Create Contact
        Contact con = new Contact(LastName = 'Grant Contact',Email = 'karthikke129+test@gmail.com',AccountId = acc.Id);
        insert con;        
        // Create APA
        Applicant_Proposal_Association__c apa = new Applicant_Proposal_Association__c(Contact__c = con.Id,Proposals__c = proposal.Id);
        insert apa;        
        // Create Existing Grant
        Existing_Grants__c grant = new Existing_Grants__c(Title__c = 'Grant 1',Account__c = acc.Id);
        insert grant;
        
        Test.startTest();        
        List<Account> result = Proposal_Controller.getApplicantDetailsForGrant(apa.Id,proposal.Id);        
        Test.stopTest(); 
        
       
}    
    
    @isTest
    public static void testInsertExistingGrants() {        
        // Create Account
        Account acc = new Account(Name = 'Grant Insert Account');
        insert acc;        
        // Create Proposal
        Application_Proposal__c proposal = new Application_Proposal__c(Title_Of__c = 'Grant Proposal');
        insert proposal;        
        // Create Contact + APA
        Contact con = new Contact(LastName = 'Test', AccountId = acc.Id,Email = 'karthikke129+test@gmail.com');
        insert con;        
        Applicant_Proposal_Association__c apa = new Applicant_Proposal_Association__c(Contact__c = con.Id,Proposals__c = proposal.Id);
        insert apa;        
        // Wrapper
        Proposal_Controller.ExistingGrantsWrapper wrap = new Proposal_Controller.ExistingGrantsWrapper();   
        
        Test.startTest();        
        String result = Proposal_Controller.insertExistingGrants(new List<Proposal_Controller.ExistingGrantsWrapper>{wrap},apa.Id);
        Test.stopTest();        
               
        
}
    
    @isTest
    public static void testInsertExistingGrantsAsDraft() {    
        // Create Account
        Account acc = new Account(Name = 'Draft Account');
        insert acc;    
        // Create Proposal
        Application_Proposal__c proposal = new Application_Proposal__c(Title_Of__c = 'Draft Proposal');
        insert proposal;    
        // Wrapper
        Proposal_Controller.ExistingGrantsWrapper wrap = new Proposal_Controller.ExistingGrantsWrapper();
        
        Test.startTest();    
        String result = Proposal_Controller.insertExistingGrantsAsDraft(new List<Proposal_Controller.ExistingGrantsWrapper>{wrap});
        Test.stopTest();
        
       
}
      
    @isTest
    public static void testFinalSubmitWiser() {    
        // ===============================
        // STEP 1: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(Title_Of__c = 'Final Submit Proposal');
        insert proposal;    
        // ===============================
        // STEP 2: Create Contacts
        // ===============================
        Contact con1 = new Contact(LastName = 'Coordinator',Email = 'karthikke129+test@gmail.com');
        Contact con2 = new Contact(LastName = 'Partner',Email = 'karthikke129+test2@gmail.com');
        insert new List<Contact>{con1, con2};
        
        // ===============================
        // STEP 3: Create APA Records
        // ===============================
        Applicant_Proposal_Association__c apa1 = new Applicant_Proposal_Association__c(Contact__c = con1.Id,Proposals__c = proposal.Id,Is_Coordinator__c = true,Is_Signatory__c = false,Applicant_Status__c = 'Draft');
        Applicant_Proposal_Association__c apa2 = new Applicant_Proposal_Association__c(Contact__c = con2.Id,Proposals__c = proposal.Id,Is_Coordinator__c = false,Is_Signatory__c = false,Applicant_Status__c = 'Draft');
        insert new List<Applicant_Proposal_Association__c>{apa1, apa2};
        
        Test.startTest();    
        // ===============================
        // CASE 1: Non-Coordinator submits
        // ===============================
        Proposal_Controller.FinalSubmitResponse res1 = Proposal_Controller.finalSubmitWiser(proposal.Id,con2.Id,apa2.Id,10, 5, 2026);
        System.assertEquals(true, res1.isCurrentUserSubmitted);
        System.assertEquals(false, res1.isProposalCompleted);
        
        // ===============================
        // CASE 2: Coordinator submits but NOT all submitted
        // (reset second APA to Draft)
        // ===============================
        update new Applicant_Proposal_Association__c(Id = apa2.Id,Applicant_Status__c = 'Draft');    
        Proposal_Controller.FinalSubmitResponse res2 = Proposal_Controller.finalSubmitWiser(proposal.Id,con1.Id,apa1.Id,10, 5, 2026);
        
        System.assertEquals(true, res2.isCurrentUserSubmitted);
        System.assertEquals(false, res2.isProposalCompleted);
        
        // ===============================
        // CASE 3: Both submitted → FINAL SUBMISSION
        // ===============================
        update new Applicant_Proposal_Association__c(Id = apa2.Id,Applicant_Status__c = 'Submitted');    
        Proposal_Controller.FinalSubmitResponse res3 =Proposal_Controller.finalSubmitWiser(proposal.Id,con1.Id,apa1.Id,10, 5, 2026);
        
        String result1 = Proposal_Controller.insertWiserDraft(proposal.Id,10, 5, 2026); 
        String result2 = Proposal_Controller.insertWiserDraft(proposal.Id,0, 0, 0);  
        String result3 = Proposal_Controller.insertPrivacyPolicy(proposal);    
        String result4 = Proposal_Controller.finalSubmit(proposal); 
       // String result5 = Proposal_Controller.createAnotherCoord(proposal.Id);        

       



        
        Test.stopTest();
        
       
}
    
    @isTest
    public static void testDeleteGrants() {    
        // ===============================
        // STEP 1: Create Account
        // ===============================
        Account acc = new Account(Name = 'Grant Account');
        insert acc;    
        // ===============================
        // STEP 2: Create Grant
        // ===============================
        Existing_Grants__c grant = new Existing_Grants__c(Account__c = acc.Id);
        insert grant;
        
        // ===============================
        // EXECUTE METHOD
        // ===============================
        Test.startTest();    
        Proposal_Controller.deleteGrants(grant.Id);    
        Test.stopTest();
       
}
    
    @isTest
    public static void testFetchProjectDetails() {    
        // ===============================
        // STEP 1: Create Campaign
        // ===============================
        Campaign camp = new Campaign(Name = '2+2 Call');
        insert camp;    
        // ===============================
        // STEP 2: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(Title_Of__c = 'Test Proposal',Campaign__c = camp.Id);
        insert proposal;    
        // ===============================
        // STEP 3: Create Contacts
        // ===============================
        Contact con = new Contact(LastName = 'Test',Proposals__c = proposal.Id,MailingCountry = 'India',Email = 'karthikke129+test@gmail.com');
        insert con;    
        // ===============================
        // STEP 4: Create Attachment
        // ===============================
        Attachment att = new Attachment(Name = 'test.pdf',ParentId = proposal.Id,Body = Blob.valueOf('Test File'));
        insert att;    
        // ===============================
        // EXECUTE METHOD
        // ===============================
        Test.startTest();    
        Proposal_Controller.MyProposalWapper result = Proposal_Controller.fetchProjectDetails(proposal.Id);
        Test.stopTest();    
       
}
    
    @isTest
    public static void testGetCoordinatorsDetails() {
        
        // ===============================
        // STEP 1: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Coordinator Proposal'
        );
        insert proposal;
        
        // ===============================
        // STEP 2: Create Account
        // ===============================
        Account acc = new Account(Name = 'Coordinator Account');
        insert acc;
        
        // ===============================
        // STEP 3: Create Contacts
        // ===============================
        
        // Main contact (used for hash lookup)
        Contact con1 = new Contact(
            LastName = 'Main Contact',
            Login_Hash_Code__c = 'HASHCOORD',
            Proposals__c = proposal.Id,
            Email = 'karthikke129+test2@gmail.com',
            AccountId = acc.Id
        );
        
        // Another contact under same proposal
        Contact con2 = new Contact(
            LastName = 'Coordinator 2',
            Proposals__c = proposal.Id,
            Email = 'karthikke129+test2@gmail.com',
            AccountId = acc.Id
        );
        
        insert new List<Contact>{con1, con2};
        
        // ===============================
        // EXECUTE METHOD
        // ===============================
        Test.startTest();    
        List<Contact> result = Proposal_Controller.getCoordinatorsDetails('HASHCOORD');    
        Test.stopTest();
      
}
    
    @isTest
    public static void testCreateAnotherCoord() {
        
        // ===============================
        // STEP 1: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Another Coord Proposal'
        );
        insert proposal;
        
        // ===============================
        // EXECUTE METHOD
        // ===============================
        Test.startTest();        
        String result = Proposal_Controller.createAnotherCoord(proposal.Id);        
        Test.stopTest();
        
        
}
    
    @isTest
    public static void testGetCoordDetails() {
        
        // ===============================
        // STEP 1: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Coord Details Proposal'
        );
        insert proposal;
        
        // ===============================
        // STEP 2: Create Account
        // ===============================
        Account acc = new Account(
            Name = 'Coord Account',
            BillingCountry = 'India'
        );
        insert acc;
        
        // ===============================
        // STEP 3: Create Contacts
        // ===============================
        Contact con1 = new Contact(
            LastName = 'Coord 1',
            Email = 'karthikke129+test@gmail.com',
            AccountId = acc.Id,
            Proposals__c = proposal.Id
        );
        
        Contact con2 = new Contact(
            LastName = 'Coord 2',
            Email = 'karthikke129+test2@gmail.com',
            AccountId = acc.Id,
            Proposals__c = proposal.Id
        );
        
        insert new List<Contact>{con1, con2};
        
        // ===============================
        // EXECUTE METHOD
        // ===============================
        Test.startTest();        
        List<Contact> result = Proposal_Controller.getCoordDetails(proposal.Id);        
        Test.stopTest();
        
}
    
    @isTest
    public static void testInsertCoordinatorsInformation() {
        
        // ===============================
        // STEP 1: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Coordinator Info Proposal'
        );
        insert proposal;
        
        // ===============================
        // STEP 2: Prepare Accounts
        // ===============================
        Account acc1 = new Account(
            Name = 'Acc1',
            Is_Coordinator__c = true,
            State__c = 'Karnataka'
        );
        
        Account acc2 = new Account(
            Name = 'Acc2',
            Is_Coordinator__c = false
        );
        
        List<Account> accList = new List<Account>{acc1, acc2};
        
        // ===============================
        // STEP 3: Prepare Contacts
        // ===============================
        Contact con1 = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email ='karthikke129@gmail.com',
            AccountId = acc1.Id// intentionally using Name (matches your logic)
        );
        
        // Missing LastName → should fallback to FirstName
        Contact con2 = new Contact(
            FirstName = 'Jane',
            LastName = 'Doess',
            Email ='karthikke129@gmail.com',
            AccountId = acc2.Id
        );
        
        List<Contact> conList = new List<Contact>{con1, con2};
        
        // ===============================
        // EXECUTE METHOD
        // ===============================
        Test.startTest();        
        String result = Proposal_Controller.insertCoordinatorsInformation(proposal.Id,accList,conList);        
        Test.stopTest();       
        
        
}

	@isTest
    public static void testInsertCoordinatorsInformation2() {
        
        // ===============================
        // STEP 1: Create Campaign (for ELSE case)
        // ===============================
        Campaign camp = new Campaign(Name = 'Workshop');
        insert camp;
        
        // ===============================
        // STEP 2: Get RecordType (Workshop)
        // ===============================
        Id rtId = Schema.SObjectType.Application_Proposal__c
            .getRecordTypeInfosByName()
            .get('Workshop')
            .getRecordTypeId();
        
        // ===============================
        // STEP 3: Create Existing Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Existing Proposal',
            RecordTypeId = rtId,
            Campaign__c = camp.Id
        );
        insert proposal;
        
        // ===============================
        // STEP 4: Create Accounts
        // ===============================
        Account acc1 = new Account(Name = 'Acc1', Is_Coordinator__c = true);
        Account acc2 = new Account(Name = 'Acc2', Is_Coordinator__c = false);
        
        List<Account> accList = new List<Account>{acc1, acc2};
        
        // ===============================
        // STEP 5: Create Contacts
        // (AccountId initially holds NAME as per your logic)
        // ===============================
        Contact con1 = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'karthikke129+test@gmail.com',
            AccountId = acc1.Id
        );
        
        Contact con2 = new Contact(
            FirstName = 'Jane',
             LastName = 'Doee',
             Email = 'karthikke129+test2@gmail.com',
            AccountId = acc2.Id // no last name → fallback
        );
        
        List<Contact> conList = new List<Contact>{con1, con2};
        
        // ===============================
        // STEP 6: Existing APA (for CASE 1)
        // ===============================
        insert accList;
        insert conList;
        
        Applicant_Proposal_Association__c apa = new Applicant_Proposal_Association__c(
            Contact__c = con1.Id,
            Proposals__c = proposal.Id,
            Is_Coordinator__c = true
        );
        insert apa;
        
        Test.startTest();
        
        // ===============================
        // CASE 1: Proposal EXISTS
        // ===============================
        Proposal_Controller.insertApplicationWrapper res1 =
            Proposal_Controller.insertCoordinatorsInformation2(
                accList,
                conList,
                proposal.Id,
                null
            );
        
       
        // ===============================
        // CASE 2: Proposal DOES NOT EXIST
        // ===============================
        Proposal_Controller.insertApplicationWrapper res2 =
            Proposal_Controller.insertCoordinatorsInformation2(
                accList,
                conList,
                null,
                null
            );
        
        Test.stopTest();
       
        
}
    
    @isTest
    public static void testGetBasicDetails() { 
          // ===============================
        // STEP 2: Get RecordType (Workshop)
        // ===============================
        Id rtId = Schema.SObjectType.Application_Proposal__c
            .getRecordTypeInfosByName()
            .get('Workshop')
            .getRecordTypeId();
        
        // ===============================
        // STEP 3: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Basic Details Test',
               RecordTypeId = rtId
        );
        insert proposal;
        
        Test.startTest();
        
        // ===============================
        // CASE 1: Valid proposalId
        // ===============================
        Application_Proposal__c result = Proposal_Controller.getBasicDetails(proposal.Id);
        
        // ===============================
        // CASE 2: Blank proposalId
        // ===============================
        Application_Proposal__c blankResult =Proposal_Controller.getBasicDetails(null);
        
        Test.stopTest();
        
        
}
    
    @isTest
    public static void testInsertBasicDetails2() {
        
        // ===============================
        // STEP 1: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Basic2 Test'
        );
        insert proposal;
        
        Account acc = new Account(Name = 'Basic Account');
        insert acc;
        
        // ===============================
        // STEP 2: Create Contact
        // ===============================
        Contact con = new Contact(
            LastName = 'Test',
            AccountId = acc.Id,
            Email = 'karthikke129+test@gmail.com'
        );
        insert con;
        
        // ===============================
        // STEP 3: Prepare input object
        // ===============================
        Application_Proposal__c updateProposal = new Application_Proposal__c();
        
        Test.startTest();
        String proposalId = Proposal_Controller.insertBasicDetails(
            updateProposal,
            1, 1, 2026,
            10, 1, 2026,
            con.Id,
            'Workshop'
        );
        
        // ===============================
        // CASE 1: Valid input
        // ===============================
        String result = Proposal_Controller.insertBasicDetails2(
            updateProposal,
            10, 5, 2026,
            15, 5, 2026,
            con.Id,
            proposal.Id,
            'Workshop'
        );
        
        Test.stopTest();
    
       
}
  
    @isTest
    public static void testInsertParticipants_WithProposalId() {
        
        // ===============================
        // STEP 1: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Participants Proposal'
        );
        insert proposal;
        
        // ===============================
        // STEP 2: Prepare Participants
        // ===============================
        Participants__c p1 = new Participants__c(Name = 'P1');
        Participants__c p2 = new Participants__c(Name = 'P2');
        
        List<Participants__c> pList = new List<Participants__c>{p1, p2};
        
        Test.startTest();
        
        // ===============================
        // EXECUTE METHOD
        // ===============================
        
        String result = Proposal_Controller.insertParticipants(pList, proposal.Id);
        String result2 = Proposal_Controller.insertParticipants(pList);
         List<Participants__c> result3 =
            Proposal_Controller.getParticipantDetails(proposal.Id);
        
        // ===============================
        // CASE 2: Blank proposalId
        // ===============================
        List<Participants__c> emptyResult =
            Proposal_Controller.getParticipantDetails(null);
		Proposal_Controller.deleteParticipant(p1.Id);


        
        Test.stopTest();
        
       
        
        
}
     
    @isTest
    public static void testSaveFinancialDetails() {
        
        // ===============================
        // STEP 1: Create Contact
        // ===============================
        Contact con = new Contact(
            LastName = 'Finance Contact',
            Email = 'karthikke129@gmail.com',
             Login_Hash_Code__c = 'HASHFIN'
        );
        insert con;
        
        // ===============================
        // STEP 2: Prepare Financial Records
        // ===============================
        Financial_Contribution__c fc1 = new Financial_Contribution__c(
            Partner__c = con.Id,
            Expanse_Name__c = 'Equipment',
            Total__c = 500
        );
        
        Financial_Contribution__c fc2 = new Financial_Contribution__c(
            Partner__c = con.Id,
            Expanse_Name__c = 'Travel',
            Total__c = 800
        );
        
        List<Financial_Contribution__c> fcList = new List<Financial_Contribution__c>{fc1, fc2};
        
        Test.startTest();
        
        String result = Proposal_Controller.saveFinancialDetails(fcList);
        List<Contact> result2 =
            Proposal_Controller.getAllFinancialDetails('HASHFIN');
        
        
        
        Test.stopTest();
        
}
    
    @isTest
    public static void testGetBankDetails() {
        
        // ===============================
        // STEP 1: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Bank Proposal'
        );
        insert proposal;
        
        // ===============================
        // STEP 2: Create Contact
        // ===============================
        Contact con = new Contact(
            LastName = 'Bank User',
            Login_Hash_Code__c = 'HASHBANK',
            Proposals__c = proposal.Id,
            Email = 'karthikke129@gmail.com'
        );
        insert con;
        
        // ===============================
        // STEP 3: Create Account
        // ===============================
        Account acc = new Account(
            Name = 'Bank Account',
            Proposals__c = proposal.Id
        );
        insert acc;
        
        // ===============================
        // STEP 4: Create Bank Details
        // ===============================
        Bank_Details__c bank = new Bank_Details__c(
            Account__c = acc.Id,
            Bank_Name__c = 'SBI',
            Bank_Account_Number__c = '123456789'
        );
        insert bank;
        
        Test.startTest();
        
        List<Account> result =
            Proposal_Controller.getBankDetails('HASHBANK');    
        Test.stopTest();
        
        
}
    
    @isTest
    public static void testUpsertBankDetails() {
        
        // ===============================
        // STEP 1: Create Account
        // ===============================
        Account acc = new Account(Name = 'Upsert Bank Acc');
        insert acc;
        
        // ===============================
        // STEP 2: Prepare Bank Details
        // ===============================
        Bank_Details__c bank1 = new Bank_Details__c(
            Account__c = acc.Id,
            Bank_Name__c = 'HDFC',
            Bank_Account_Number__c = '11111'
        );
        
        Bank_Details__c bank2 = new Bank_Details__c(
            Account__c = acc.Id,
            Bank_Name__c = 'ICICI',
            Bank_Account_Number__c = '22222'
        );
        
        List<Bank_Details__c> bankList = new List<Bank_Details__c>{bank1, bank2};
        
        Test.startTest();
        
        String result = Proposal_Controller.upsertBankDetails(bankList);
        
        Test.stopTest();
        
        
}

	@isTest
    public static void testGetApplicantDetailsWiser() {
        
        // ===============================
        // STEP 1: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Wiser Proposal'
        );
        insert proposal;
        
        // ===============================
        // STEP 2: Create Contact
        // ===============================
        Contact con = new Contact(
            LastName = 'Wiser User',
            Login_Hash_Code__c = 'HASHWISER',
            Email = 'karthikke129@gmail.com'
        );
        insert con;
        
        Test.startTest();
        
        // ===============================
        // EXECUTE METHOD
        // ===============================
        Proposal_Controller.insertApplicationWrapper result2 =
            Proposal_Controller.insertApplicationWiser(
                proposal,
                con.Id,
                'WISER' // ensure this record type exists
            );
        Application_Proposal__c result =
            Proposal_Controller.getApplicantDetailsWiser(
                'HASHWISER',
                proposal.Id
            );
        
        Test.stopTest();
      
}

	@isTest
    public static void testGetAccountNames() {
        
        // ===============================
        // STEP 1: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Account Names Proposal'
        );
        insert proposal;
        
        // ===============================
        // STEP 2: Create Contact
        // ===============================
        Contact con = new Contact(
            LastName = 'Test User',
            Login_Hash_Code__c = 'HASHACC',
            Proposals__c = proposal.Id,
            Email = 'karthikke129@gmail.com'
        );
        insert con;
        
        // ===============================
        // STEP 3: Create Accounts
        // ===============================
        Account acc1 = new Account(
            Name = 'Account 1',
            Proposals__c = proposal.Id
        );
        
        Account acc2 = new Account(
            Name = 'Account 2',
            Proposals__c = proposal.Id
        );
        
        insert new List<Account>{acc1, acc2};
        
        Test.startTest();
        
        // ===============================
        // EXECUTE METHOD
        // ===============================
        Proposal_Controller controller = new Proposal_Controller();
        
        List<SelectOption> result =
            controller.getAccountNames('HASHACC');
        List<Account> result2 =
            Proposal_Controller.getProposalAccounts(proposal.Id);
        
        
        Test.stopTest();
        
}
    
    @isTest
    public static void testGetWPDetails() {
        
        // ===============================
        // STEP 1: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'WP Proposal'
        );
        insert proposal;
        
        // ===============================
        // STEP 2: Create Account
        // ===============================
        Account acc = new Account(Name = 'WP Account');
        insert acc;
        
        // ===============================
        // STEP 3: Create Work Package
        // ===============================
        Work_Package__c wp = new Work_Package__c(
            Title__c = 'WP1',
            Application__c = proposal.Id,
            Account__c = acc.Id
        );
        insert wp;
        
        Test.startTest();
        
        List<Work_Package__c> result =
            Proposal_Controller.getWPDetails(proposal.Id, null);
        
        Test.stopTest();
        
}
    
    @isTest
    public static void testGetProposalAccounts() {
        
        // ===============================
        // STEP 1: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Account Proposal'
        );
        insert proposal;
        
        // ===============================
        // STEP 2: Create Accounts
        // ===============================
        Account acc1 = new Account(
            Name = 'Acc1',
            Proposals__c = proposal.Id
        );
        
        Account acc2 = new Account(
            Name = 'Acc2',
            Proposals__c = proposal.Id
        );
        
        insert new List<Account>{acc1, acc2};
        
        Test.startTest();
        
        List<Account> result =
            Proposal_Controller.getProposalAccounts(proposal.Id);
        
        Test.stopTest();
       
}

	@isTest
    public static void testGetProposalAccount() {
        
        // ===============================
        // STEP 1: Create Account
        // ===============================
        Account acc = new Account(Name = 'Wrapper Account');
        insert acc;
        
        // ===============================
        // STEP 2: Create Contact
        // ===============================
        Contact con = new Contact(
            LastName = 'Wrapper User',
            Login_Hash_Code__c = 'HASHWRAP',
            Email = 'karthikke129@gmail.com',
            AccountId = acc.Id
        );
        insert con;
        
        // ===============================
        // STEP 3: Create Financial Record
        // ===============================
        Financial_Contribution__c fc = new Financial_Contribution__c(
            Account__c = acc.Id,
            Total__c = 1000
        );
        insert fc;
        
        Test.startTest();
        
        Proposal_Controller.accountWrapper result =
            Proposal_Controller.getProposalAccount('HASHWRAP');
        
        Test.stopTest();
       
}
    
    @isTest
    public static void testGetDeliverablesDetails() {
        
        // ===============================
        // STEP 1: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Deliverable Proposal'
        );
        insert proposal;
        
        // ===============================
        // STEP 2: Create Contact
        // ===============================
        Contact con = new Contact(
            LastName = 'Deliver User',
            Login_Hash_Code__c = 'HASHDEL',
            Proposals__c = proposal.Id,
            Email = 'karthikke129@gmail.com'
        );
        insert con;
        
        // ===============================
        // STEP 3: Create Account
        // ===============================
        Account acc = new Account(Name = 'Deliver Account');
        insert acc;
        
        Work_Package__c wp = new Work_Package__c(Account__c = acc.Id);
        insert wp;
        
        // ===============================
        // STEP 4: Create Deliverable
        // ===============================
        PI_Deliverables__c pi = new PI_Deliverables__c(
            Title__c = 'Deliverable 1',
            Application__c = proposal.Id,
            Work_Package__c=wp.Id,
            Account__c = acc.Id,
            External_Id__c = 'EXT1'
        );
        insert pi;
        
        Test.startTest();
        
        List<PI_Deliverables__c> result =
            Proposal_Controller.getDeliverablesDetails('HASHDEL');
        
        Test.stopTest();
        
        
}   	
	
	@isTest
    public static void testSaveDeliverables() {
        
        // ===============================
        // STEP 1: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Test Proposal'
        );
        insert proposal;
        
        // ===============================
        // STEP 2: Create Account
        // ===============================
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Work_Package__c wp = new Work_Package__c(Account__c = acc.Id);
            insert wp;
        
        // ===============================
        // STEP 3: Create EXISTING Deliverable + Mapping (for delete case)
        // ===============================
        PI_Deliverables__c existingPI = new PI_Deliverables__c(
            Title__c = 'Old Deliverable',
            External_Id__c = 'EXT_DEL',
            Work_Package__c=wp.Id,
            Application__c = proposal.Id
        );
        insert existingPI;
        
        Deliverables_Account_Mapping__c existingMapping =
            new Deliverables_Account_Mapping__c(
                Account__c = acc.Id,
                PI_Deliverables__c = existingPI.Id
            );
        insert existingMapping;
        
        // ===============================
        // STEP 4: Prepare Wrapper
        // ===============================
        Proposal_Controller controller = new Proposal_Controller();
        
        // 🔹 Case 1: CREATE mapping
        Proposal_Controller.AccountListWrapper createWrap =
            new Proposal_Controller.AccountListWrapper();
        createWrap.accnt = acc;
        createWrap.isSelected = true;
        createWrap.accountMappingId = null;
        
        // 🔹 Case 2: DELETE mapping
        Proposal_Controller.AccountListWrapper deleteWrap =
            new Proposal_Controller.AccountListWrapper();
        deleteWrap.accnt = acc;
        deleteWrap.isSelected = false;
        deleteWrap.accountMappingId = existingMapping.Id;
        
        Proposal_Controller.WrapperPIDeliverables wpWrap =
            new Proposal_Controller.WrapperPIDeliverables();
        
        wpWrap.title = 'New Deliverable';
        wpWrap.ExternalId = 'EXT_DEL'; // SAME external id → important!
        wpWrap.day = 1;
        wpWrap.month = 1;
        wpWrap.year = 2026;
        
        wpWrap.AccountListWrapper =
            new List<Proposal_Controller.AccountListWrapper>{
                createWrap,
                deleteWrap
            };
        
        List<Proposal_Controller.WrapperPIDeliverables> wrapperList =
            new List<Proposal_Controller.WrapperPIDeliverables>{wpWrap};
        
        Test.startTest();
        
        String result =
            controller.saveDeliverables(wrapperList, proposal.Id);
        
        Test.stopTest();
        
} 
    
    @isTest
    public static void testDeleteDeliverables() {
        
        // ===============================
        // STEP 1: Create Account
        // ===============================
        Account acc = new Account(Name = 'Delete Account');
        insert acc;
        
        Work_Package__c wp = new Work_Package__c(Account__c = acc.Id);
        insert wp;
        
        // ===============================
        // STEP 2: Create Deliverable
        // ===============================
        PI_Deliverables__c pi = new PI_Deliverables__c(
            Title__c = 'Delete Deliverable',
            Work_Package__c=wp.Id,
            External_Id__c = 'DEL1'
        );
        insert pi;
        
        // ===============================
        // STEP 3: Create Mapping
        // ===============================
        Deliverables_Account_Mapping__c mapRec =
            new Deliverables_Account_Mapping__c(
                Account__c = acc.Id,
                PI_Deliverables__c = pi.Id
            );
        insert mapRec;
        
        Test.startTest();
        
        String result =
            Proposal_Controller.deleteDeliverables(pi.Id);
        
        Test.stopTest();
        
        
}

	@isTest
    public static void testGetMeetingDetails() {
        
        // ===============================
        // STEP 1: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Meeting Proposal'
        );
        insert proposal;
        
        // ===============================
        // STEP 2: Create Contact
        // ===============================
        Contact con = new Contact(
            LastName = 'Meeting User',
            Login_Hash_Code__c = 'HASH_MEET',
            Proposals__c = proposal.Id,
            Email = 'karthikke129@gmail.com'
        );
        insert con;
        
        // ===============================
        // STEP 3: Create Account
        // ===============================
        Account acc = new Account(Name = 'Meeting Account');
        insert acc;
        
        // ===============================
        // STEP 4: Create Network Meeting
        // ===============================
        Network_Meeting__c nm = new Network_Meeting__c(
            Meeting_Agenda__c = 'Agenda 1',
            Proposals__c = proposal.Id,
            Account__c = acc.Id,
            External_Id__c = 'NM1'
        );
        insert nm;
        
        Test.startTest();
        
        List<Network_Meeting__c> result =
            Proposal_Controller.getMeetingDetails('HASH_MEET');
        
        Test.stopTest();
        
        
}

	@isTest
    public static void testSaveMeetingDetails_CreateAndDelete() {
        
        // ===============================
        // STEP 1: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Save Meeting Proposal'
        );
        insert proposal;
        
        // ===============================
        // STEP 2: Create Account
        // ===============================
        Account acc = new Account(Name = 'Meeting Acc');
        insert acc;
        
        // ===============================
        // STEP 3: Existing Meeting + Mapping (for DELETE)
        // ===============================
        Network_Meeting__c existingMeeting = new Network_Meeting__c(
            Meeting_Agenda__c = 'Old Meeting',
            Proposals__c = proposal.Id,
            External_Id__c = 'EXT_MEET'
        );
        insert existingMeeting;
        
        Network_Meeting_Account_Mapping__c existingMap =
            new Network_Meeting_Account_Mapping__c(
                Account__c = acc.Id,
                Network_Meeting__c = existingMeeting.Id
            );
        insert existingMap;
        
        // ===============================
        // STEP 4: Wrapper Setup
        // ===============================
        Proposal_Controller controller = new Proposal_Controller();
        
        // CREATE case
        Proposal_Controller.AccountListWrapper createWrap =
            new Proposal_Controller.AccountListWrapper();
        createWrap.accnt = acc;
        createWrap.isSelected = true;
        createWrap.accountMappingId = null;
        
        // DELETE case
        Proposal_Controller.AccountListWrapper deleteWrap =
            new Proposal_Controller.AccountListWrapper();
        deleteWrap.accnt = acc;
        deleteWrap.isSelected = false;
        deleteWrap.accountMappingId = existingMap.Id;
        
        Proposal_Controller.WrapperNetworkMeetings wrap =
            new Proposal_Controller.WrapperNetworkMeetings();
        
        wrap.meetingAgenda = 'New Meeting';
        wrap.meetingVenue = 'Bangalore';
        wrap.ExternalId = 'EXT_MEET'; // IMPORTANT (same external id)
        wrap.tentativeday = 1;
        wrap.tentativemonth = 1;
        wrap.tentativeyear = 2026;
        wrap.AccountListWrapper =
            new List<Proposal_Controller.AccountListWrapper>{
                createWrap, deleteWrap
            };
        
        List<Proposal_Controller.WrapperNetworkMeetings> wrapperList =
            new List<Proposal_Controller.WrapperNetworkMeetings>{wrap};
        
        Test.startTest();
        
        String result =
            controller.saveMeetingDetailss(wrapperList, proposal.Id);
        
        Test.stopTest();
        
        
}
	
    @isTest
    public static void testDeleteNetworkMeeting() {
        
        // ===============================
        // STEP 1: Create Account
        // ===============================
        Account acc = new Account(Name = 'Delete Meeting Acc');
        insert acc;
        
        // ===============================
        // STEP 2: Create Meeting
        // ===============================
        Network_Meeting__c nm = new Network_Meeting__c(
            Meeting_Agenda__c = 'Delete Meeting',
            External_Id__c = 'DEL_MEET'
        );
        insert nm;
        
        // ===============================
        // STEP 3: Create Mapping
        // ===============================
        Network_Meeting_Account_Mapping__c mapRec =
            new Network_Meeting_Account_Mapping__c(
                Account__c = acc.Id,
                Network_Meeting__c = nm.Id
            );
        insert mapRec;
        
        Test.startTest();
        
        String result =
            Proposal_Controller.deleteNetworkMeeting(nm.Id);
        
        Test.stopTest();
        
}

	@isTest
    public static void testCreateExpenseDeclarationDetails() {
        
        // ===============================
        // STEP 1: Create Account
        // ===============================
        Account acc = new Account(Name = 'Expense Account');
        insert acc;
        
        // ===============================
        // STEP 2: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Expense Proposal'
        );
        insert proposal;
        
        // ===============================
        // STEP 3: Create Contact
        // ===============================
        Contact con = new Contact(
            LastName = 'Expense User',
            Email = 'karthikke129+test@gmail.com'
        );
        insert con;
        
        // ===============================
        // STEP 4: Create APA
        // ===============================
        Applicant_Proposal_Association__c apa =
            new Applicant_Proposal_Association__c(
                Contact__c = con.Id,
                Proposals__c = proposal.Id,
                Is_Coordinator__c = true
            );
        insert apa;
        
        // ===============================
        // STEP 5: Create Expense Categories
        // ===============================
        List<Expense_Category__c> categories = new List<Expense_Category__c>{
            new Expense_Category__c(Name='Manpower', Applicant_Proposal_Association__c=apa.Id),
            new Expense_Category__c(Name='Consumables', Applicant_Proposal_Association__c=apa.Id),
            new Expense_Category__c(Name='Travel', Applicant_Proposal_Association__c=apa.Id),
            new Expense_Category__c(Name='Contingency', Applicant_Proposal_Association__c=apa.Id),
            new Expense_Category__c(Name='Equipment', Applicant_Proposal_Association__c=apa.Id),
            new Expense_Category__c(Name='Overhead', Applicant_Proposal_Association__c=apa.Id),
            new Expense_Category__c(Name='Outsourcing', Applicant_Proposal_Association__c=apa.Id)
        };
        insert categories;
        
        // ===============================
        // STEP 6: Prepare Expense Records
        // ===============================
        Expense_Detail__c exp1 = new Expense_Detail__c(Expense_Category__c = categories[0].Id);
        Expense_Detail__c exp2 = new Expense_Detail__c(Expense_Category__c = categories[1].Id);
        Expense_Detail__c exp3 = new Expense_Detail__c(Expense_Category__c = categories[2].Id);
        Expense_Detail__c exp4 = new Expense_Detail__c(Expense_Category__c = categories[3].Id);
        Expense_Detail__c exp5 = new Expense_Detail__c(Expense_Category__c = categories[4].Id);
        Expense_Detail__c exp6 = new Expense_Detail__c(Expense_Category__c = categories[5].Id);
        Expense_Detail__c exp7 = new Expense_Detail__c(Expense_Category__c = categories[6].Id);
        
        Test.startTest();
        
        // ===============================
        // EXECUTE METHOD
        // ===============================
        String result = Proposal_Controller.createExpenseDeclarationDetails(
            acc.Id,
            new List<Expense_Detail__c>{exp1}, // manpower
            new List<Expense_Detail__c>{exp2}, // consumables
            new List<Expense_Detail__c>{exp5}, // equipment
            new List<Expense_Detail__c>{exp3}, // travel
            new List<Expense_Detail__c>{exp6}, // overhead
            new List<Expense_Detail__c>{exp4}, // contingency
            new List<Expense_Detail__c>{exp7}, // outsourcing
            apa
        );
        
        Test.stopTest();
        
        
}

	@isTest
    public static void testCreateExpenseWithHeadAndLineItems() {
        
        // ===============================
        // STEP 1: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Test Proposal',
            Duration_In_Months_Max_36__c = 30 // → 3 years
        );
        insert proposal;
        
        // ===============================
        // STEP 2: Create Contact
        // ===============================
        Contact con = new Contact(
            LastName = 'Test User',
            Email = 'karthikke129+exp@gmail.com'
        );
        insert con;
        
        // ===============================
        // STEP 3: Create APA
        // ===============================
        Applicant_Proposal_Association__c apa =
            new Applicant_Proposal_Association__c(
                Contact__c = con.Id,
                Proposals__c = proposal.Id,
                Is_Coordinator__c = true
            );
        insert apa;
        
        // ===============================
        // STEP 4: Prepare Expense Line Items
        // ===============================
        Expense_Line_Item__c lineItem = new Expense_Line_Item__c();
        lineItem.Expense_Type__c = 'Manpower';
        lineItem.Description__c = 'Test Desc';
        lineItem.Index__c = 1;
        
        // Important → values for ALL years
        lineItem.Year1_Expense__c = 100;
        lineItem.Year2_Expense__c = 200;
        lineItem.Year3_Expense__c = 300;
        
        List<Expense_Line_Item__c> inputList = new List<Expense_Line_Item__c>{ lineItem };
        
        Test.startTest();
        
        // ===============================
        // EXECUTE METHOD
        // ===============================
        String result = Proposal_Controller.createExpenseWithHeadAndLineItems(
            inputList,
            apa.Id,
            apa
        );
        
        Test.stopTest();
        
        
}
	
	@isTest
	public static void testPopulateCrossYearExpenseValuesForWiser_Direct() {
    
    // ===============================
    // STEP 1: Create Yearly Expense
    // ===============================
    Yearly_Expense__c y1 = new Yearly_Expense__c(Year__c = '1');
    Yearly_Expense__c y2 = new Yearly_Expense__c(Year__c = '2');
    Yearly_Expense__c y3 = new Yearly_Expense__c(Year__c = '3');
    insert new List<Yearly_Expense__c>{y1, y2, y3};
    
    // ===============================
    // STEP 2: Create Expense Heads
    // ===============================
    Expense_Head__c h1 = new Expense_Head__c(Name='Manpower', Yearly_Expense__c = y1.Id);
    Expense_Head__c h2 = new Expense_Head__c(Name='Manpower', Yearly_Expense__c = y2.Id);
    Expense_Head__c h3 = new Expense_Head__c(Name='Manpower', Yearly_Expense__c = y3.Id);
    insert new List<Expense_Head__c>{h1, h2, h3};
    
    // Re-query with relationship (IMPORTANT)
    Map<Id, Expense_Head__c> headMap = new Map<Id, Expense_Head__c>(
        [SELECT Id, Yearly_Expense__r.Year__c FROM Expense_Head__c WHERE Id IN :new List<Id>{h1.Id, h2.Id, h3.Id}]
    );
    
    // ===============================
    // STEP 3: Create Line Items
    // ===============================
    Expense_Line_Item__c li1 = new Expense_Line_Item__c(
        Expense_Head__c = h1.Id,
        Expense_Type__c = 'Manpower',
        Index__c = 1,
        Year1_Expense__c = 100
    );
    
    Expense_Line_Item__c li2 = new Expense_Line_Item__c(
        Expense_Head__c = h2.Id,
        Expense_Type__c = 'Manpower',
        Index__c = 1,
        Year2_Expense__c = 200
    );
    
    Expense_Line_Item__c li3 = new Expense_Line_Item__c(
        Expense_Head__c = h3.Id,
        Expense_Type__c = 'Manpower',
        Index__c = 1,
        Year3_Expense__c = 300
    );
    
    List<Expense_Line_Item__c> lineItems = new List<Expense_Line_Item__c>{li1, li2, li3};
    
    // ===============================
    // EXECUTE PRIVATE METHOD
    // ===============================
    Test.startTest();
    
    Proposal_Controller.populateCrossYearExpenseValuesForWiser(lineItems, headMap);
    
    Test.stopTest();
    
   
}

	@isTest
    public static void testCreateExpenseWithHeadAndLineItemsForWiser() {
    
        // ===============================
        // STEP 1: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Test Proposal',
            Duration_In_Months_Max_36__c = 24
        );
        insert proposal;
    
        // ===============================
        // STEP 2: Create Contact
        // ===============================
        Contact con = new Contact(
            LastName = 'Test User',
            Email ='karthikke129@gmail.com'
        );
        insert con;
    
        // ===============================
        // STEP 3: Create APA
        // ===============================
        Applicant_Proposal_Association__c apa = new Applicant_Proposal_Association__c(
            Contact__c = con.Id,
            Proposals__c = proposal.Id,
            Is_Coordinator__c = true
        );
        insert apa;
    
        // ===============================
        // STEP 4: Create Yearly Expense (optional - method can create)
        // ===============================
        Yearly_Expense__c y1 = new Yearly_Expense__c(
            Year__c = '1',
            Applicant_Proposal_Association__c = apa.Id
        );
        insert y1;
    
        // ===============================
        // STEP 5: Create Expense Head (for UPDATE scenario)
        // ===============================
        Expense_Head__c head = new Expense_Head__c(
            Name = 'Research staff 1',
            Yearly_Expense__c = y1.Id
        );
        insert head;
    
        // ===============================
        // STEP 6: Create Line Items
        // ===============================
    
        // 🔹 Research Staff (UPDATE scenario)
        Expense_Line_Item__c rsItem = new Expense_Line_Item__c(
            Expense_Type__c = 'Research staff 1',
            Expense_Head__c = head.Id,
            Index__c = 1,
            Year1_Expense__c = 100,
            Description__c = 'Positions|Y1Total:100|Y2Total:200|Y3Total:300'
        );
    
        // 🔹 Non Research Staff (CREATE scenario)
        Expense_Line_Item__c travelItem = new Expense_Line_Item__c(
            Expense_Type__c = 'Travel',
            Index__c = 1,
            Year2_Expense__c = 500
        );
    
        List<Expense_Line_Item__c> lineItems = new List<Expense_Line_Item__c>{
            rsItem, travelItem
        };
    
        // ===============================
        // EXECUTE
        // ===============================
        Test.startTest();
    
        String result = Proposal_Controller.createExpenseWithHeadAndLineItemsForWiser(
            lineItems,
            apa.Id,
            apa
        );
        String result2 = Proposal_Controller.deleteResearchStaffByIds(
            new List<String>{ head.Id }
        );
        
         Proposal_Controller.ExpenseHeadLineItemWrapper result3 =
            Proposal_Controller.getExpenseHeadLineItems(apa.Id);
    
    
        Test.stopTest();
    
        
    
}

	@isTest
    public static void testGetExpenseDetails() {
        // ===============================
        // STEP 1: Create Account
        // ===============================
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;
    
        // ===============================
        // STEP 2: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Test Proposal',
            Duration_In_Months_Max_36__c = 24
        );
        insert proposal;
    
        // ===============================
        // STEP 3: Create Contact
        // ===============================
        Contact con = new Contact(
            LastName = 'Test User',
            AccountId = acc.Id,
            Email = 'karthikke129@gmail.com'
        );
        insert con;
    
        // ===============================
        // STEP 4: Create APA
        // ===============================
        Applicant_Proposal_Association__c apa = new Applicant_Proposal_Association__c(
            Contact__c = con.Id,
            Proposals__c = proposal.Id
        );
        insert apa;
    
        // ===============================
        // STEP 5: Create Expense Category
        // ===============================
        Expense_Category__c ec = new Expense_Category__c(
            Name = 'Manpower',
            Applicant_Proposal_Association__c = apa.Id
        );
        insert ec;
    
        // ===============================
        // STEP 6: Create Expense Detail
        // ===============================
        Expense_Detail__c ed = new Expense_Detail__c(
            Expense_Category__c = ec.Id,
            Year1_Expense__c = 100,
            Year2_Expense__c = 200,
            Year3_Expense__c = 300
        );
        insert ed;
    
        // ===============================
        // EXECUTE METHOD
        // ===============================
        Test.startTest();
    
        Proposal_Controller.edWrapper result =
            Proposal_Controller.getExpenseDetails(proposal.Id, con.Id);
		Proposal_Controller.deleteExpenseLineItem(ed.Id);

    
        Test.stopTest();
    
}
    
    @isTest
    public static void testGetExpenseRecords() {
    
        Account acc = new Account(Name = 'Test Acc');
        insert acc;
        
       Id wiserRecordTypeId = [ SELECT Id  FROM RecordType  WHERE SObjectType = 'Application_Proposal__c' AND DeveloperName = 'Two_Plus_Two' LIMIT 1].Id;
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Test Proposal'
        );
        insert proposal;
    
        Expense_Master__c em = new Expense_Master__c(
         
            Account__c = acc.Id,
            Proposals__c = proposal.Id
        );
        insert em;
    
        Yearly_Expense__c ye = new Yearly_Expense__c(
            Year__c = '1',
            Expense_Master__c = em.Id
        );
        insert ye;
    
        Test.startTest();
    
        // 👉 Insert inside startTest to reduce flow issues
        Expense_Head__c eh = new Expense_Head__c(
            Name = 'Man Power',
            Account__c = acc.Id,
            Yearly_Expense__c = ye.Id
            
        );
        insert eh;
    
        List<Expense_Line_Item__c> lineItems = new List<Expense_Line_Item__c>{
            new Expense_Line_Item__c(
                Expense_Head__c = eh.Id,
                Index__c = 1,
                Year1_Expense__c = 100,
                Expense_Type__c = 'Man Power'
            )
        };
        insert lineItems;
    
        List<Expense_Line_Item__c> result =
            Proposal_Controller.getExpenseRecords(proposal.Id);
    
        Test.stopTest();
    
       
}
    
    @isTest
    public static void testGetConsentCheckbox() {
    
        // ===============================
        // STEP 1: Create Account
        // ===============================
        Account acc = new Account(
            Name = 'Test Account',
            Country_Type__c = 'India'
        );
        insert acc;
    
        // ===============================
        // STEP 2: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Test Proposal',
            Privacy_Policy_Accepted__c = true
        );
        insert proposal;
    
        // ===============================
        // STEP 3: Create Contact
        // ===============================
        Contact con = new Contact(
            LastName = 'Test Contact',
            Email = 'karthikke129@gmail.com',
            AccountId = acc.Id,
            Declaration_Sign_Date__c = Date.today(),
            Login_Hash_Code__c = 'HASH123'
        );
        insert con;
    
        // ===============================
        // STEP 4: Create APA (Link Contact + Proposal)
        // ===============================
        Applicant_Proposal_Association__c apa =
            new Applicant_Proposal_Association__c(
                Contact__c = con.Id,
                Proposals__c = proposal.Id
            );
        insert apa;
        
         Application_Proposal__c updateProposal =
            new Application_Proposal__c(Id = proposal.Id);
    
    
        // ===============================
        // EXECUTE METHOD
        // ===============================
        Test.startTest();
    
        Proposal_Controller.ProposalWithContactsDTO result =
            Proposal_Controller.getConsentCheckbox(proposal.Id);
        String result2 = Proposal_Controller.saveAsDraftWorkshop(
            updateProposal,
            'HASH123',
            10, 5, 2026
        ); 
        String result3 = Proposal_Controller.upsertCheckbox(
            updateProposal,
            'dummy',
            1, 1, 2025
        );
    
        Test.stopTest();
    
        
}
        
    @isTest
    public static void testGetProposalPendings() {
    
        // ===============================
        // STEP 1: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Test Proposal'
        );
        insert proposal;
    
        // ===============================
        // STEP 2: Create Account (linked to proposal)
        // ===============================
        Account acc = new Account(
            Name = 'Test Account',
            Proposals__c = proposal.Id,
            Academia__c = true,
            Industry__c = false,
            Country_Type__c = 'India'
        );
        insert acc;
    
        // ===============================
        // STEP 3: Create Child Records
        // ===============================
        Existing_Grants__c grant = new Existing_Grants__c(
            Title__c = 'Grant 1',
            Account__c = acc.Id
        );
        insert grant;
    
        Financial_Contribution__c fc = new Financial_Contribution__c(
           
            Account__c = acc.Id
        );
        insert fc;
    
        // ===============================
        // STEP 4: Work Package
        // ===============================
        Work_Package__c wp = new Work_Package__c(
            Title__c = 'WP1',
            Application__c = proposal.Id,
            Account__c = acc.Id
        );
        insert wp;
    
        // ===============================
        // EXECUTE METHOD
        // ===============================
        Test.startTest();
    
        Proposal_Controller.WrapProposalPendings result =
            Proposal_Controller.getProposalPendings(proposal.Id);
    
        Test.stopTest();
    
    
}
    
    @isTest
    public static void testGetExpenseFromProposal() {
    
        // ===============================
        // STEP 1: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Test Proposal'        
        );
        insert proposal;
    
        // ===============================
        // STEP 2: Create Expense Head
        // ===============================
        Expense_Head__c eh = new Expense_Head__c(
            Name = 'Test Head',
            Proposals__c = proposal.Id
        );
        insert eh;
    
        // ===============================
        // STEP 3: Create Line Item
        // ===============================
        Expense_Line_Item__c eli = new Expense_Line_Item__c(
            Expense_Head__c = eh.Id,
            Description__c = 'Test Line',
            Unit_Price__c = 100,
            Multiplier__c = 2,
            Total_Expense__c = 200
        );
        insert eli;
    
        // ===============================
        // EXECUTE METHOD
        // ===============================
        Test.startTest();
    
        List<Expense_Head__c> result =
            Proposal_Controller.getExpenseFromProposal(proposal.Id);
    
        Test.stopTest();
    
}

	@isTest
    public static void testGetExpenseDetailsOfAccount() {
    
        // ===============================
        // STEP 1: Create Account
        // ===============================
        Account acc = new Account(
            Name = 'Test Account',
            BillingCountry = 'India'
        );
        insert acc;
    
        // ===============================
        // STEP 2: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Test Proposal'
        );
        insert proposal;
    
        // ===============================
        // STEP 3: Create Contact (with hashcode)
        // ===============================
        Contact con = new Contact(
            LastName = 'Test User',
            AccountId = acc.Id,
            Email ='karthikke129@gmail.com',
            Login_Hash_Code__c = 'HASH123',
            Proposals__c = proposal.Id
        );
        insert con;
    
        // ===============================
        // STEP 4: Create Expense Head
        // ===============================
        Expense_Head__c eh = new Expense_Head__c(
            Name = 'Expense Head',
            Account__c = acc.Id,
            Proposals__c = proposal.Id
        );
        insert eh;
    
        // ===============================
        // STEP 5: Create Line Item
        // ===============================
        Expense_Line_Item__c eli = new Expense_Line_Item__c(
            Expense_Head__c = eh.Id,
            Unit_Price__c = 100,
            Multiplier__c = 2,
            Total_Expense__c = 200
        );
        insert eli;
    
        // ===============================
        // EXECUTE METHOD
        // ===============================
        Test.startTest();
    
        List<Proposal_Controller.accWrapper> result =
            Proposal_Controller.getExpenseDetailsOfAccount('HASH123');
    
        Test.stopTest();
    
       
}
    
    @isTest
    public static void testSaveExpenseDetails() {
    
        // ===============================
        // STEP 1: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Save Expense Test'
        );
        insert proposal;
    
        // ===============================
        // STEP 2: Create Expense Head
        // ===============================
        Expense_Head__c eh = new Expense_Head__c(
            Name = 'Test Head'
        );
        insert eh;
    
        // ===============================
        // STEP 3: Create Line Items
        // ===============================
        List<Expense_Line_Item__c> lineItems = new List<Expense_Line_Item__c>{
            new Expense_Line_Item__c(
                Expense_Head__c = eh.Id,
                Index__c = 1,
                Year1_Expense__c = 100
            ),
            new Expense_Line_Item__c(
                Expense_Head__c = eh.Id,
                Index__c = 2,
                Year2_Expense__c = 200
            )
        };
    
        // ===============================
        // EXECUTE
        // ===============================
        Test.startTest();
        String result = Proposal_Controller.saveExpenseDetails(lineItems, proposal);
        Test.stopTest();
    
}

	@isTest
    public static void testDeleteExpenseLineItems() {
    
        // ===============================
        // STEP 1: Create Proposal + Contact + APA
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Delete Test'
        );
        insert proposal;
    
        Contact con = new Contact(
            LastName = 'Test User',
            Email = 'karthikke129@gmail.com'
        );
        insert con;
    
        Applicant_Proposal_Association__c apa =
            new Applicant_Proposal_Association__c(
                Contact__c = con.Id,
                Proposals__c = proposal.Id
            );
        insert apa;
    
        // ===============================
        // STEP 2: Create Yearly Expenses (3 years)
        // ===============================
        List<Yearly_Expense__c> yearlyList = new List<Yearly_Expense__c>{
            new Yearly_Expense__c(Year__c = '1', Applicant_Proposal_Association__c = apa.Id),
            new Yearly_Expense__c(Year__c = '2', Applicant_Proposal_Association__c = apa.Id),
            new Yearly_Expense__c(Year__c = '3', Applicant_Proposal_Association__c = apa.Id)
        };
        insert yearlyList;
    
        // ===============================
        // STEP 3: Create Expense Heads (same name)
        // ===============================
        List<Expense_Head__c> heads = new List<Expense_Head__c>();
        for (Yearly_Expense__c ye : yearlyList) {
            heads.add(new Expense_Head__c(
                Name = 'Travel',
                Yearly_Expense__c = ye.Id
            ));
        }
        insert heads;
    
        // ===============================
        // STEP 4: Create Line Items (same Index)
        // ===============================
        List<Expense_Line_Item__c> lineItems = new List<Expense_Line_Item__c>();
        for (Expense_Head__c eh : heads) {
            lineItems.add(new Expense_Line_Item__c(
                Expense_Head__c = eh.Id,
                Index__c = 1,
                Year1_Expense__c = 100
            ));
        }
        insert lineItems;
    
        // Pick one line item to delete
        Id deleteId = lineItems[0].Id;
    
        // ===============================
        // EXECUTE
        // ===============================
        Test.startTest();
    
        Proposal_Controller.deleteExpenseLineItems(deleteId);
    
        Test.stopTest();
    
}
    
    @isTest
    public static void testInsertFellowshipDetails() {
    
        // ===============================
        // STEP 1: Create Account + Contact
        // ===============================
        Account acc = new Account(Name = 'Test Account');
        insert acc;
    
        Contact con = new Contact(
            LastName = 'Test Contact',
            Email ='karthikke129@gmail.com',
            AccountId = acc.Id
        );
        insert con;
    
        // ===============================
        // STEP 2: Prepare Contact to update
        // ===============================
        Contact proposalDetails = new Contact(
            Id = con.Id
        );
    
        Test.startTest();
    
        String result = Proposal_Controller.insertFellowship_Details(
            proposalDetails,
            1, 1, 2025,   // start date
            10, 1, 2025,  // end date
            con.Id,
            'PECFAR'
        );
    
        Test.stopTest();
    
        
}
    
	@isTest
    public static void testGetPairingDetailsinWiser_WithAPA() {
    
        // ===============================
        // STEP 1: Create Account
        // ===============================
        Account acc = new Account(Name = 'Test Account');
        insert acc;
    
        // ===============================
        // STEP 2: Create Contacts
        // ===============================
        Contact con1 = new Contact(
            LastName = 'User1',
            Login_Hash_Code__c = 'hash123',
            Email = 'karthikke129@gmail.com',
            AccountId = acc.Id
        );
        
        Contact con2 = new Contact(
            LastName = 'User2',
             Email = 'karthikke129+test@gmail.com',
            AccountId = acc.Id
        );
        
        insert new List<Contact>{con1, con2};
    
        // ===============================
        // STEP 3: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Wiser Proposal'
        );
        insert proposal;
    
        // ===============================
        // STEP 4: Create APA records
        // ===============================
        List<Applicant_Proposal_Association__c> apaList = new List<Applicant_Proposal_Association__c>{
            new Applicant_Proposal_Association__c(
                Contact__c = con1.Id,
                Proposals__c = proposal.Id,
                Is_Coordinator__c = true,
                Is_Signatory__c = false
            ),
            new Applicant_Proposal_Association__c(
                Contact__c = con2.Id,
                Proposals__c = proposal.Id,
                Is_Coordinator__c = false,
                Is_Signatory__c = false
            )
        };
        insert apaList;
    
        // ===============================
        // EXECUTE
        // ===============================
        Test.startTest();
    
        List<Proposal_Controller.ContactWithAPAWrapper> result =
            Proposal_Controller.getPairingDetailsinWiser('hash123', proposal.Id);
        List<Proposal_Controller.PairingContactWrapper> result2 =
            Proposal_Controller.getPairingDetails('hash123', null);
    
    
        Test.stopTest();
    
       
}
    
    @isTest
    public static void testGetPairingDetailsinWiser_NoAPA() {
    
        // ===============================
        // STEP 1: Create Contact
        // ===============================
        Contact con = new Contact(
            LastName = 'Solo User',
            Login_Hash_Code__c = 'hash456',
            Email = 'karthikke129@gmail.com'
        );
        insert con;
    
        // ===============================
        // STEP 2: Create Proposal (no APA)
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'No APA Proposal'
        );
        insert proposal;
    
        // ===============================
        // EXECUTE
        // ===============================
        Test.startTest();
    
        List<Proposal_Controller.ContactWithAPAWrapper> result =
            Proposal_Controller.getPairingDetailsinWiser('hash456', proposal.Id);
    
        Test.stopTest();
    
        
}

	@isTest
    public static void testInsertPairingDetails_CreateNewProposal() {
         
         Year__c yr = new Year__c(Name = '2026');
         insert yr;
    
        YealyCall__c ycRec = new YealyCall__c(    
            Years__c = yr.Id
        );
        insert ycRec;
        
          // ===============================
        // STEP 1: Create Logged-in Contact (hashcode)
        // ===============================
        Contact loginCon = new Contact(
            LastName = 'Login User',
            Email = 'karthikke129+test1@gmail.com',
            Login_Hash_Code__c = 'hash123'
        );
        insert loginCon;
    
        // ===============================
        // STEP 2: Prepare Wrapper Data
        // ===============================
        Proposal_Controller.wrapperPairing w1 = new Proposal_Controller.wrapperPairing();
        w1.companyNmae = 'Company A';
        w1.cont = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'karthikke129+test2@gmail.com',
            MailingCountry = 'India'
        );
        w1.birthyear = 1990;
        w1.birthmonth = 1;
        w1.birthday = 1;
    
        Proposal_Controller.wrapperPairing w2 = new Proposal_Controller.wrapperPairing();
        w2.companyNmae = 'Company B';
        w2.cont = new Contact(
            FirstName = 'Jane',
            LastName = 'Smith',
            Email = 'karthikke129+test3@gmail.com',
            MailingCountry = 'Germany'
        );
        w2.birthyear = 1992;
        w2.birthmonth = 2;
        w2.birthday = 2;
    
        List<Proposal_Controller.wrapperPairing> wrapperList =
            new List<Proposal_Controller.wrapperPairing>{w1, w2};
    
        // ===============================
        // EXECUTE
        // ===============================
        Test.startTest();
    
        Proposal_Controller.insertPairingWrapper result =
            Proposal_Controller.insertPairingDetails(
                wrapperList,
                null,           // campaignId
                ycRec.Id,         // yearlyCallId
                'hash123',      // logged-in contact
                null            // projectId → NEW proposal
            );
    
        Test.stopTest();
    
       
}

	@isTest
    public static void testInsertPairingDetails_ExistingProposal() {
    
        // ===============================
        // STEP 0: Yearly Call (MANDATORY FIX)
        // ===============================
        Year__c yr = new Year__c(Name = '2025');
        insert yr;
    
        YealyCall__c yc = new YealyCall__c(
            Years__c = yr.Id
        );
        insert yc;
    
        // ===============================
        // STEP 1: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Existing Proposal'
        );
        insert proposal;
    
        // ===============================
        // STEP 2: Logged-in Contact
        // ===============================
        Contact loginCon = new Contact(
            LastName = 'Login User',
            Email = 'karthikke129+test2@gmail.com',
            Login_Hash_Code__c = 'hash456'
        );
        insert loginCon;
    
        // ===============================
        // STEP 3: Wrapper Data
        // ===============================
        Proposal_Controller.wrapperPairing w = new Proposal_Controller.wrapperPairing();
        w.companyNmae = 'Company X';
        w.cont = new Contact(
            FirstName = 'Existing',
            LastName = 'User',
            Email = 'karthikke129@gmail.com',
            MailingCountry = 'India'
        );
        w.birthyear = 1995;
        w.birthmonth = 5;
        w.birthday = 10;
    
        List<Proposal_Controller.wrapperPairing> wrapperList =
            new List<Proposal_Controller.wrapperPairing>{w};
    
        // ===============================
        // EXECUTE
        // ===============================
        Test.startTest();
    
        Proposal_Controller.insertPairingWrapper result =
            Proposal_Controller.insertPairingDetails(
                wrapperList,
                null,
                yc.Id,        // FIX: pass Yearly Call Id
                'hash456',
                proposal.Id
            );
    
        Test.stopTest();
    
}
    
    @isTest
    public static void testInsertPairingDetailsinWiser_NewProposal() {
    
        // ===============================
        // STEP 1: Create Year + Yearly Call
        // ===============================
        Year__c yr = new Year__c(Name = '2026');
        insert yr;
    
        YealyCall__c yc = new YealyCall__c(
            Years__c = yr.Id
        );
        insert yc;
    
        // ===============================
        // STEP 2: Create Campaign (if required)
        // ===============================
        Campaign camp = new Campaign(Name = 'Test Campaign');
        insert camp;
    
        // ===============================
        // STEP 3: Logged-in Contact (hashcode)
        // ===============================
        Contact loginCon = new Contact(
            LastName = 'Login User',
            Email = 'karthikke129+test@gmail.com',
            Login_Hash_Code__c = 'hash123'
        );
        insert loginCon;
    
        // ===============================
        // STEP 4: Wrapper Data (2 Contacts)
        // ===============================
        Proposal_Controller.wrapperPairing w1 = new Proposal_Controller.wrapperPairing();
        w1.companyNmae = 'Company A';
        w1.cont = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'karthikke129+test2@gmail.com',
            MailingCountry = 'India'
        );
        w1.birthyear = 1990;
        w1.birthmonth = 1;
        w1.birthday = 1;
    
        Proposal_Controller.wrapperPairing w2 = new Proposal_Controller.wrapperPairing();
        w2.companyNmae = 'Company B';
        w2.cont = new Contact(
            FirstName = 'Jane',
            LastName = 'Smith',
            Email = 'karthikke129+test3@gmail.com',
            MailingCountry = 'Germany'
        );
        w2.birthyear = 1992;
        w2.birthmonth = 2;
        w2.birthday = 2;
    
        List<Proposal_Controller.wrapperPairing> wrapperList =
            new List<Proposal_Controller.wrapperPairing>{ w1, w2 };
    
        // ===============================
        // EXECUTE
        // ===============================
        Test.startTest();
    
        Proposal_Controller.insertPairingWrapperinWiser result =
            Proposal_Controller.insertPairingDetailsinWiser(
                wrapperList,
                camp.Id,           // campaignId
                yc.Id,             // MUST be Id (fix)
                null,              // proposalId → create new
                null,              // coordinatorContactId (fallback to first)
                'hash123'          // logged-in hash
            );
    
        Test.stopTest();
    
       
}
  
    @isTest
    public static void testGetPersonalInformation() {

        // ===============================
        // STEP 1: Create Account
        // ===============================
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // ===============================
        // STEP 2: Create Contact
        // ===============================
        Contact con = new Contact(
            FirstName = 'Karthik',
            LastName = 'Test',
            Email = 'karthikke129+test@gmail.com',
            Login_Hash_Code__c = 'hash123',
            AccountId = acc.Id
        );
        insert con;

        // ===============================
        // STEP 3: Add Attachment
        // ===============================
        Attachment att = new Attachment(
            Name = 'TestFile',
            ParentId = con.Id,
            Body = Blob.valueOf('Test Body')
        );
        insert att;

        // ===============================
        // EXECUTE
        // ===============================
        Test.startTest();

        Contact result = Proposal_Controller.getPersonalInformation('hash123');

        Test.stopTest();

       
    }

    @isTest
    public static void testInsertPersonalInfo_WithDate() {

        // ===============================
        // STEP 1: Create Contact
        // ===============================
        Contact con = new Contact(
            FirstName = 'User',
            LastName = 'Test',
            Email = 'karthikke129+test1@gmail.com'
        );
        insert con;

        // ===============================
        // PREPARE UPDATE OBJECT
        // ===============================
        Contact updateCon = new Contact(
            Id = con.Id,
            State__c = 'Karnataka'
        );

        // ===============================
        // EXECUTE
        // ===============================
        Test.startTest();

        String result = Proposal_Controller.insertPersonalInfo(
            updateCon,
            10, 5, 1995   // valid date
        );

        Test.stopTest();
    }

    @isTest
    public static void testInsertPersonalInfo_WithoutDate() {

        // ===============================
        // STEP 1: Create Contact
        // ===============================
        Contact con = new Contact(
            FirstName = 'User2',
            LastName = 'Test2',
            Email = 'karthikke129+test4@gmail.com'
        );
        insert con;

        Contact updateCon = new Contact(
            Id = con.Id,
            State__c = 'Delhi'
        );

        // ===============================
        // EXECUTE (NO DATE CASE)
        // ===============================
        Test.startTest();

        String result = Proposal_Controller.insertPersonalInfo(
            updateCon,
            0, 0, 0   // triggers empty condition
        );

        Test.stopTest();

        
    }

    @isTest
  	public static void testInsertAndGetEmploymentDetails() {

        // ===============================
        // STEP 1: Create Contact
        // ===============================
        Contact con = new Contact(
            LastName = 'Emp Test',
            Email = 'karthikke129@gmail.com'
        );
        insert con;

        // ===============================
        // STEP 2: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Test Proposal'
        );
        insert proposal;

        // ===============================
        // STEP 3: Create APA
        // ===============================
        Applicant_Proposal_Association__c apa =
            new Applicant_Proposal_Association__c(
                Contact__c = con.Id,
                Proposals__c = proposal.Id
            );
        insert apa;

        // ===============================
        // STEP 4: Prepare Employment Data
        // ===============================
        Employment_Details__c emp = new Employment_Details__c(
            Applicant_Proposal_Association__c = apa.Id,
            Contact__c = con.Id
            
        );

        List<Employment_Details__c> empList =
            new List<Employment_Details__c>{ emp };

        // ===============================
        // EXECUTE INSERT
        // ===============================
        Test.startTest();

        String result = Proposal_Controller.insertEmploymentDetailsPECFAR(
            empList,
            apa.Id
        );         

        List<Employment_Details__c> fetched =
            Proposal_Controller.getEmpDetails('dummy', apa.Id);
		Proposal_Controller.deleteEmployment(emp.Id);


        Test.stopTest();

       
    }

    @isTest
  	public static void testGetParentOrgDetails() {

        // ===============================
        // STEP 1: Create Account
        // ===============================
        Account acc = new Account(
            Name = 'Parent Org',
            BillingStreet = 'Street 1',
            BillingCity = 'Bangalore',
            BillingState = 'Karnataka',
            BillingCountry = 'India',
            BillingPostalCode = '560001'
        );
        insert acc;

        // ===============================
        // STEP 2: Create Contact
        // ===============================
        Contact con = new Contact(
            LastName = 'User',
            AccountId = acc.Id,
            Login_Hash_Code__c = 'hash123',
            Email = 'karthikke129@gmail.com',
			Declaration_Sign_Date__c = Date.today()

        );
        insert con;

        // ===============================
        // EXECUTE
        // ===============================
        Test.startTest();
        Contact result1 = Proposal_Controller.getParentOrgDetails('hash123');
        Contact result2 = Proposal_Controller.getDeclarationfields('hash123');
        Contact result3 = Proposal_Controller.getDeclarationfields(con.Id);


        Test.stopTest();

        
    }

    @isTest
    public static void testUpdateconAccDetails() {

        // ===============================
        // STEP 1: Create Account
        // ===============================
        Account acc = new Account(
            Name = 'Update Org',
            BillingState = 'OldState'
        );
        insert acc;

        // ===============================
        // STEP 2: Prepare Update
        // ===============================
        Account updateAcc = new Account(
            Id = acc.Id,
            Shipping_State__c = 'NewState'
        );

        // ===============================
        // EXECUTE
        // ===============================
        Test.startTest();
        String result = Proposal_Controller.updateconAccDetails(updateAcc);
        Test.stopTest();

    }
     
    @isTest
    public static void testUpdateAndGetAchievements() {

        // ===============================
        // STEP 1: Create Contact
        // ===============================
        Contact con = new Contact(
            LastName = 'Ach Test',
            Email = 'karthikke129@gmail.com'
        );
        insert con;

        // ===============================
        // STEP 2: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Achievement Proposal'
        );
        insert proposal;

        // ===============================
        // STEP 3: Create APA
        // ===============================
        Applicant_Proposal_Association__c apa =
            new Applicant_Proposal_Association__c(
                Contact__c = con.Id,
                Proposals__c = proposal.Id
            );
        insert apa;

        // ===============================
        // STEP 4: Prepare Achievement
        // ===============================
        Achievement__c ach = new Achievement__c(
            Contact__c = con.Id,
            Awards_Honours__c = 'Best Researcher'
        );

        // ===============================
        // EXECUTE UPDATE
        // ===============================
        Test.startTest();

        String result = Proposal_Controller.updateAchievements(ach, apa.Id);   

        Achievement__c fetched =
            Proposal_Controller.getAchievements('dummy', apa.Id);

        Test.stopTest();

      
    }


    @isTest
    public  static void testGetAchievements_NoRecord() {

        // ===============================
        // STEP 1: Create Contact + Proposal + APA
        // ===============================
        Contact con = new Contact(LastName = 'No Ach',Email ='karthikke129@gmail.com');
        insert con;

        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'No Ach Proposal'
        );
        insert proposal;

        Applicant_Proposal_Association__c apa =
            new Applicant_Proposal_Association__c(
                Contact__c = con.Id,
                Proposals__c = proposal.Id
            );
        insert apa;

        // ===============================
        // EXECUTE
        // ===============================
        Test.startTest();

        Achievement__c fetched =
            Proposal_Controller.getAchievements('dummy', apa.Id);

        Test.stopTest();

        
    }
      
    @isTest
    public static void testGetDeclarationfieldsinWiser() {

        // Create Contact
        Contact con = new Contact(
            LastName = 'Wiser Test',
            Email = 'karthikke129@gmail.com',
            Login_Hash_Code__c = 'hash456'
        );
        insert con;

        // Create Proposal
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Wiser Proposal'
        );
        insert proposal;

        // Create APA
        Applicant_Proposal_Association__c apa =
            new Applicant_Proposal_Association__c(
                Contact__c = con.Id,
                Proposals__c = proposal.Id,
                Proposed_Date__c = Date.today()
            );
        insert apa;

        Test.startTest();

        Applicant_Proposal_Association__c result =
            Proposal_Controller.getDeclarationfieldsinWiser('hash456', apa.Id);

        Test.stopTest();

    }
       
    @isTest
    public static void testUpsertSign() {

        // ===============================
        // STEP 1: Create Contact
        // ===============================
        Contact con = new Contact(
            LastName = 'Sign Test',
            Email = 'karthikke129@gmail.com'
        );
        insert con;

        // ===============================
        // STEP 2: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Sign Proposal'
        );
        insert proposal;

        // ===============================
        // STEP 3: Create APA
        // ===============================
        Applicant_Proposal_Association__c apa =
            new Applicant_Proposal_Association__c(
                Contact__c = con.Id,
                Proposals__c = proposal.Id
            );
        insert apa;

        // ===============================
        // PREPARE UPDATE CONTACT
        // ===============================
        Contact updateCon = new Contact(Id = con.Id);

        // ===============================
        // EXECUTE
        // ===============================
        Test.startTest();

        String result = Proposal_Controller.upsertSign(
            updateCon,
            1, 1, 2025
        );

        Test.stopTest();

        
    }


    @isTest
    public static void testSubmitPartner2plus2andsubmit2plus2() {

        // ===============================
        // STEP 1: Create Contact
        // ===============================
        Contact con = new Contact(
            LastName = 'Partner Test',
            Email = 'karthikke129@gmail.com'
        );
        insert con;

        // ===============================
        // STEP 2: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Partner Proposal'
        );
        insert proposal;

        // ===============================
        // STEP 3: Create APA
        // ===============================
        Applicant_Proposal_Association__c apa =
            new Applicant_Proposal_Association__c(
                Contact__c = con.Id,
                Proposals__c = proposal.Id,
                Is_Coordinator__c = false
            );
        insert apa;

        // ===============================
        // PREPARE UPDATE CONTACT
        // ===============================
        Contact updateCon = new Contact(Id = con.Id);

        // ===============================
        // EXECUTE
        // ===============================
        Test.startTest();

        String result = Proposal_Controller.submitPartner2plus2(
            updateCon,
            5, 5, 2025,
            proposal.Id
        );
       String result1 = Proposal_Controller.submit2plus2(
            updateCon,
            5, 5, 2025,
            proposal.Id
        );

        Test.stopTest();

   
        
    }    
    
    // ===============================
    // COMMON TEST DATA
    // ===============================
   public static Id createFile(Id parentId) {
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('Test Content'),
            FirstPublishLocationId = parentId
        );
        insert cv;

        // Get ContentDocumentId
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

        // Create ContentDistribution (optional but needed for coverage)
        ContentDistribution cd = new ContentDistribution(
            Name = 'Test Dist',
            ContentVersionId = cv.Id
        );
        insert cd;

        return cv.ContentDocumentId;
    }
    
    @isTest
    public static void testGetReviewerUserDoc() {
    
        // ===============================
        // STEP 1: Create Reviewer (Custom Object)
        // ===============================
        Contact con = new Contact(LastName = 'Reviewer',Email='karthikke129@gmail.com');
        insert con;
    
        // ===============================
        // STEP 2: Create User Document
        // ===============================
        User_Document__c ud = new User_Document__c(
            Contact__c = con.Id, // your logic uses Contact__c
            Status__c = 'Pending'
        );
        insert ud;
    
        // ===============================
        // STEP 3: Create File
        // ===============================
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'test.pdf',
            VersionData = Blob.valueOf('Test Data'),
            FirstPublishLocationId = ud.Id
        );
        insert cv;
    
        // Get ContentDocumentId
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
    
        // ===============================
        // STEP 4: Create ContentDistribution
        // ===============================
        ContentDistribution cd = new ContentDistribution(
            Name = 'Test Dist',
            ContentVersionId = cv.Id,
            RelatedRecordId = ud.Id
        );
        insert cd;
    
        // ===============================
        // EXECUTE
        // ===============================
        Test.startTest();
    
        List<Proposal_Controller.UserDocumentWrapper> result =
            Proposal_Controller.getReviewerUserDoc(con.Id);
    
        Test.stopTest();
    
       
       
}
    
    @isTest
    public static void testGetContactUserDoc() {
    
        // ===============================
        // STEP 1: Create Account + Contact
        // ===============================
        Account acc = new Account(Name = 'Test Acc');
        insert acc;
    
        Contact con = new Contact(
            LastName = 'Test User',
            Email = 'karthikke129@gmail.com',
            AccountId = acc.Id
        );
        insert con;
    
        // ===============================
        // STEP 2: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Test Proposal'
        );
        insert proposal;
    
        // ===============================
        // STEP 3: Create APA
        // ===============================
        Applicant_Proposal_Association__c apa =
            new Applicant_Proposal_Association__c(
                Contact__c = con.Id,
                Proposals__c = proposal.Id,
                Is_Signatory__c = false
            );
        insert apa;
    
        // ===============================
        // STEP 4: Create User Document
        // ===============================
        User_Document__c ud = new User_Document__c(
            Applicant_Proposal_Association__c = apa.Id,
            Status__c = 'Pending'
        );
        insert ud;
    
        // ===============================
        // STEP 5: Create File
        // ===============================
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'test.pdf',
            VersionData = Blob.valueOf('Test Data'),
            FirstPublishLocationId = ud.Id
        );
        insert cv;
    
        // Get ContentDocumentId
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
    
        // ===============================
        // STEP 6: Content Distribution
        // ===============================
        ContentDistribution cd = new ContentDistribution(
            Name = 'Test Dist',
            ContentVersionId = cv.Id,
            RelatedRecordId = ud.Id
        );
        insert cd;
    
        // ===============================
        // EXECUTE
        // ===============================
        Test.startTest();
    
        List<Proposal_Controller.UserDocumentWrapper> result =
            Proposal_Controller.getContactUserDoc(con.Id, proposal.Id);
    
        Test.stopTest();
    
}
        
    @isTest
    public static void testGetAllUserDoc() {

        Contact con = new Contact(LastName = 'User',Email='karthikke129@gmail.com');
        insert con;

        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Proposal'
        );
        insert proposal;

        Applicant_Proposal_Association__c apa =
            new Applicant_Proposal_Association__c(
                Contact__c = con.Id,
                Proposals__c = proposal.Id
            );
        insert apa;

        User_Document__c ud = new User_Document__c(
            Name = 'Doc2',
            Proposals__c = proposal.Id,
            Contact__c = con.Id
        );
        insert ud;

        createFile(ud.Id);

        Test.startTest();
        List<Proposal_Controller.UserDocumentWrapper> result =
            Proposal_Controller.getAllUserDoc(proposal.Id);
        Test.stopTest();

    }


    @isTest
    public static void testGetAllProposalDoc() {

        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Proposal Doc'
        );
        insert proposal;

        Proposal_Document__c pd = new Proposal_Document__c(
            Name = 'PD1',
            Proposals__c = proposal.Id
        );
        insert pd;

        createFile(pd.Id);

        Test.startTest();
        List<Proposal_Controller.ProposalDocumentWrapper> result =
            Proposal_Controller.getAllProposalDoc(proposal.Id);
        Test.stopTest();

    }


    @isTest
    public static void testGetAllUserDocSignature() {

        Contact con = new Contact(
            LastName = 'Sig User',
            Login_Hash_Code__c = 'hash123',
            Email ='karthikke129@gmail.com'
        );
        insert con;

        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Sig Proposal'
        );
        insert proposal;

        Applicant_Proposal_Association__c apa =
            new Applicant_Proposal_Association__c(
                Contact__c = con.Id,
                Proposals__c = proposal.Id
            );
        insert apa;

        User_Document__c ud = new User_Document__c(
            Name = 'DocSig',
            Proposals__c = proposal.Id,
            Contact__c = con.Id
        );
        insert ud;

        createFile(ud.Id);

        Test.startTest();
        List<Proposal_Controller.UserDocumentWrapper> result =
            Proposal_Controller.getAllUserDocSignature('hash123');
        Test.stopTest();

        
    }

    @isTest
    public static void testGetAllUserDocSignatureNEW() {

        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'New Sig Proposal'
        );
        insert proposal;

        User_Document__c ud = new User_Document__c(
            Name = 'DocNew',
            Proposals__c = proposal.Id
        );
        insert ud;

        createFile(ud.Id);

        Test.startTest();
        List<Proposal_Controller.UserDocumentWrapper> result =
            Proposal_Controller.getAllUserDocSignatureNEW(proposal.Id);
        Test.stopTest();

 
    }    
    
    @isTest
    public static void testGetMeetingThemeDetails() {

        // Create Proposal
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Meeting Proposal'
        );
        insert proposal;

        // Parent Meeting Theme (with date)
        Meeting_Theme__c parentTheme = new Meeting_Theme__c(
            Proposals__c = proposal.Id,
            Meeting_Date__c = Date.today(),
            External_Id__c = 'PARENT1'
        );
        insert parentTheme;

        // Child Meeting Theme
        Meeting_Theme__c childTheme = new Meeting_Theme__c(
           
            Meeting_Theme__c = parentTheme.Id,
            External_Id__c = 'CHILD1'
        );
        insert childTheme;

        // Agenda
        Meeting_Agenda__c agenda = new Meeting_Agenda__c(
            Meeting_Theme__c = childTheme.Id
        );
        insert agenda;

        Test.startTest();
        List<Proposal_Controller.MeetingThemeWrapper> result =
            Proposal_Controller.getMeetingThemeDetails(proposal.Id);
        Test.stopTest();

    
    }

    @isTest
    public static void testSaveMeetingDetails() {

        // Create Proposal
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Save Meeting Proposal'
        );
        insert proposal;

        // Parent Theme
        Meeting_Theme__c parentTheme = new Meeting_Theme__c(
           Proposals__c = proposal.Id,
            External_Id__c = 'PARENT_SAVE'
        );

        // Child Theme
        Meeting_Theme__c childTheme = new Meeting_Theme__c(
            External_Id__c = 'CHILD_SAVE'
        );

        // Agenda
        Meeting_Agenda__c agenda = new Meeting_Agenda__c(
          
        );

        // Wrapper Construction
        Proposal_Controller.MeetingDetails md = new Proposal_Controller.MeetingDetails();
        md.meetingTopic = childTheme;
        md.meetingAgenda = new List<Meeting_Agenda__c>{ agenda };

        Proposal_Controller.MeetingThemeWrapper mtw = new Proposal_Controller.MeetingThemeWrapper();
        mtw.meetingTheme = parentTheme;
        mtw.meetingYear = 2025;
        mtw.meetingMonth = 1;
        mtw.MeetingDetailList = new List<Proposal_Controller.MeetingDetails>{ md };

        List<Proposal_Controller.MeetingThemeWrapper> wrapperList =
            new List<Proposal_Controller.MeetingThemeWrapper>{ mtw };

        Test.startTest();
        String result = Proposal_Controller.saveMeetingDetails(wrapperList);
        Test.stopTest();

       
    }
    
    @isTest
    public static void testSaveAsDraftPecfartestFinalSubmitPecfar() {

        // Create Proposal
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Draft Proposal'
        );
        insert proposal;

        // Prepare update record
        Application_Proposal__c updateProposal =
            new Application_Proposal__c(Id = proposal.Id);

        Test.startTest();
        String result = Proposal_Controller.saveAsDraftPecfar(updateProposal);
        String result1 = Proposal_Controller.finalSubmitPecfar(updateProposal);

       
        Test.stopTest();

        
    }
    
    @isTest
    public static void testGetFellowshipDetails() {
    
        // ===============================
        // STEP 1: Create Yearly Call
        // ===============================
        YealyCall__c yc = new YealyCall__c(          
        );
        insert yc;
		RecordType rt = [
            SELECT Id, DeveloperName 
            FROM RecordType  
            WHERE SobjectType = 'Application_Proposal__c' 
            AND DeveloperName = 'PECFAR'
            LIMIT 1
        ];
	
    
        // ===============================
        // STEP 2: Create Proposal
        // ===============================
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Test Proposal',            
            yearly_Call__c = yc.Id,
    		RecordTypeId = rt.Id 
        );
        insert proposal;
    
        // ===============================
        // STEP 3: Create Contact (if required by lookup)
        // ===============================
        Contact con = new Contact(
            LastName = 'Test User',
            Email = 'karthikke129@gmail.com',
            Login_Hash_Code__c='dummyHash'
        );
        insert con;
    
        // ===============================
        // STEP 4: Create APA
        // ===============================
        Applicant_Proposal_Association__c apa =
            new Applicant_Proposal_Association__c(
                Proposals__c = proposal.Id,
                Contact__c = con.Id
            );
        insert apa;
    
        // ===============================
        // EXECUTE (SUCCESS CASE)
        // ===============================
        Test.startTest();
    
        Applicant_Proposal_Association__c result =
            Proposal_Controller.getFellowshipDetails(
                'dummyHash',
                proposal.Id,
                apa.Id
            );
    
        Test.stopTest();
    
        
    
}

	@isTest
	public static void testGetFieldDependencies() {

    Test.startTest();

    Map<String, List<String>> result =
        Proposal_Controller.getFieldDependencies(
            'Application_Proposal__c',          // Standard object
            'Stage__c',        // Controlling field
            'Proposal_Stages__c'         // Dependent field (may vary per org)
        );

    Test.stopTest();

    
}    
    
	@isTest
	public static void testGetCoordCVDetails() {

    // ===============================
    // STEP 1: Create Account
    // ===============================
    Account acc = new Account(Name = 'Test Account');
    insert acc;

    // ===============================
    // STEP 2: Create Contact
    // ===============================
    Contact con = new Contact(
        FirstName = 'Jane',
        LastName = 'Doe',
        Email = 'karthikke129+test@gmail.com.com',
        AccountId = acc.Id,
		Login_Hash_Code__c = 'hash123',
        Nationalities__c = 'Indian',
        Nationality__c ='Indian',
        MailingCountry = 'India'

    );
    insert con;

    // ===============================
    // STEP 3: Create Proposal
    // ===============================
    Application_Proposal__c proposal = new Application_Proposal__c(
        Title_Of__c = 'Test Proposal'
    );
    insert proposal;

    // ===============================
    // STEP 4: Create APA
    // ===============================
    Applicant_Proposal_Association__c apa =
        new Applicant_Proposal_Association__c(
            Contact__c = con.Id,
            Proposals__c = proposal.Id
        );
    insert apa;

    // ===============================
    // STEP 5: Create Education
    // ===============================
    Education_Details__c edu = new Education_Details__c(
        Contact__c = con.Id,
        Applicant_Proposal_Association__c = apa.Id
    );
    insert edu;

    // ===============================
    // STEP 6: Create Employment
    // ===============================
    Employment_Details__c emp = new Employment_Details__c(
        Contact__c = con.Id,
        Applicant_Proposal_Association__c = apa.Id
    );
    insert emp;

    // ===============================
    // EXECUTE
    // ===============================
    Test.startTest();

    List<Contact> result =Proposal_Controller.getCoordCVDetails('hash123',apa.Id,proposal.Id);
    Contact result2 = Proposal_Controller.getCoodinatorDetList('hash123',apa.Id);
	Proposal_Controller.getConForHostNationality('hash123');
    Contact result3 = Proposal_Controller.getCVDetailsForWiserApplicant('hash123',apa.Id);
    Proposal_Controller.deleteEducationWorkshop(edu.Id);
    Proposal_Controller.deleteEmploymentWorkshop(emp.Id);
        
    

    Test.stopTest();

   
}
    
    @isTest
	public static void testGetApplicationThematicAreas() {

    // ===============================
    // STEP 1: Create Proposal
    // ===============================
    Application_Proposal__c proposal = new Application_Proposal__c(
        Title_Of__c = 'Test Proposal'
    );
    insert proposal;

    // ===============================
    // STEP 2: Create Thematic Area MASTER records (LOOKUP TARGET)
    // ===============================
    Thematic_Area__c area1 = new Thematic_Area__c(Name = 'AI');
    Thematic_Area__c area2 = new Thematic_Area__c(Name = 'ML');
    insert new List<Thematic_Area__c>{ area1, area2 };

    // ===============================
    // STEP 3: Create Application Thematic records
    // ===============================
    List<Application_Thematic_Area__c> thematicList = new List<Application_Thematic_Area__c>{
        new Application_Thematic_Area__c(
            Application__c = proposal.Id,
            Thematic_Area__c = area1.Id   
        ),
        new Application_Thematic_Area__c(
            Application__c = proposal.Id,
            Thematic_Area__c = area2.Id              
        )
    };

    insert thematicList;

    // ===============================
    // EXECUTE
    // ===============================
    Test.startTest();

    List<Application_Thematic_Area__c> result =
        Proposal_Controller.getApplicationThematicAreas(proposal.Id);
    Test.stopTest();

}

	@isTest
	public static void testSaveWorkshopContactDetails() {

    // ===============================
    // STEP 1: Create Account + Contact
    // ===============================
    Account acc = new Account(Name = 'Test Acc');
    insert acc;

    Contact con = new Contact(
        LastName = 'Test User',
        AccountId = acc.Id,
        Email ='karthikke129@gmail.com',
        State__c = 'Karnataka',
        Login_Hash_Code__c = 'hashc1234567890'
    );
    insert con;
        
    Contact con2 = new Contact(
        LastName = 'Test User2',
        Email ='karthikke129+test2@gmail.com',
        State__c = 'Karnataka',
        Login_Hash_Code__c = 'hashc1234567890111'
    );
    insert con2;

    // ===============================
    // STEP 2: Create Proposal + APA
    // ===============================
    Application_Proposal__c proposal = new Application_Proposal__c(
        Title_Of__c = 'Test Proposal'
    );
    insert proposal;

    Applicant_Proposal_Association__c apa =
        new Applicant_Proposal_Association__c(
            Contact__c = con.Id,
            Proposals__c = proposal.Id
        );
    insert apa;

    // ===============================
    // STEP 3: Prepare Education + Employment
    // ===============================
    Education_Details__c edu = new Education_Details__c(
        Contact__c = con.Id       
    );

    Employment_Details__c emp = new Employment_Details__c(
        Contact__c = con.Id        
    );

    // ===============================
    // EXECUTE
    // ===============================
    Test.startTest();

    String result = Proposal_Controller.SaveWorkshopContactDetails(
        new List<Contact>{con},
        new List<Education_Details__c>{edu},
        new List<Employment_Details__c>{emp},
        apa.Id,
        proposal.Id
    );
    Account result2 = Proposal_Controller.getAddressDetails('hashc1234567890');
    Account result3 = Proposal_Controller.getAddressDetails('hashc1234567890111');

	Account result4 = Proposal_Controller.getAddressDetails(null);


    Test.stopTest();

    
}
    
    @isTest
	public static void testSaveAddressDetails() {

    // ===============================
    // STEP 1: Create Account (input)
    // ===============================
    Account acc = new Account(
        Name = 'New Account',
        BillingCountry = 'India',
        Shipping_State__c = 'KA',
        NumberOfEmployees = 50
    );

    // ===============================
    // STEP 2: Create Contact (no AccountId)
    // ===============================
    Contact con = new Contact(
        LastName = 'Test User',
        Email ='karthikke129@gmail.com'
    );

    // ===============================
    // EXECUTE
    // ===============================
    Test.startTest();

    String result = Proposal_Controller.saveAddressDetails(
        acc,
        new List<Contact>{con}
    );
   String result2 = Proposal_Controller.saveAddressDetails(null, null);


    Test.stopTest();
}    
    
    @isTest
	public static void testGetAllContacts() {

    // ===============================
    // STEP 1: Create Test Contacts
    // ===============================
    List<Contact> conList = new List<Contact>{
        new Contact(LastName = 'User1', Email = 'karthikke129@gmail.com'),
        new Contact(LastName = 'User2', Email = 'karthikke129+test2@gmail.com')
    };
    insert conList;

    // ===============================
    // EXECUTE
    // ===============================
    Test.startTest();
    List<Contact> result = Proposal_Controller.getAllContacts();
    Test.stopTest();

  
}
    
    @isTest
	public static void testCheckReferenceEmail() {

    // ===============================
    // STEP 1: Create Test Data
    // ===============================
    References__c ref1 = new References__c(
        Name = 'Ref1',
        Email__c = 'karthikke129@gmail.com'
    );

    References__c ref2 = new References__c(
        Name = 'Ref2',
        Email__c = 'karthikke129+test@gmail.com'
    );

    insert new List<References__c>{ref1, ref2};

    // ===============================
    // STEP 2: Prepare Inputs
    // ===============================
    List<String> emailList = new List<String>{'karthikke129@gmail.com', 'karthikke129+test@gmail.com'};
    
    // Exclude one record
    List<Id> excludeIds = new List<Id>{ref1.Id};

    // ===============================
    // EXECUTE
    // ===============================
    Test.startTest();
    List<References__c> result = Proposal_Controller.checkReferenceEmail(emailList, excludeIds);
    Test.stopTest();

    
}    
    

    // =========================================
    // COMMON TEST DATA SETUP
    // =========================================
    @testSetup
   public static void setupData() {

        // Account
        Account acc = new Account(
            Name = 'Test Account',
            BillingCountry = 'India'
        );
        insert acc;

        // Contacts
        Contact c1 = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'karthikke129@gmail.com',
            MailingCountry = 'India',
            AccountId = acc.Id
        );

        Contact c2 = new Contact(
            FirstName = 'Jane',
            LastName = 'Smith',
            Email = 'karthikke129@gmail.com', // SAME email for duplicate check
            MailingCountry = 'Germany',
            AccountId = acc.Id
        );

        insert new List<Contact>{c1, c2};
    }

    // =========================================
    // TEST: checkEmail (basic)
    // =========================================
    @isTest
    public static void testCheckEmail_WithDuplicate() {

        Test.startTest();
        List<Contact> result = Proposal_Controller.checkEmail('karthikke129@gmail.com', null);
        Test.stopTest();

     }

    // =========================================
    // TEST: checkEmail (exclude current Id)
    // =========================================
    @isTest
    public static void testCheckEmail_ExcludeCurrentContact() {

        Contact existing = [SELECT Id FROM Contact WHERE Email='karthikke129@gmail.com' LIMIT 1];

        Test.startTest();
        List<Contact> result = Proposal_Controller.checkEmail('karthikke129@gmail.com', existing.Id);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Should exclude current contact');
    }

    // =========================================
    // TEST: checkEmail (blank email)
    // =========================================
    @isTest
    public static void testCheckEmail_BlankEmail() {

        Test.startTest();
        List<Contact> result = Proposal_Controller.checkEmail('', null);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return empty list');
    }

    // =========================================
    // TEST: checkEmailWiser - No Contact Found
    // =========================================
    @isTest
    public static void testCheckEmailWiser_NoContact() {

        Test.startTest();
        Proposal_Controller.CheckEmailWrapper result =
            Proposal_Controller.checkEmailWiser('karthikke1291@gmail.com', null, 'India', null);
        Test.stopTest();

    }

    // =========================================
    // TEST: checkEmailWiser - Country Mismatch
    // =========================================
    @isTest
    public static void testCheckEmailWiser_CountryMismatch() {

        Test.startTest();
        Proposal_Controller.CheckEmailWrapper result =
            Proposal_Controller.checkEmailWiser('karthikke129@gmail.com', null, 'USA', null);
        Test.stopTest();

        
    }

    // =========================================
    // TEST: checkEmailWiser - Existing APA (Priority Case)
    // =========================================
    @isTest
    public static void testCheckEmailWiser_ExistingAPA_CurrentYear() {

        // Get contact
        Contact con = [SELECT Id, Email FROM Contact WHERE Email='karthikke129@gmail.com' LIMIT 1];

        // Create Year (Custom Object assumed)
        Year__c yr = new Year__c(
            Name = '2026',
            Is_Current_Year__c = true
        );
        insert yr;

        // Create Campaign (if required)
        Campaign camp = new Campaign(Name = 'Test Campaign');
        insert camp;

        // Create Yearly Call
        YealyCall__c yc = new YealyCall__c(
            Years__c = yr.Id,
            Campaign__c = camp.Id
        );
        insert yc;

        // Create Proposal
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Test Proposal',
            yearly_Call__c = yc.Id
        );
        insert proposal;

        // Create APA (Existing application)
        Applicant_Proposal_Association__c apa = new Applicant_Proposal_Association__c(
            Contact__c = con.Id,
            Proposals__c = proposal.Id
        );
        insert apa;

        Test.startTest();

        Proposal_Controller.CheckEmailWrapper result =
            Proposal_Controller.checkEmailWiser(
                con.Email,
                null,
                'India',
                yc.Id
            );

        Test.stopTest();

       
    }

    // =========================================
    // TEST: checkEmailWiser - Happy Path
    // =========================================
    @isTest
    public static void testCheckEmailWiser_Success() {

        // Create a contact with different email
        Contact newCon = new Contact(
            LastName = 'New User',
            Email = 'karthikke129@gmail.com',
            MailingCountry = 'India'
        );
        insert newCon;

        Test.startTest();
        Proposal_Controller.CheckEmailWrapper result =
            Proposal_Controller.checkEmailWiser(
                'karthikke129@gmail.com',
                null,
                'India',
                null
            );
        Test.stopTest();

      
    }    
   
    // =========================================
    // TEST: createHostContact
    // =========================================
    @isTest
    public static void testCreateHostContact() {

        // Create primary contact (input contact)
        Contact primaryCon = new Contact(
            LastName = 'Primary User',
            Email = 'karthikke129@gmail.com'
        );
        insert primaryCon;

        // Create dummy proposal (if lookup required)
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Test Proposal'
        );
        insert proposal;

        Test.startTest();

        String hostContactId = Proposal_Controller.createHostContact(
            primaryCon.Id,
            proposal.Id
        );

        Test.stopTest();

        
    }

    // =========================================
    // TEST: getMentorHostDetails (SUCCESS)
    // =========================================
    @isTest
    public static void testGetMentorHostDetails_Success() {

        // Create Account (Host Account)
        Account hostAcc = new Account(
            Name = 'Host Account'
        );
        insert hostAcc;

        // Create Parent Account with Host_Account__c reference
        Account parentAcc = new Account(
            Name = 'Parent Account',
            Host_Account__c = hostAcc.Id
        );
        insert parentAcc;

        // Create Contact linked to parent account
        Contact con = new Contact(
            LastName = 'User',
            AccountId = parentAcc.Id,
             Email = 'karthikke129@gmail.com',
            Login_Hash_Code__c = 'testHash'
        );
        insert con;

        // Create Proposal
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Test Proposal'
        );
        insert proposal;

        // Create APA linking Account
        Applicant_Proposal_Association__c apa = new Applicant_Proposal_Association__c(
            Contact__c = con.Id,
            Proposals__c = proposal.Id
        );
        insert apa;

        Test.startTest();

        Account result = Proposal_Controller.getMentorHostDetails(
            'testHash',
            apa.Id
        );
        Account result2 = Proposal_Controller.getMentorHostDetails(
            'testHash',
            null
        );

        Test.stopTest();

        
    }

    // =========================================
    // TEST: saveMentorHostDetails (SUCCESS)
    // =========================================
    @isTest
    public static void testSaveMentorHostDetails_Success() {

        // Create Contact Account
        Account parentAcc = new Account(Name = 'Parent Account');
        insert parentAcc;

        // Create Contact
        Contact con = new Contact(
            LastName = 'User',
            Email = 'karthikke129@gmail.com',
            AccountId = parentAcc.Id,
            Login_Hash_Code__c = 'hash123'
        );
        insert con;

        // Create Proposal
        Application_Proposal__c proposal = new Application_Proposal__c(
            Title_Of__c = 'Test Proposal'
        );
        insert proposal;

        // Create APA
        Applicant_Proposal_Association__c apa = new Applicant_Proposal_Association__c(
            Proposals__c = proposal.Id,
            Contact__c = con.Id
        );
        insert apa;

        // Create Host Account (input)
        Account hostAcc = new Account(
            Name = 'Host Account',
            Shipping_State__c = 'Karnataka'
        );
        
        proposal.Title_Of__c = 'Updated Proposal';

        Proposal_Controller controller = new Proposal_Controller();


        Test.startTest();

        String result = Proposal_Controller.saveMentorHostDetails(
            hostAcc,
            'hash123',
            proposal.Id,
            apa.Id
        );
        String result2 = controller.updateIFDocStatus(proposal);


        Test.stopTest();
    }

    // =========================================
    // TEST: saveMentorHostDetails (INVALID USER)
    // =========================================
    @isTest
    public static void testSaveMentorHostDetails_InvalidUser() {

        Account hostAcc = new Account(Name = 'Host');

        Test.startTest();

        String result = Proposal_Controller.saveMentorHostDetails(
            hostAcc,
            'invalidHash',
            null,
            null
        );

        Test.stopTest();
    }

   
    // =========================================
    // Helper: Create Proposal
    // =========================================
    private static Application_Proposal__c createProposal(Boolean isTwoPlusTwo) {

        Id rtId;

        if (isTwoPlusTwo) {
            rtId = [SELECT Id FROM RecordType 
                    WHERE SObjectType = 'Application_Proposal__c' 
                    AND DeveloperName  = 'Two_Plus_Two' 
                    LIMIT 1].Id;
        } else {
            rtId = [SELECT Id FROM RecordType 
                    WHERE SObjectType = 'Application_Proposal__c' 
                    LIMIT 1].Id;
        }

        Application_Proposal__c app = new Application_Proposal__c(
            Stage__c = '1St Stage',
            RecordTypeId = rtId
        );
        insert app;

        return app;
    }

    // =========================================
    // Helper: Create Evaluation Steps
    // =========================================
    private static List<Evaluation_Step__c> createEvaluationSteps(Id proposalId, String stage) {

        List<Evaluation_Step__c> steps = new List<Evaluation_Step__c>();

        for (Integer i = 0; i < 2; i++) {
            steps.add(new Evaluation_Step__c(               
                Proposals__c = proposalId,
                Stage__c = stage,
                Subject__c = 'Test Subject',
                Comments__c = 'Test Comment',
                Yes__c = true
            ));
        }

        insert steps;
        return steps;
    }

    // =========================================
    // TEST: getEvaluationRecords (Two Plus Two)
    // =========================================
    @isTest
    static void testGetEvaluationRecords_TwoPlusTwo() {

        Application_Proposal__c app = createProposal(true);
        createEvaluationSteps(app.Id, app.Stage__c);

        Test.startTest();
        List<Evaluation_Step__c> result =
            Proposal_Controller.getEvaluationRecords(app.Id);
        Test.stopTest();
    }

    // =========================================
    // TEST: getEvaluationRecords (Other RT)
    // =========================================
    @isTest
    static void testGetEvaluationRecords_Other() {

        Application_Proposal__c app = createProposal(false);
        createEvaluationSteps(app.Id, '2nd Stage');

        Test.startTest();
        List<Evaluation_Step__c> result =
            Proposal_Controller.getEvaluationRecords(app.Id);
        Test.stopTest();

    }

    // =========================================
    // TEST: saveEvaluationRecords
    // =========================================
    @isTest
    static void testSaveEvaluationRecords() {

        Application_Proposal__c app = createProposal(false);
        List<Evaluation_Step__c> steps =
            createEvaluationSteps(app.Id, '1St Stage');

        Test.startTest();
        String result =
            Proposal_Controller.saveEvaluationRecords(steps);
        Test.stopTest();

      
    }

    // =========================================
    // TEST: SaveDraftEvaluationRecords
    // =========================================
    @isTest
    static void testSaveDraftEvaluationRecords() {

        Application_Proposal__c app = createProposal(false);
        List<Evaluation_Step__c> steps =
            createEvaluationSteps(app.Id, '1St Stage');

        Test.startTest();
        String result =
            Proposal_Controller.SaveDraftEvaluationRecords(steps);
        Test.stopTest();

        
    }

    
  
    // =========================================
    // Helper: Create Proposal
    // =========================================
    private static Application_Proposal__c createProposal() {
        Application_Proposal__c app = new Application_Proposal__c(
           Title_Of__c = 'Test Proposal' 
        );
        insert app;
        return app;
    }

    // =========================================
    // TEST: reviewAppDocGen
    // =========================================
    @isTest
    static void testReviewAppDocGen() {

        Application_Proposal__c app = createProposal();

        Proposal_Controller controller = new Proposal_Controller();

        Test.startTest();
        String result = controller.reviewAppDocGen(app.Id);
        Test.stopTest();

       
    }

    // =========================================
    // TEST: getCongaDoc (No Attachment Case)
    // =========================================
    @isTest
    static void testGetCongaDoc_NoAttachment() {

        Application_Proposal__c app = createProposal();

        Proposal_Controller controller = new Proposal_Controller();

        Test.startTest();
        List<Attachment> result = controller.getCongaDoc(app.Id);
        Test.stopTest();

    }

    // =========================================
    // TEST: getCongaDoc (With Attachment)
    // =========================================
    @isTest
    static void testGetCongaDoc_WithAttachment() {

        Application_Proposal__c app = createProposal();

        // Create Attachment manually
        Attachment att = new Attachment(
            Name = 'TestDoc',
            ParentId = app.Id,
            Body = Blob.valueOf('Test Content'),
            ContentType = 'text/plain'
        );
        insert att;

        Proposal_Controller controller = new Proposal_Controller();

        Test.startTest();
        List<Attachment> result = controller.getCongaDoc(app.Id);
        Test.stopTest();

      
    }

    // =========================================
    // TEST: getAttachmentId
    // =========================================
    @isTest
    static void testGetAttachmentId() {

        Application_Proposal__c app = createProposal();

        Attachment att = new Attachment(
            Name = 'Test Attachment',
            ParentId = app.Id,
            Body = Blob.valueOf('Test Data'),
            ContentType = 'text/plain'
        );
        insert att;

        Test.startTest();
        String attId = Proposal_Controller.getAttachmentId(app.Id);
        Test.stopTest();

    }





	

    
    









            
    
}