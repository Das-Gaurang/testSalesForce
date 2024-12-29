@isTest(SeeAllData=False)
public class CreateContactServiceTest {
    
    @isTest 
    static void testWithParam() {
        RestRequest req = new RestRequest(); 
       	RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/createContact';
        String reqBody = '{"firstName": "dsaa", "lastName": "safs", "Number": "+919999999999", "Group": "Youth", "City": "Panipat", "Occupation": "Student", "LeadSource": "Sankirtan"}';
        req.addHeader('secret_app_key', 'ekusdmbnjwehv9178');
        req.requestBody = Blob.valueOf(reqBody);
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
            CreateContactService.createContact();
        Test.stopTest();
    }
}