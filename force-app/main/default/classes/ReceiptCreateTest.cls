@isTest(SeeAllData=False)
private class ReceiptCreateTest {
    @isTest 
    static void testWithParam() {
        RestRequest req = new RestRequest(); 
       	RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/receipt/create';
        String reqBody = '{"gateway_transaction_id": "safasfasf2", "service_token": "krishna!!Balaram@gqGovind#Damodara$Madhaveti*hkhkkkhhhrhrrrhh)"}';
        req.requestBody = Blob.valueOf(reqBody);
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        opportunity opp = new opportunity();
        opp.Gateway_Transaction_Id__c  = 'safasfasf2';
        opp.name = 'dasfs';
        opp.CloseDate = date.today();
        opp.Amount=20;
        opp.Receipt_Purpose__c = 'General';
        opp.StageName = 'Closed Won';
        insert opp;
        npe01__OppPayment__c pay = new npe01__OppPayment__c();
        pay.npsp__Gateway_Payment_ID__c = 'safasfasf2';
        pay.npe01__Opportunity__c = opp.id;
        insert pay;
        Test.startTest();
            ReceiptCreate.doPost();
        Test.stopTest();
    }
}