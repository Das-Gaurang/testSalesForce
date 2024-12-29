public class DonationPDFController {
    public List<npe01__OppPayment__c > donationList{get;set;}
    public string donationListJson = System.currentPagereference().getParameters().get('donationListJson');
    public DonationPDFController(){
        donationList = (List<npe01__OppPayment__c>) JSON.deserialize(donationListJson, List<npe01__OppPayment__c>.class);
    }
    
    public static String save_and_send_receipt(String donationListJson, Id donation_id){
		PageReference ref = Page.GQReceipt;
        ref.getParameters().put('donationListJson', donationListJson);
        Blob b;
        if(!test.isRunningTest()){
          b = ref.getContentAsPDF();
        }else{
          b = blob.valueof('TEST');
        }
        System.debug('user id ' + UserInfo.getUserId());
		ContentVersion receipt = new ContentVersion();
        receipt.ContentLocation = 'S';
        receipt.pathOnClient = 'receipt.pdf';
        receipt.title = 'receipt';
        receipt.VersionData = b;
        Database.SaveResult saveResult;
        try {
            saveResult = Database.insert(receipt);
        } catch (DmlException DMLE) {
            system.debug(
                'Failed to insert fileToUpload, error is: ' + dmle.getMessage()
            );
        }
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:receipt.Id].ContentDocumentId;

        //Create ContentDocumentLink
        ContentDocumentLink linkToRecord = new ContentDocumentLink();
        linkToRecord.ContentDocumentId = contentDocumentId;
        linkToRecord.LinkedEntityId = donation_id; // RecordID of the parent
        linkToRecord.ShareType = 'V'; // View permissions
        linkToRecord.visibility = 'AllUsers';
        insert linkToRecord;
        ContentDistribution cd = new ContentDistribution();
        cd.Name = 'Test';
        cd.ContentVersionId = receipt.id;
        cd.PreferencesAllowViewInBrowser= true;
        cd.PreferencesLinkLatestVersion=true;
        cd.PreferencesNotifyOnVisit=false;
        cd.PreferencesAllowPDFDownload=true;
        cd.PreferencesPasswordRequired=false;
        cd.PreferencesAllowOriginalDownload= true;
        cd.PreferencesExpires=false;
        insert cd;
		String receipt_public_url = [select PdfDownloadUrl from ContentDistribution where id=:cd.Id].PdfDownloadUrl;
        return receipt_public_url;
    }
    
    public static String getExistingReceiptOrCreate(String donationListJson, Id donation_id){
        List<ContentDocumentLink> documentIds = [select ContentDocument.id from ContentDocumentLink where LinkedEntityId=:donation_id and ContentDocument.title = 'receipt' order by ContentDocument.createddate desc limit 1];
        if(documentIds.isEmpty()){
            return DonationPDFController.save_and_send_receipt(donationListJson, donation_id);
        }else{
            String receipt_public_url = [select PdfDownloadUrl from ContentDistribution where ContentDocumentId=:documentIds[0].ContentDocument.Id].PdfDownloadUrl;
        	return receipt_public_url;
        }
    }
}