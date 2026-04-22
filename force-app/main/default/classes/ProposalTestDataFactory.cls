@isTest
public class ProposalTestDataFactory {

    public static Account createAccount() {
        Account acc = new Account(
            Name = 'Acc ' + System.now().getTime(),
            BillingCountry = 'India'
        );
        insert acc;
        return acc;
    }

    public static Contact createContact(String hash, Id accId) {
        Contact con = new Contact(
            LastName = 'User',
            Email = 'karthikke129@gmail.com',
            Login_Hash_Code__c = hash,
            AccountId = accId
        );
        insert con;
        return con;
    }

    public static Application_Proposal__c createProposal() {
        Application_Proposal__c p = new Application_Proposal__c(
            Title_Of__c = 'Proposal ' + System.now().getTime()
        );
        insert p;
        return p;
    }

    public static Applicant_Proposal_Association__c createAPA(Id conId, Id proposalId, Boolean isCoord) {
        Applicant_Proposal_Association__c apa = new Applicant_Proposal_Association__c(
            Contact__c = conId,
            Proposals__c = proposalId,
            Is_Coordinator__c = isCoord,
            Applicant_Status__c = 'Draft'
        );
        insert apa;
        return apa;
    }

    public static ContentVersion createFile(Id parentId) {
        ContentVersion cv = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'test.txt',
            VersionData = Blob.valueOf('test'),
            FirstPublishLocationId = parentId
        );
        insert cv;
        return cv;
    }
}