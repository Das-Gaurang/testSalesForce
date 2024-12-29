public class GiftingRecordsController {
    public List<Gifting__c> giftingRecords { get; set; }

    // StandardSetController to handle selected records in the list view
    public GiftingRecordsController(ApexPages.StandardSetController controller) {
        giftingRecords = (List<Gifting__c>)controller.getSelected();
    }
}