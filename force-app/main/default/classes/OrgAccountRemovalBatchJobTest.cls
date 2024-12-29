@isTest(SeeAllData=false)
private class OrgAccountRemovalBatchJobTest {
    @isTest static void testGetExistingReceiptOrCreate() {
        
        Account acc = new Account();
        acc.name = 'hari';
        insert acc;
        
        Contact con = new Contact();
        con.lastname = 'test';
        con.phone = '+919999999999';
        con.account = acc;
        insert con;
      	
        Test.startTest();
            OrgAccountRemovalBatchJob obj = new OrgAccountRemovalBatchJob('Phone != null');
			DataBase.executeBatch(obj);
        Test.stopTest();
    }
}