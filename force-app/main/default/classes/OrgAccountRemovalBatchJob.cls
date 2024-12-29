global class OrgAccountRemovalBatchJob implements Database.Batchable<sObject> {
    
    private String queryParameter;

    public OrgAccountRemovalBatchJob(String queryParam) {
        queryParameter = queryParam;
    }
        
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        
        String query = 'SELECT Id,accountId FROM Contact WHERE ' + queryParameter;
       	System.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope)
    {
        for (Contact contact : scope) {
            contact.AccountId = null;
        }
        if (!scope.isEmpty()) {
            update scope;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    }

}