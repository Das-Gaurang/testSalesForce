public with sharing class ContactController {
    
    // Method to get all contact records
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts() {
        try {
            return [SELECT Id, FirstName, LastName, Email, Phone,Country__c, States_UT__c, City__c, Full_Address__c, Birthdate FROM Contact LIMIT 50];  // Fetching 50 contacts
            // return [SELECT Id, FirstName, LastName, Email, Phone, Full_Address__c FROM Contact LIMIT 100];  // Fetching 100 contacts
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching contacts: ' + e.getMessage());
        }
    }

    // Method to save contact updates
    @AuraEnabled
    public static void saveContacts(List<Contact> updatedContacts) {
        try {
            update updatedContacts;  // Updating the contact list passed from LWC
        } catch (DmlException e) {
            throw new AuraHandledException('Error updating contacts: ' + e.getMessage());
        }
    }
}