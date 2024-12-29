@isTest
public class AppendCommentsToDescriptionBatchTest {

    // Set up diverse test data to cover all cases
    @testSetup
    static void setupTestData() {
        List<Contact> contacts = new List<Contact>();

        // Case 1: Contact with Comments__c data (to test the appending functionality)
        contacts.add(new Contact(LastName = 'Test1', Comments__c = 'This is a comment.'));

        // Case 2: Contact with no Comments__c (should not be updated)
        contacts.add(new Contact(LastName = 'Test2', Comments__c = null));

        // Case 3: Contact with existing Description and Comments__c data (to test appending to existing Description)
        contacts.add(new Contact(LastName = 'Test3', Description = 'Existing description.', Comments__c = 'Another comment.'));

        // Case 4: Contact with only Description (to ensure it remains unchanged if Comments__c is empty)
        contacts.add(new Contact(LastName = 'Test4', Description = 'Only description here.'));

        // Insert test records
        insert contacts;
    }

    // Test the main execution of the batch job
    @isTest
    static void testBatchExecution() {
        Test.startTest();
        // Execute the batch process with chunk size of 1 for testing each record individually
        AppendCommentsToDescriptionBatch batch = new AppendCommentsToDescriptionBatch();
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }

    
}