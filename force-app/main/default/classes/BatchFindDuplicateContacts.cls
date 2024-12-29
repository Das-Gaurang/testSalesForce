public class BatchFindDuplicateContacts implements Database.Batchable<SObject>, Database.Stateful {
    
    // Query to get all contacts
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, FirstName, Phone
            FROM Contact
            WHERE Phone != null
        ]);
    }
    
    public void execute(Database.BatchableContext BC, List<Contact> scope) {
        // Map to hold phone numbers and corresponding contact lists
        Map<String, List<Contact>> phoneToContactsMap = new Map<String, List<Contact>>();
        
        // Group contacts by phone number
        for(Contact con : scope) {
            if(phoneToContactsMap.containsKey(con.Phone)) {
                phoneToContactsMap.get(con.Phone).add(con);
            } else {
                phoneToContactsMap.put(con.Phone, new List<Contact>{con});
            }
        }
        
        List<Contact> contactsToUpdate = new List<Contact>();
        List<DuplicateContact__c> duplicatesToCreate = new List<DuplicateContact__c>();
        
        // Iterate over grouped contacts to find duplicates
        for(String phone : phoneToContactsMap.keySet()) {
            List<Contact> contacts = phoneToContactsMap.get(phone);
            
            if(contacts.size() > 1) {
                // Compare first names and create duplicate relationships
                for(Integer i = 0; i < contacts.size(); i++) {
                    for(Integer j = i + 1; j < contacts.size(); j++) {
                        if(contacts[i].FirstName != contacts[j].FirstName) {
                            DuplicateContact__c duplicate = new DuplicateContact__c(
                                Contact1__c = contacts[i].Id,
                                Contact2__c = contacts[j].Id
                            );
                            duplicatesToCreate.add(duplicate);
                        }
                    }
                    
                    // Nullify phone number for all contacts except the first one
                    if (i > 0) {
                        contacts[i].Phone = null;
                        contactsToUpdate.add(contacts[i]);
                    }
                }
            }
        }
        
        // Update contacts and insert duplicate relationships
        if(!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
        if(!duplicatesToCreate.isEmpty()) {
            insert duplicatesToCreate;
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        // Optionally log the completion or send an email notification
    }
}