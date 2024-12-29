@isTest(SeeAllData=False)
private class ExotelBirthdayCheckTest {
    @isTest static void testWithParam() {
        RestRequest req = new RestRequest(); 
       	RestResponse res = new RestResponse();
    
        req.requestURI = System.label.OrgEndPoint + 'apexrest/isbirthday';  //Request URL
        req.params.put('CallFrom', '012314');
        req.httpMethod = 'GET';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
            ExotelBirthdayCheck.doGet();
        Test.stopTest();
    }
    
    @isTest static void testWithoutParam() {
        RestRequest req = new RestRequest(); 
       	RestResponse res = new RestResponse();
    
        req.requestURI = System.label.OrgEndPoint + 'apexrest/isbirthday';  //Request URL
        req.httpMethod = 'GET';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
            ExotelBirthdayCheck.doGet();
        Test.stopTest();
    }
}