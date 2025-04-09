@isTest
public class TimeSheetCreationBatchTest {


    @testSetup
    static void setupTestData() {
        // Create user records for ServiceResource
        TestDataFactory.createUsers();
    }

    @isTest
    static void batchExecutionTest() {
        // Run the batch job
        Test.startTest();
        TestDataFactory.createSalesOrganizations();

        // Create ServiceResource records for the test
        List<ServiceResource> serviceResources = TestDataFactory.createServiceResources();
        TimesheetGeneration__mdt batchConfig = TimesheetGeneration__mdt.getInstance(
            'Timesheet_info'
        );
        TimeSheetCreationBatch newBatch = new TimeSheetCreationBatch((Integer) batchConfig.WeeksAhead__c);
        Database.executeBatch(newBatch, (Integer) batchConfig.BatchSize__c);
        Test.stopTest();

        // Verify if new TimeSheets have been created
        Integer newTimeSheetCount = [
            select count() 
            from TimeSheet 
            where Status = 'New'];
        Assert.isTrue(newTimeSheetCount > 0, 'New TimeSheet records should be created by the batch.');
    }


    @isTest
    static void scheduleTest() {
        Datetime scheduleTime = Datetime.now().addSeconds(5);
        String cronExp = '' + scheduleTime.second() + ' ' + scheduleTime.minute() + ' ' + 
                    scheduleTime.hour() + ' ' + scheduleTime.day() + ' ' + 
                    scheduleTime.month() + ' ? ' + scheduleTime.year();

        ScheduleTimeSheetCreationBatch job = new ScheduleTimeSheetCreationBatch();
        String jobID = System.schedule('Timesheet Creation Batch Test', cronExp, job);
    }
    


}