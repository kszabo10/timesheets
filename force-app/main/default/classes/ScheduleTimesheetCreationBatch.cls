/*
 * ===================================================================
 * @author      
 * @email       
 * @version
 * @date        
 * @description Create Time Sheet records for the active Service Resources
 *              as a batch process
 * ===================================================================
 */
public class ScheduleTimesheetCreationBatch implements Schedulable {
    private static final String BATCH_CODE = 'ScheduleTimeSheetCreationBatch';
  
    public void execute(SchedulableContext sc) {
		TimesheetGeneration__mdt batchConfig = TimesheetGeneration__mdt.getInstance(
            'Timesheet_info'
        );
        TimeSheetCreationBatch newBatch = new TimeSheetCreationBatch((Integer) batchConfig.WeeksAhead__c);
        Database.executeBatch(newBatch, (Integer) batchConfig.BatchSize__c);

	}
}