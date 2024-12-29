trigger AppendCommentsToDescription on Contact (before update) {
    for (Contact contactRecord : Trigger.new) {
        // Check if Comments__c has data and if Description needs to be updated
        if (!String.isBlank(contactRecord.Comments__c)) {
            // Set existingDescription to the current Description or an empty string if null
            String existingDescription = contactRecord.Description != null ? contactRecord.Description : '';
            
            // Format the appended text with "Desc: " followed by the comment
            String appendText = 'Comments: ' + contactRecord.Comments__c;
            
            // Append the text to Description with a space if Description already has content
            contactRecord.Description = existingDescription + (existingDescription != '' ? ' ' : '') + appendText;
        }
    }
}