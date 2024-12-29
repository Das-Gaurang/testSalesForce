global class DuplicateContactManageBatchJob implements Database.Batchable<sObject>
{
    public static final String indianNumberRegex = '^(?:\\+91|91|0)?[6-9]\\d{9}$';
    public static final String internationalNumberRegex = '^\\+?(?:[0-9] ?){6,14}[0-9]$';
    
    private String queryParameter;

    public DuplicateContactManageBatchJob(String queryParam) {
        queryParameter = queryParam;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        
        String query = 'SELECT Id, FirstName, LastName, Phone, phoneId__c, MobilePhone FROM Contact WHERE ' + queryParameter;
       
        return Database.getQueryLocator(query);
    }                                                                                                   
    global void execute(Database.BatchableContext BC, List<Contact> scope)
    {
        Map<String, List<Contact>> phoneToContactsMap = new Map<String, List<Contact>>();
        // Step 3: Populate the map with contacts grouped by phone number
        for (Contact contact : scope) {
            String mobile = contact.phone.replaceAll('\\s+', '').replaceAll('[^0-9]', '').replaceFirst('^0+', '');
            system.debug('HK mohit '+mobile);
            if (Pattern.matches(indianNumberRegex, mobile)) {
                if (!mobile.startsWith('+91')) {
                    mobile = '+91' + mobile.substring(mobile.length() - 10);
                }
                
            } else if (Pattern.matches(internationalNumberRegex, mobile)) {
                if (!mobile.startsWith('+')) {
                    mobile = '+' + mobile;
                }
            } 
            else {
                mobile = null;
            }
            if (!phoneToContactsMap.containsKey(mobile)) {
                phoneToContactsMap.put(mobile, new List<Contact>());
            }
            contact.Phone = mobile;
            contact.phoneId__c = mobile;
            contact.MobilePhone = mobile;
            phoneToContactsMap.get(mobile).add(contact);
        }

        // Step 4: Process each group of contacts with the same phone number
        List<npe4__Relationship__c> relationshipsToInsert = new List<npe4__Relationship__c>();
        List<Contact> contactsToUpdate = new List<Contact>();

        for (String phone : phoneToContactsMap.keySet()) {
            List<Contact> contactGroup = phoneToContactsMap.get(phone);

            if (contactGroup.size() > 1) {
                // Keep the phone number of the first contact, nullify others
                for (Integer i = 1; i < contactGroup.size(); i++) {
                    contactGroup[i].Phone = null;
                    contactGroup[i].phoneId__c = null;
                    contactGroup[i].MobilePhone = null;
                    contactsToUpdate.add(contactGroup[i]);
                }

                // Create 'Duplicate Contact' relationships between the first contact and the rest
                for (Integer i = 1; i < contactGroup.size(); i++) {
                    npe4__Relationship__c relationship = new npe4__Relationship__c();
                    relationship.npe4__Contact__c = contactGroup[0].Id;
                    relationship.npe4__RelatedContact__c = contactGroup[i].Id;
                    relationship.npe4__Type__c = 'Duplicate Contact';
                    relationshipsToInsert.add(relationship);
                }
            }
        }

        System.debug('Contacts to update: ' + contactsToUpdate);
        System.debug('Relationships to insert: ' + relationshipsToInsert);
		
        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
        
        // Step 5: Update contacts and insert relationships
        if (!scope.isEmpty()) {
            update scope;
        }

        if (!relationshipsToInsert.isEmpty()) {
            insert relationshipsToInsert;
        }

        System.debug('Finished establishDuPlicateContactRelationships method');
    }
    global void finish(Database.BatchableContext BC) {
    }
}