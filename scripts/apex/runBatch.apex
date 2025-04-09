TimesheetGeneration__mdt batchConfig = TimesheetGeneration__mdt.getInstance(
    'Timesheet_info'
);
Database.executeBatch(
    new TimeSheetCreationBatch((Integer) batchConfig.WeeksAhead__c), (Integer) batchConfig.BatchSize__c
);