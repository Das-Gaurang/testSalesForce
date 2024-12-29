/*public class GiftingsController {
    public List<Gifting__c> giftings { get; set; }
    
    public GiftingsController() {
        // Fetch all records from Giftings__c
        giftings = [SELECT Name, Full_Address__c, TrackingNumber__c FROM Gifting__c LIMIT 100];
    }
}*/

public class GiftingsController {
    public List<Gifting__c> giftings { get; set; }
    
    // Constructor
    public GiftingsController() {
        // Get the selected list view ID from the URL parameters
        String listViewId = ApexPages.currentPage().getParameters().get('fcf');
        
        if (listViewId != null) {
            // Fetch the records based on the list view's filter criteria
            giftings = getGiftingsByListView(listViewId);
        } else {
            // Default behavior: fetch the first 100 records
            giftings = [SELECT Name, TrackingNumber__c, Full_Address__c FROM Gifting__c LIMIT 100];
        }
    }
    
    // Method to fetch records based on the list view ID using StandardSetController
    private List<Gifting__c> getGiftingsByListView(String listViewId) {
        // Create a StandardSetController using the ListView ID
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
            [SELECT Name, TrackingNumber__c, Full_Address__c FROM Gifting__c] // Base query, add more filters if needed
        ));
        setCon.setPageSize(100); // Set page size as per your need
        return (List<Gifting__c>)setCon.getRecords();
    }
}