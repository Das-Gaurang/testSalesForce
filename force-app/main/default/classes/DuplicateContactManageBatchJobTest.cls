@isTest(SeeAllData=false)
private class DuplicateContactManageBatchJobTest {
    @isTest static void testGetExistingReceiptOrCreate() {
        Contact con = new Contact();
        con.lastname = 'test';
        con.phone = '+919999999999';
        insert con;
        Contact con1 = new Contact();
        con1.lastname = 'test';
        con1.phone = '+919999999999';
        insert con1;
        Test.startTest();
            DuplicateContactManageBatchJob obj = new DuplicateContactManageBatchJob('Phone != null order by phone');
			DataBase.executeBatch(obj);
        Test.stopTest();
    }
}