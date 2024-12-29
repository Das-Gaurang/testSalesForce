trigger ContactDuplicateValidation on Contact (before insert, before update) {
    // Set to hold normalized phone numbers for comparison
    Set<String> newPhones = new Set<String>();
    Set<String> newWorkPhones = new Set<String>();
    
    // Prepare a map to track errors
    Map<Id, String> recordErrors = new Map<Id, String>();

    for (Contact con : Trigger.new) {
        // Normalize Phone and Work Phone numbers for consistency
        String normalizedPhone = ContactHelper.normalizePhone(con.Phone);
        String normalizedWorkPhone = ContactHelper.normalizePhone(con.npe01__WorkPhone__c);

        // Check if Phone and Work Phone within the same record are different
        if (normalizedPhone == normalizedWorkPhone) {
            con.addError('Phone and Work Phone cannot have the same value within the same record.');
        }

        // Add to sets for comparison with database
        if (!String.isEmpty(normalizedPhone)) newPhones.add(normalizedPhone);
        if (!String.isEmpty(normalizedWorkPhone)) newWorkPhones.add(normalizedWorkPhone);
    }

    // Query existing contacts for duplicates
    List<Contact> existingContacts = [
        SELECT Id, Phone, npe01__WorkPhone__c
        FROM Contact
        WHERE Phone IN :newPhones
           OR npe01__WorkPhone__c IN :newPhones
           OR Phone IN :newWorkPhones
           OR npe01__WorkPhone__c IN :newWorkPhones
    ];

    // Check for conflicts with existing records
    for (Contact con : Trigger.new) {
        String normalizedPhone = ContactHelper.normalizePhone(con.Phone);
        String normalizedWorkPhone = ContactHelper.normalizePhone(con.npe01__WorkPhone__c);

        for (Contact existing : existingContacts) {
            if (existing.Id != con.Id) { // Ignore self when updating
                String existingPhone = ContactHelper.normalizePhone(existing.Phone);
                String existingWorkPhone = ContactHelper.normalizePhone(existing.npe01__WorkPhone__c);

                // Check Phone conflicts
                if (normalizedPhone == existingPhone || normalizedPhone == existingWorkPhone) {
                    recordErrors.put(con.Id, 'The Phone number matches an existing Contact\'s Phone or Work Phone.');
                }
                // Check Work Phone conflicts
                if (normalizedWorkPhone == existingPhone || normalizedWorkPhone == existingWorkPhone) {
                    recordErrors.put(con.Id, 'The Work Phone number matches an existing Contact\'s Phone or Work Phone.');
                }
            }
        }
    }

    // Add errors to trigger records
    for (Contact con : Trigger.new) {
        if (recordErrors.containsKey(con.Id)) {
            con.addError(recordErrors.get(con.Id));
        }
    }
}