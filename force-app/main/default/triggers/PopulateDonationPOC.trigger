trigger PopulateDonationPOC on Opportunity (before insert) {
    // Collect Contact IDs from the opportunities being created
    Set<Id> contactIds = new Set<Id>();
    for (Opportunity opp : Trigger.new) {
        if (opp.npsp__Primary_Contact__c != null && opp.Donation_POC__c == null) {
            contactIds.add(opp.npsp__Primary_Contact__c);
        }
    }

    // Query Contacts and fetch Fundraiser__c values
    Map<Id, Contact> contactMap = new Map<Id, Contact>(
        [SELECT Id, Fundraiser__c FROM Contact WHERE Id IN :contactIds]
    );

    // Update the Donation_POC__c field on the opportunities
    for (Opportunity opp : Trigger.new) {
        if (opp.npsp__Primary_Contact__c != null && opp.Donation_POC__c == null) {
            Contact primaryContact = contactMap.get(opp.npsp__Primary_Contact__c);
            if (primaryContact != null) {
                opp.Donation_POC__c = primaryContact.Fundraiser__c;
            }
        }
    }
}