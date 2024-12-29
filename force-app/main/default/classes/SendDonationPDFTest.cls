@isTest(SeeAllData=false)
private class SendDonationPDFTest {
    @isTest static void testPrepareReceipts() {
        Contact con = new Contact();
        con.lastname = 'test';
        con.Phone = '+919999999999';
        insert con;
        Opportunity  don = new Opportunity();
        don.CloseDate = date.today();
        don.npsp__Primary_Contact__c  = con.Id;
        don.Name = 'sfsf';
        don.StageName = 'Closed Won';
        don.Gateway_Transaction_Id__c = 'sdadasa';
        don.Amount = 20;
        don.Donation_Bank_Account__c = 'ISKCON Roorkee';
        insert don;
        npe01__OppPayment__c pay = new npe01__OppPayment__c();
        pay.npe01__Opportunity__c = don.id;
        pay.npe01__Payment_Amount__c = don.Amount;
        System.debug('don.id ---->' + don.id);
        Test.startTest();
        	List<npe01__OppPayment__c> payments = [select id from npe01__OppPayment__c];
        	payments[0].npsp__Gateway_Payment_ID__c = don.Gateway_Transaction_Id__c;
        	update payments[0];
        	List<String> result = SendDonationPDF.getDonationPdfDetails(new List<string> {payments[0].id});
        	System.debug('don.id ---->' + don.id);
        Test.stopTest();
    }

    @isTest static void testSendReceipts() {
        Contact con = new Contact();
        con.lastname = 'test';
        con.Phone = '+919999999999';
        insert con;
        Opportunity  don = new Opportunity();
        don.CloseDate = date.today();
        don.npsp__Primary_Contact__c  = con.Id;
        don.Name = 'sfsf';
        don.StageName = 'Closed Won';
        don.Gateway_Transaction_Id__c = 'sdadasa';
        don.Amount = 20;
        don.Donation_Bank_Account__c = 'ISKCON Roorkee';
        insert don;
        npe01__OppPayment__c pay = new npe01__OppPayment__c();
        pay.npe01__Opportunity__c = don.id;
        pay.npe01__Payment_Amount__c = don.Amount;
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('WATIResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        System.debug('don.id ---->' + don.id);
        List<npe01__OppPayment__c> payments = [select id from npe01__OppPayment__c];
        payments[0].npsp__Gateway_Payment_ID__c = don.Gateway_Transaction_Id__c;
        update payments[0];
        List<String> result = SendDonationPDF.getDonationPdfDetails(new List<string> {payments[0].id});
        Test.startTest();
	        SendDonationPDF.sendDonationPdfs(result);
        Test.stopTest();
    }
}