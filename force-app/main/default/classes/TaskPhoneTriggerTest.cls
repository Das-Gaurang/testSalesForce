@isTest
public class TaskPhoneTriggerTest {

    @isTest
    static void testTaskPhoneNumberFromContact() {
        // Create a Contact with a phone number
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Phone = '1234567890'  // Valid phone number
        );
        insert contact;

        // Create a Task linked to the Contact via WhoId
        Task task = new Task(
            WhoId = contact.Id,   // Link to the Contact
            Subject = 'Test Task',
            Status = 'Not Started',
            Priority = 'Normal'
        );
        
        // Insert Task to trigger TaskPhoneTrigger
        insert task;

        // Retrieve the inserted Task and check if the Phone_Number__c field was updated
        Task insertedTask = [SELECT Id, Phone_Number__c FROM Task WHERE Id = :task.Id];
        System.assertEquals('1234567890', insertedTask.Phone_Number__c, 'Task phone number should match Contact phone number');
    }

    @isTest
    static void testTaskWithoutContactPhoneNumber() {
        // Create a Contact without a phone number
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'NoPhoneContact'
        );
        insert contact;

        // Create a Task linked to the Contact without a phone number
        Task task = new Task(
            WhoId = contact.Id,   // Link to the Contact
            Subject = 'Test Task Without Phone',
            Status = 'Not Started',
            Priority = 'Normal'
        );
        
        // Insert Task to trigger TaskPhoneTrigger
        insert task;

        // Retrieve the inserted Task and ensure Phone_Number__c is not updated
        Task insertedTask = [SELECT Id, Phone_Number__c FROM Task WHERE Id = :task.Id];
        System.assertEquals(null, insertedTask.Phone_Number__c, 'Task phone number should remain null if Contact has no phone number');
    }

    @isTest
    static void testTaskWithoutContact() {
        // Create a Task with no WhoId (i.e., not linked to a Contact)
        Task task = new Task(
            Subject = 'Test Task Without Contact',
            Status = 'Not Started',
            Priority = 'Normal'
        );
        
        // Insert Task to trigger TaskPhoneTrigger
        insert task;

        // Retrieve the inserted Task and ensure Phone_Number__c is null since there's no Contact
        Task insertedTask = [SELECT Id, Phone_Number__c FROM Task WHERE Id = :task.Id];
        System.assertEquals(null, insertedTask.Phone_Number__c, 'Task phone number should remain null if no Contact is linked');
    }

    // New Test: Testing updates on existing Task records
    @isTest
    static void testUpdateTaskWithContactPhoneNumber() {
        // Create a Contact with a phone number
        Contact contact = new Contact(
            FirstName = 'Updated',
            LastName = 'Contact',
            Phone = '0987654321'  // Another valid phone number
        );
        insert contact;

        // Create a Task without a WhoId (Contact not linked initially)
        Task task = new Task(
            Subject = 'Test Task Without Contact Initially',
            Status = 'Not Started',
            Priority = 'Normal'
        );
        insert task;

        // Now update the Task to link it to the Contact
        task.WhoId = contact.Id;
        update task;

        // Retrieve the updated Task and check if the Phone_Number__c field was updated
        Task updatedTask = [SELECT Id, Phone_Number__c FROM Task WHERE Id = :task.Id];
        System.assertEquals('0987654321', updatedTask.Phone_Number__c, 'Updated Task phone number should match updated Contact phone number');
    }

    // New Test: Test updating Task where the WhoId is changed to null
    @isTest
    static void testUpdateTaskRemoveContact() {
        // Create a Contact with a phone number
        Contact contact = new Contact(
            FirstName = 'Contact',
            LastName = 'RemoveTest',
            Phone = '9876543210'  // Valid phone number
        );
        insert contact;

        // Create a Task linked to the Contact
        Task task = new Task(
            WhoId = contact.Id,
            Subject = 'Test Task for Remove Contact',
            Status = 'Not Started',
            Priority = 'Normal'
        );
        insert task;

        // Retrieve and verify Task phone number before update
        Task insertedTask = [SELECT Id, Phone_Number__c FROM Task WHERE Id = :task.Id];
        System.assertEquals('9876543210', insertedTask.Phone_Number__c, 'Task phone number should match Contact phone number before update');

        // Now update the Task to remove the Contact (WhoId = null)
        task.WhoId = null;
        update task;

        // Retrieve the updated Task and check if the Phone_Number__c field remains unchanged
        Task updatedTask = [SELECT Id, Phone_Number__c FROM Task WHERE Id = :task.Id];
        System.assertEquals('9876543210', updatedTask.Phone_Number__c, 'Phone number should remain unchanged if WhoId is removed');
    }
}