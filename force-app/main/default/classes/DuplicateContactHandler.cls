public class DuplicateContactHandler {

    public static void handleDuplicateContacts(List<Contact> newContacts) {
        Set<String> phoneNumbers = new Set<String>();
        
        // Collect phone numbers from the new contacts
        for(Contact con : newContacts) {
            if(con.Phone != null) {
                phoneNumbers.add(con.Phone);
            }
        }
        
        if(phoneNumbers.isEmpty()) {
            return; // No phone numbers to check
        }
        
        // Query existing contacts with the same phone numbers
        Map<String, List<Contact>> existingContactsMap = new Map<String, List<Contact>>();
        for(Contact existingCon : [
            SELECT Id, FirstName, Phone 
            FROM Contact 
            WHERE Phone IN :phoneNumbers
        ]) {
            if(!existingContactsMap.containsKey(existingCon.Phone)) {
                existingContactsMap.put(existingCon.Phone, new List<Contact>());
            }
            existingContactsMap.get(existingCon.Phone).add(existingCon);
        }

        for(Contact newCon : newContacts) {
            if(newCon.Phone != null && existingContactsMap.containsKey(newCon.Phone)) {
                List<Contact> existingContacts = existingContactsMap.get(newCon.Phone);
                
                Boolean exactMatchFound = false;
                
                for(Contact existingCon : existingContacts) {
                    if(existingCon.FirstName == newCon.FirstName) {
                        newCon.addError('Contact already exists with the same name and phone number.');
                        exactMatchFound = true;
                        break;
                    }
                }
                
                if(!exactMatchFound) {
                    // Nullify phone number for the new contact if no exact match found
                    newCon.Phone = null;
                    
                    // Relate the new contact to the first existing contact with the same phone number
                    if(existingContacts.size() > 0) {
                        newCon.AccountId = existingContacts[0].AccountId;
                        // Add more relationships as needed (e.g., ReportsToId, Other custom relationships)
                        // newCon.Relationship__c = existingContacts[0].Id;
                    }
                }
            }
        }
    }
}