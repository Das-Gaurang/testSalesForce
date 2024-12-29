trigger TaskPhoneTrigger on Task (before insert, before update) {
    // Collect all related Contact Ids from tasks
    Set<Id> contactIds = new Set<Id>();

    // Loop through all Task records and gather the Contact Ids (those starting with '003' for Contact)
    for (Task task : Trigger.new) {
        if (task.WhoId != null && String.valueOf(task.WhoId).startsWith('003')) {
            contactIds.add(task.WhoId);  // Add WhoId to the set of contactIds
        }
    }

    // Query related Contacts only if there are any Contact Ids to fetch
    Map<Id, Contact> contactMap = new Map<Id, Contact>();
    if (!contactIds.isEmpty()) {
        contactMap = new Map<Id, Contact>([SELECT Id, Phone FROM Contact WHERE Id IN :contactIds]);
    }

    // Loop through tasks and set the Phone Number from related Contact
    for (Task task : Trigger.new) {
        if (task.WhoId != null && contactMap.containsKey(task.WhoId)) {
            String contactPhone = contactMap.get(task.WhoId).Phone;

            // Only update Task.Phone_Number__c if Contact's Phone is NOT blank
            if (String.isNotBlank(contactPhone)) {
                task.Phone_Number__c = contactPhone;  // Set phone number from related contact
            }
            // If contact phone is blank, do not overwrite Task.Phone_Number__c
        }
    }
}