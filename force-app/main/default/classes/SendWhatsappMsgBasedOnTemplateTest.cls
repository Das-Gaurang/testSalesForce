@isTest(SeeAllData=false)
private class SendWhatsappMsgBasedOnTemplateTest {
    @isTest static void testgetWatiTemplate() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('WATIResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
            SendWhatsappMsgBasedOnTemplate.getTemplateList();
        Test.stopTest();
    }
    
    @isTest static void testgetSessionId() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('WATIResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
            SendWhatsappMsgBasedOnTemplate.getSessionId();
        Test.stopTest();
    }
}