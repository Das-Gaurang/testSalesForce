public class GiftingController {
    public List<Gifting__c> selGfLst { get; set; }
    public String gfIds { get; set; }

    // Constructor that accepts StandardSetController
    public GiftingController(ApexPages.StandardSetController setController) {
        selGfLst = (List<Gifting__c>) setController.getSelected();
        gfIds = '';

        if(selGfLst != null && selGfLst.size() > 0) {
            for(Gifting__c gf : selGfLst) {
                gfIds += gf.Id + ',';
            }
            // Remove the last comma
            gfIds = gfIds.removeEnd(',');
        }
        getGiftingRecords();
    }

    // Method to retrieve full records based on the IDs
    public void getGiftingRecords() {
        if (!String.isEmpty(gfIds)) {
            List<Id> gfIdList = gfIds.split(',');
            selGfLst = [SELECT Id, Name, TrackingNumber__c, Donor_Contact__r.Name, Donor_Contact__r.Phone, Address_Line_1__c, Pincode__c, City__c, State__c, Status__c, Full_Address__c 
                    FROM Gifting__c 
                    WHERE Id IN :gfIdList];
        }
       
    }
}