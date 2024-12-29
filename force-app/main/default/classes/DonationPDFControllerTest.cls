@isTest(SeeAllData=false)
private class DonationPDFControllerTest {
    @isTest static void testGetExistingReceiptOrCreate() {
        Contact con = new Contact();
        con.lastname = 'test';
        con.phone = '+919999999999';
        insert con;
        Opportunity don = new Opportunity();
        don.CloseDate  = date.today();
        don.Amount = 108;
        don.name = 'test';
        don.StageName  = 'Closed Won';
        don.Receipt_Purpose__c = 'General';
        don.npsp__Primary_Contact__c = con.Id;
        insert don;
        list <npe01__OppPayment__c> donList = [Select npe01__Opportunity__r.npsp__Primary_Contact__r.Name,
                                              npe01__Opportunity__r.npsp__Primary_Contact__r.Phone,
                                              npe01__Opportunity__r.npsp__Primary_Contact__r.OtherPhone,
                                              npe01__Opportunity__r.npsp__Primary_Contact__r.Email,
                                              npe01__Opportunity__r.npsp__Primary_Contact__r.PAN_Number__c,
                                              npe01__Opportunity__r.npsp__Primary_Contact__r.Full_Address__c,
                                              npe01__Opportunity__r.npsp__Primary_Contact__r.City__c,
                                              npe01__Opportunity__r.npsp__Primary_Contact__r.States_UT__c,
                                              npe01__Opportunity__r.npsp__Primary_Contact__r.Country__c,
                                              npe01__Opportunity__r.npsp__Primary_Contact__r.PIN_Code__c,
                                              npe01__Opportunity__r.Is_80G__c,
                                              npe01__Payment_Date__c,
                                              npe01__Payment_Amount__c,
                                              npsp__Gateway_Payment_ID__c,
                                              Id,
                                              Name
                                             From npe01__OppPayment__c];
        Test.startTest();
            DonationPDFController.getExistingReceiptOrCreate(JSON.serialize(donList), don.Id);
        Test.stopTest();
    }
}