@isTest(SeeAllData=False)
private class WatiBroadcastTest {
    @isTest static void testWarmTemp() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('WATIResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        List<string> conList = new List<string>();
        Contact con = new Contact();
        con.LastName = 'testSF';
        insert con;
        conList.add(con.Id);
        Map<string, string> paramMap = new Map<string, string>();
        paramMap.put('key', 'value');
        Test.startTest();
            System.enqueueJob(new WatiBroadcast(conList, 'templateName', paramMap));
        Test.stopTest();
    }
}