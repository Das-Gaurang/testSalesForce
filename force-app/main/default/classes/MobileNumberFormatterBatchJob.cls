global class MobileNumberFormatterBatchJob implements Database.Batchable<sObject>
{
    public static final String indianNumberRegex = '^(?:\\+91|91|0)?[6-9]\\d{9}$';
    public static final String internationalNumberRegex = '^\\+?(?:[0-9] ?){6,14}[0-9]$';
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        
        String query = 'SELECT Id, Phone FROM Contact WHERE phone != null';
       
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Contact> scope)
    {
        List<Contact> contactsToUpdate = new List<Contact>();
        for (Contact contact : scope) {
            String mobile = contact.phone.replaceAll('\\s+', '').replaceAll('[^0-9]', '');
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
            contact.phone = mobile;
            //contact.phone = mobile;
            //contact.phoneId__c = mobile;
            contactsToUpdate.add(contact);
            
        }

        // Update the contacts
         if (!contactsToUpdate.isEmpty()) {
             update contactsToUpdate;
        }
    }
    global void finish(Database.BatchableContext BC) {
    }
}