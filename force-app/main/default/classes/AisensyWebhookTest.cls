@isTest(SeeAllData=False)
private class AisensyWebhookTest {
    @isTest 
    static void testWithParam() {
        RestRequest req = new RestRequest(); 
       	RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/aisensy/webhook';
        String reqBody = '{}';
        req.requestBody = Blob.valueOf(reqBody);
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
            AisensyWebhook.doPost();
        Test.stopTest();
    }
}