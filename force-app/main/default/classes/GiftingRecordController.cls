public class GiftingRecordController {
    public List<Gifting__c> giftingRecords { get; set; }

    // StandardSetController to handle selected records in the list view
    public GiftingRecordController(ApexPages.StandardSetController controller) {
        giftingRecords = (List<Gifting__c>)controller.getSelected();
    }
}