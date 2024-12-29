public class SendDonationPDF {
    
    @AuraEnabled
    public static List<String> getPdfDetails(String listViewId){
        String sessionId = SendWhatsappMsgBasedOnTemplate.getSessionId();
        IF(String.isNotBlank(sessionId)){
            List<string> donationIds = SendWhatsappMsgBasedOnTemplate.getListViewIds(listViewId, sessionId, 'npe01__OppPayment__c');
            return SendDonationPDF.getDonationPdfDetails(donationIds);
        }else{
            return null;
        }      
    }
   
    @AuraEnabled
    public static List<String> getDonationPdfDetails(List<string> donationIds){
        List<String> result = new List<String>();
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartArray();
        boolean is_contactList_empty = True;
        List<string> orderedDonationIds = new List<string>();
       
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
                                              npe01__Opportunity__r.Transaction_Reference__c,
                                              npe01__Payment_Date__c,
                                              npe01__Payment_Amount__c,
                                              npsp__Payment_Acknowledged_Date__c,
                                              npsp__Gateway_Payment_ID__c,
                                              npsp__Payment_Acknowledgment_Status__c,
                                              Id,
                                              Name 
                                            From npe01__OppPayment__c Where Id IN :donationIds];
        for(npe01__OppPayment__c don : donationList){
            if(don.npsp__Payment_Acknowledgment_Status__c == 'Acknowledged'){
                continue;
            }
            String donationListJson = JSON.serialize(new List<npe01__OppPayment__c>{don});
            String receipt_url = DonationPDFController.getExistingReceiptOrCreate(donationListJson, don.Id);
            String phone = don.npe01__Opportunity__r.npsp__Primary_Contact__r.Phone;
            IF(String.isempty(phone)){
                phone = don.npe01__Opportunity__r.npsp__Primary_Contact__r.OtherPhone;
            }
            IF(String.isempty(phone)){
                continue;
            }
            
            List<String> params = new List<String>();
            params.add(don.npe01__Opportunity__r.npsp__Primary_Contact__r.Name);
            params.add(String.valueOf(don.npe01__Payment_Amount__c));
            params.add(String.valueOf(don.npe01__Payment_Date__c));
            params.add(don.npsp__Gateway_Payment_ID__c);
                
            gen.writeStartObject();
            gen.writeStringField('id', don.Id);
            gen.writeFieldName('customParams');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('name', 'const__receipt_pdf_link');
            gen.writeStringField('value', receipt_url);
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeStringField('whatsappNumber', don.npe01__Opportunity__r.npsp__Primary_Contact__r.Phone);  
            gen.writeStringField('name', don.npe01__Opportunity__r.npsp__Primary_Contact__r.Name);  
            
            gen.writeFieldName('media_str'); 
            gen.writeStartObject();
            gen.writeStringField('url', receipt_url);
            gen.writeStringField('filename', 'receipt.pdf');
            gen.writeEndObject();
            
            gen.writeFieldName('param_str');  
            gen.writeStartArray();
            for (String param : params) {
                gen.writeString(param);  
            }
            gen.writeEndArray();
            
            gen.writeStringField('bankAccount', don.npe01__Opportunity__r.Donation_Bank_Account__c); 
            gen.writeEndObject();
            orderedDonationIds.add((String)don.Id);
            is_contactList_empty = False;
        }
        gen.writeEndArray();
        String receivers = gen.getAsString();
        System.debug('receivers---->' + receivers);
        if(!is_contactList_empty){
            result.add(receivers);
            result.add(JSON.serialize(orderedDonationIds));
            return result;
        }
        else{
            return null;
        }
    }
    public class CustomParam {
            public String name { get; set; }
            public String value { get; set; }
    }    
        public class Media {
            public String url { get; set; }
            public String filename { get; set; }
        }
     public class Receiver {
        public String Id;
        public String whatsappNumber { get; set; }
        public String name { get; set; }
        public List<CustomParam> customParams { get; set; } 
        public Media media_str { get; set; }
        public List<String> param_str { get; set; } 
        public String bankAccount { get; set; }
    
    }
    
    @AuraEnabled
    public static String sendDonationPdfs(List<String> donationDetails){
        String receivers = donationDetails[0];
        System.debug('receivers---->' + receivers);
        System.debug('donationDetails-1---->' + donationDetails[1]);
        List<string> sentDonationIds = new List<string>();
        List<string> sentDonationFailedIds = new List<string>();
        List<Receiver> receiverList = (List<Receiver>) JSON.deserialize(receivers, List<Receiver>.class);
        
        List <String> donationIds = (List<String>) JSON.deserialize(donationDetails[1], List<String>.class);
            Map<String,String> settlementAccountDomainMap = new Map<String,String>{
                    'SAVE - 1801' => 'gitaquest',
                    'ISKCON - 4397' => 'iskcon'
            };
            
        Map<String,String> campaignMap = new Map<String,String>{
                'gitaquest' => 'Send-Receipt-2',
                'iskcon' => 'Send-Receipt-1'
        };
            
        for (Receiver receiver : receiverList) {
            String Id = receiver.Id;
            String domain = settlementAccountDomainMap.get(receiver.bankAccount);
            String campaignName = campaignMap.get(domain);
            String phone = receiver.whatsappNumber;
            String name = receiver.name;
            String source_str = 'Donation Receipt'; 
            String media_str = JSON.serialize(receiver.media_str); 
            String param_str = JSON.serialize(receiver.param_str); 
            String response = SendWhatsappMsg.sendToAiSensy(phone, name, source_str, media_str, param_str, campaignName, domain);
            System.debug('response---->' + response);
            if (response.contains('Success')) {
                sentDonationIds.add(receiver.Id); 
            } else {
                sentDonationFailedIds.add(receiver.Id);
            }
    	}
	    
        /*for (Integer i = 0; i < donationIds.size(); i++) {
            String errString = 'contact#' + i;
            if(!watiResponse.contains(errString)){
                sentDonationIds.add(donationIds[i]);
            }else{
                sentDonationFailedIds.add(donationIds[i]);
            }
        }*/
        List<npe01__OppPayment__c> donationList = [Select id From npe01__OppPayment__c Where Id IN :sentDonationIds];
        for(npe01__OppPayment__c don : donationList){
            don.npsp__Payment_Acknowledged_Date__c = date.today();
            don.npsp__Payment_Acknowledgment_Status__c = 'Acknowledged';
            update don;
        }
        List <String> failedTRs = new List <String>();
        List<npe01__OppPayment__c> failedDonationList = [Select Name From npe01__OppPayment__c Where Id IN :sentDonationFailedIds];
        for(npe01__OppPayment__c don : failedDonationList){
            failedTRs.add(don.Name);
        }
        if(failedTRs.isEmpty()){
            return 'Succesfully sent all receipts!';
        }else{
            return 'Some receipts failed to send : ' + String.join(failedTRs, ', ');
        }
    }
}