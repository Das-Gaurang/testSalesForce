@RestResource(urlMapping='/receipt/create')
global class ReceiptCreate {
    @HttpPost
    global static void doPost() {
        Map<String, String> bodyObj = (Map<String, String>)JSON.deserialize(
            RestContext.request.requestBody.toString(), Map<String, String>.class
        );
        RestResponse res = RestContext.response;
        String service_token = 'krishna!!Balaram@gqGovind#Damodara$Madhaveti*hkhkkkhhhrhrrrhh)';
        if(bodyObj.get('service_token') != service_token){
            res.statusCode = 404;
            return;
        }
        String gateway_transaction_id = bodyObj.get('gateway_transaction_id');
        List<npe01__OppPayment__c> donationList = [SELECT 
                                              npe01__Opportunity__r.npsp__Primary_Contact__r.Name,
                                              npe01__Opportunity__r.npsp__Primary_Contact__r.Phone,
                                              npe01__Opportunity__r.npsp__Primary_Contact__r.OtherPhone,
                                              npe01__Opportunity__r.npsp__Primary_Contact__r.Email,
                                              npe01__Opportunity__r.npsp__Primary_Contact__r.PAN_Number__c,
                                              npe01__Opportunity__r.npsp__Primary_Contact__r.Full_Address__c,
                                              npe01__Opportunity__r.npsp__Primary_Contact__r.locality__c,
                                              npe01__Opportunity__r.npsp__Primary_Contact__r.City__c,
                                              npe01__Opportunity__r.npsp__Primary_Contact__r.States_UT__c,
                                              npe01__Opportunity__r.npsp__Primary_Contact__r.Country__c,
                                              npe01__Opportunity__r.npsp__Primary_Contact__r.PIN_Code__c,
                                              npe01__Opportunity__r.Is_80G__c,
                                              npe01__Opportunity__r.Donation_Bank_Account__c,  
                                              npe01__Payment_Date__c,
                                              npe01__Payment_Amount__c,
                                              npsp__Gateway_Payment_ID__c,
                                              Id,
                                              Name
                                          FROM 
                                              npe01__OppPayment__c
                                          WHERE 
                                              npsp__Gateway_Payment_ID__c = :gateway_transaction_id];
        String don_id = donationList[0].id;
        String donationListJson = JSON.serialize(donationList);
        String receipt_url = DonationPDFController.getExistingReceiptOrCreate(donationListJson, don_id);
        res.responseBody = Blob.valueOf(receipt_url);
        res.statusCode = 200;
        return; 
    }
}