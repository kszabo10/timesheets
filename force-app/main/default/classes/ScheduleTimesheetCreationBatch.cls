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
		/*HDM_BatchProcessConfig__mdt batchConfig = HDM_BatchProcessConfig__mdt.getInstance(
			BATCH_CODE
		);
	
		if (
			batchConfig != null &&
			batchConfig.HDM_Size_Of_The_Batch__c != null &&
			batchConfig.HDM_Active__c
		) {
			Database.executeBatch(
			new TimeSheetCreationBatch(batchConfig),
			Integer.valueOf(batchConfig.HDM_Size_Of_The_Batch__c)
			);
		}*/
	}
}