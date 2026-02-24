@IsTest
public class EmailVerification_ControllerTest {

    @IsTest
    static void testVerifyEmail_ValidContact() {
        // Create test contact
        Contact con = new Contact(
            FirstName = 'Test',
            LastName  = 'User',
            Email     = 'testuser@test.com',
            Email_Verified__c = false
        );
        insert con;

        Test.startTest();
        String result = EmailVerification_Controller.verifyEmail(con.Id);
        Test.stopTest();

        // Fetch updated record
        Contact updatedCon = [
            SELECT Email_Verified__c, Name
            FROM Contact
            WHERE Id = :con.Id
        ];

        // Assertions
       
    }

    @IsTest
    static void testVerifyEmail_BlankHashcode() {
        Test.startTest();
        String result = EmailVerification_Controller.verifyEmail('');
        Test.stopTest();

       
    }

    @IsTest
    static void testVerifyEmail_InvalidId() {
        // Fake Id (valid Contact prefix but does not exist)
        Id fakeContactId = '003000000000000AAA';

        Test.startTest();
        String result = EmailVerification_Controller.verifyEmail(fakeContactId);
        Test.stopTest();

        
    }
}