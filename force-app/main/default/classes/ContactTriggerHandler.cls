public class ContactTriggerHandler {

    public static void beforeInsert(List<Contact> newContacts) {
        // Get existing contacts with the same mobile numbers
        Map<String, List<Contact>> existingContactsMap = existingContactsMap(newContacts);

        // Check conditions and update fields if necessary
        for (Contact newContact : newContacts) { 
            if (String.isNotEmpty(newContact.Phone) && existingContactsMap.containsKey(newContact.Phone)) {
                List<Contact> existingContacts = existingContactsMap.get(newContact.Phone);
                
                boolean sameNameExists = false;
                for (Contact existingContact : existingContacts) {
                    if (existingContact.FirstName == newContact.FirstName) {
                        sameNameExists = true;
                        newContact.addError('CARE003-A : User already exists with the same mobile number and name.');
                    }
                }
                 
                
            }
        }
    }

    public static void afterInsert(List<Contact> newContacts) {
        // Additional logic to be added here if necessary
        Map<String, List<Contact>> existingContactsMap = existingContactsMap(newContacts);
        
        //             --- relationship code
         // Collect new contacts by mobile phone
        
        Map<String, Contact> newContactsMap = new Map<String, Contact>();
        for (Contact newContact : newContacts) {
            if (String.isNotEmpty(newContact.Phone)) {
                newContactsMap.put(newContact.Phone, newContact);
                System.debug('New contact added to map: ' + newContact.FirstName + ' ' + newContact.Phone);
            }
        }

        if (newContactsMap.isEmpty()) {
            return;
        }

        // Create relationships
        List<npe4__Relationship__c> relationshipsToCreate = new List<npe4__Relationship__c>();
        Set<Id> newContactIdsToUpdate = new Set<Id>();
        for (String mobilePhone : existingContactsMap.keySet()) {
            List<Contact> existingContacts = existingContactsMap.get(mobilePhone);
            Contact newContact = newContactsMap.get(mobilePhone);

            for (Contact existingContact : existingContacts) {
                if (newContact != null && existingContact.FirstName != newContact.FirstName) {
                    npe4__Relationship__c newRelationship = new npe4__Relationship__c(
                        npe4__Contact__c = existingContact.Id,
                        npe4__RelatedContact__c = newContact.Id,
                        npe4__Type__c = 'Same Phone Number'
                    );
                    relationshipsToCreate.add(newRelationship);
                    System.debug('Preparing to create relationship between existing contact ' + existingContact.Id + ' and new contact ' + newContact.Id);
                    newContactIdsToUpdate.add(newContact.Id);
                }

            }
            
        }

        if (!relationshipsToCreate.isEmpty()) {
            try {
                insert relationshipsToCreate;
                System.debug('Relationships successfully inserted: ' + relationshipsToCreate);
                	
            } catch (DmlException e) {
                System.debug('Error inserting relationships: ' + e.getMessage());
            }
        } else {
            System.debug('No relationships to insert.');
        }
	 // Query new contacts again and update Phone, Phone, and phoneId__c fields
        if (!newContactIdsToUpdate.isEmpty()) {
            List<Contact> contactsToUpdate = [SELECT Id, Phone, phoneId__c FROM Contact WHERE Id IN :newContactIdsToUpdate];
            for (Contact contactToUpdate : contactsToUpdate) {
                contactToUpdate.Phone = null;
                //contactToUpdate.Phone = null;
                contactToUpdate.phoneId__c = null;
            }

            try {
                    update contactsToUpdate;
                System.debug('Contacts successfully updated: ' + contactsToUpdate);
            } catch (DmlException e) {
                System.debug('Error updating contacts: ' + e.getMessage());
            }
        } else {
            System.debug('No contacts to update.');
        }
    }
//    ---- relationship code ends
        
        
 

    /**
     * Retrieves a map of existing contacts by mobile numbers from a list of new contacts.
     *
     * @param newContacts The list of new contacts to check for existing mobile numbers.
     * @return A map where the key is the mobile phone number and the value is a list of existing contacts with that mobile number.
     */

    public static Map<String, List<Contact>> existingContactsMap(List<Contact> newContacts) {
        // Collect mobile phone numbers from new contacts
        Set<String> mobileNumbers = new Set<String>();
        for (Contact newContact : newContacts) {
            if (String.isNotEmpty(newContact.Phone)) {
                mobileNumbers.add(newContact.Phone);
            }
        }

        // Return empty map if no mobile numbers are collected
        if (mobileNumbers.isEmpty()) {
            return new Map<String, List<Contact>>();
        }

        // Query existing contacts with the same mobile numbers
        Map<String, List<Contact>> existingContactsMap = new Map<String, List<Contact>>();
        for (Contact existingContact : [
            SELECT Id, FirstName, Phone, phoneId__c
            FROM Contact
            WHERE Phone IN :mobileNumbers
        ]) {
            if (!existingContactsMap.containsKey(existingContact.Phone)) {
                existingContactsMap.put(existingContact.Phone, new List<Contact>());
            }
            existingContactsMap.get(existingContact.Phone).add(existingContact);
        }

        return existingContactsMap;
    }
}


































































 // --------------------modularized code
 /*
 public class ContactTriggerHandler {

    public static void beforeInsert(List<Contact> newContacts) {
        Map<String, List<Contact>> existingContactsMap = getExistingContactsMap(newContacts);

        for (Contact newContact : newContacts) { 
            checkForDuplicates(newContact, existingContactsMap);
        }
    }

    public static void beforeUpdate(List<Contact> updatedContacts) {
        Map<String, List<Contact>> existingContactsMap = getExistingContactsMap(updatedContacts);
        Map<String, Contact> updatedContactsMap = getUpdatedContactsMap(updatedContacts);

        List<npe4__Relationship__c> relationshipsToCreate = new List<npe4__Relationship__c>();
        Set<Id> contactsToUpdateIds = new Set<Id>();

        prepareRelationshipsForUpdate(existingContactsMap, updatedContactsMap, relationshipsToCreate, contactsToUpdateIds);

        if (!relationshipsToCreate.isEmpty()) {
            insertRelationships(relationshipsToCreate);
        }

        if (!contactsToUpdateIds.isEmpty()) {
            updateContactsFields(contactsToUpdateIds);
        }
    }

    public static void afterInsert(List<Contact> newContacts) {
        Map<String, List<Contact>> existingContactsMap = getExistingContactsMap(newContacts);
        Map<String, Contact> newContactsMap = getNewContactsMap(newContacts);
        List<npe4__Relationship__c> relationshipsToCreate = new List<npe4__Relationship__c>();
        Set<Id> newContactIdsToUpdate = new Set<Id>();

        prepareRelationships(existingContactsMap, newContactsMap, relationshipsToCreate, newContactIdsToUpdate);

        if (!relationshipsToCreate.isEmpty()) {
            insertRelationships(relationshipsToCreate);
        }

        if (!newContactIdsToUpdate.isEmpty()) {
            updateContactsFields(newContactIdsToUpdate);
        }
    }

    private static Map<String, List<Contact>> getExistingContactsMap(List<Contact> contacts) {
        Set<String> mobileNumbers = new Set<String>();
        for (Contact contact : contacts) {
            if (String.isNotEmpty(contact.MobilePhone)) {
                mobileNumbers.add(contact.MobilePhone);
            }
        }

        if (mobileNumbers.isEmpty()) {
            return new Map<String, List<Contact>>();
        }

        Map<String, List<Contact>> existingContactsMap = new Map<String, List<Contact>>();
        for (Contact existingContact : [
            SELECT Id, FirstName, MobilePhone, phoneId__c
            FROM Contact
            WHERE MobilePhone IN :mobileNumbers
        ]) {
            if (!existingContactsMap.containsKey(existingContact.MobilePhone)) {
                existingContactsMap.put(existingContact.MobilePhone, new List<Contact>());
            }
            existingContactsMap.get(existingContact.MobilePhone).add(existingContact);
        }

        return existingContactsMap;
    }

    private static Map<String, Contact> getUpdatedContactsMap(List<Contact> contacts) {
        Map<String, Contact> updatedContactsMap = new Map<String, Contact>();
        for (Contact contact : contacts) {
            if (String.isNotEmpty(contact.MobilePhone)) {
                updatedContactsMap.put(contact.MobilePhone, contact);
                System.debug('Updated contact added to map: ' + contact.FirstName + ' ' + contact.MobilePhone);
            }
        }
        return updatedContactsMap;
    }

    private static Map<String, Contact> getNewContactsMap(List<Contact> contacts) {
        Map<String, Contact> newContactsMap = new Map<String, Contact>();
        for (Contact contact : contacts) {
            if (String.isNotEmpty(contact.MobilePhone)) {
                newContactsMap.put(contact.MobilePhone, contact);
                System.debug('New contact added to map: ' + contact.FirstName + ' ' + contact.MobilePhone);
            }
        }
        return newContactsMap;
    }

    private static void checkForDuplicates(Contact newContact, Map<String, List<Contact>> existingContactsMap) {
        if (String.isNotEmpty(newContact.MobilePhone) && existingContactsMap.containsKey(newContact.MobilePhone)) {
            List<Contact> existingContacts = existingContactsMap.get(newContact.MobilePhone);

            for (Contact existingContact : existingContacts) {
                if (existingContact.FirstName == newContact.FirstName) {
                    newContact.addError('CARE 002 : User already exists with the same mobile number and name.');
                }
            }
        }
    }

    private static void prepareRelationshipsForUpdate(Map<String, List<Contact>> existingContactsMap, 
                                                      Map<String, Contact> updatedContactsMap,
                                                      List<npe4__Relationship__c> relationshipsToCreate,
                                                      Set<Id> contactsToUpdateIds) {
        for (String mobilePhone : existingContactsMap.keySet()) {
            List<Contact> existingContacts = existingContactsMap.get(mobilePhone);
            Contact updatedContact = updatedContactsMap.get(mobilePhone);

            for (Contact existingContact : existingContacts) {
                if (updatedContact != null && existingContact.FirstName != updatedContact.FirstName) {
                    npe4__Relationship__c newRelationship = new npe4__Relationship__c(
                        npe4__Contact__c = existingContact.Id,
                        npe4__RelatedContact__c = updatedContact.Id,
                        npe4__Type__c = 'Dummy Contact'
                    );
                    relationshipsToCreate.add(newRelationship);
                    System.debug('Preparing to create relationship between existing contact ' + existingContact.Id + ' and updated contact ' + updatedContact.Id);
                    contactsToUpdateIds.add(updatedContact.Id);
                }
            }
        }
    }

    private static void prepareRelationships(Map<String, List<Contact>> existingContactsMap, 
                                              Map<String, Contact> newContactsMap,
                                              List<npe4__Relationship__c> relationshipsToCreate,
                                              Set<Id> newContactIdsToUpdate) {
        for (String mobilePhone : existingContactsMap.keySet()) {
            List<Contact> existingContacts = existingContactsMap.get(mobilePhone);
            Contact newContact = newContactsMap.get(mobilePhone);

            for (Contact existingContact : existingContacts) {
                if (newContact != null && existingContact.FirstName != newContact.FirstName) {
                    npe4__Relationship__c newRelationship = new npe4__Relationship__c(
                        npe4__Contact__c = existingContact.Id,
                        npe4__RelatedContact__c = newContact.Id,
                        npe4__Type__c = 'Dummy Contact'
                    );
                    relationshipsToCreate.add(newRelationship);
                    System.debug('Preparing to create relationship between existing contact ' + existingContact.Id + ' and new contact ' + newContact.Id);
                    newContactIdsToUpdate.add(newContact.Id);
                }
            }
        }
    }

    private static void insertRelationships(List<npe4__Relationship__c> relationshipsToCreate) {
        try {
            insert relationshipsToCreate;
            System.debug('Relationships successfully inserted: ' + relationshipsToCreate);
        } catch (DmlException e) {
            System.debug('Error inserting relationships: ' + e.getMessage());
        }
    }

    private static void updateContactsFields(Set<Id> contactIdsToUpdate) {
        List<Contact> contactsToUpdate = [SELECT Id, Phone, MobilePhone, phoneId__c FROM Contact WHERE Id IN :contactIdsToUpdate];
        for (Contact contactToUpdate : contactsToUpdate) {
            contactToUpdate.Phone = null;
            contactToUpdate.MobilePhone = null;
            contactToUpdate.phoneId__c = null;
        }

        try {
            update contactsToUpdate;
            System.debug('Contacts successfully updated: ' + contactsToUpdate);
        } catch (DmlException e) {
            System.debug('Error updating contacts: ' + e.getMessage());
        }
    }
}

*/