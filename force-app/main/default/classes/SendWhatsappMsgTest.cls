@isTest(SeeAllData=false)
private class SendWhatsappMsgTest {
    @isTest static void testWithoutPhone() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('WATIResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        Contact con = new Contact();
        con.LastName = 'testSF';
        con.Birthdate = Date.today();
        insert con;
        Test.startTest();
            SendWhatsappMsg.excecuteSendWhatsappMsg();
        Test.stopTest();
    }
    @isTest static void testWithPhone() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('WATIResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        Contact con = new Contact();
        con.LastName = 'testSF';
        con.Phone = '+919999999999';
        con.Birthdate = Date.today();
        insert con;
        Test.startTest();
            SendWhatsappMsg.excecuteSendWhatsappMsg();
        Test.stopTest();
    }
}