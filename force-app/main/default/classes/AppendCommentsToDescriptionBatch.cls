global class AppendCommentsToDescriptionBatch implements Database.Batchable<SObject>, Database.Stateful {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Select all contacts without filtering, we will check Comments__c within the execute method
        return Database.getQueryLocator([SELECT Id, Description, Comments__c FROM Contact]);
    }

    global void execute(Database.BatchableContext bc, List<Contact> scope) {
        List<Contact> contactsToUpdate = new List<Contact>();

        for (Contact contactRecord : scope) {
            // Only process records where Comments__c has data
            if (!String.isBlank(contactRecord.Comments__c)) {
                // Preserve existing Description or set to empty if null
                String existingDescription = contactRecord.Description != null ? contactRecord.Description : '';
                String appendText = 'Desc: ' + contactRecord.Comments__c;

                // Append Comments__c content to Description
                contactRecord.Description = existingDescription + (existingDescription != '' ? ' ' : '') + appendText;

                // Clear the Comments__c field to avoid redundancy in future runs
                contactRecord.Comments__c = null;

                // Add to the list for bulk update
                contactsToUpdate.add(contactRecord);
            }
        }

        // Update only the contacts that had Comments__c data
        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
    }

    global void finish(Database.BatchableContext bc) {
        // Optional: Add logging, notifications, or other final steps here
    }
}