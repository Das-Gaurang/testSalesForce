@isTest(SeeAllData=false)
private class MobileNumberFormatterBatchJobTest {
		 @isTest static void testGetExistingReceiptOrCreate() {
        Contact con1 = new Contact();
        con1.lastname = 'test';
        con1.phone = '9999999999';
        insert con1;
        Test.startTest();
            MobileNumberFormatterBatchJob obj = new MobileNumberFormatterBatchJob();
			DataBase.executeBatch(obj);
        Test.stopTest();
    }
}