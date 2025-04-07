HDM_BatchProcessConfig__mdt batchCMT = [
    select Id, Label,HDM_Parameter_1__c
    from HDM_BatchProcessConfig__mdt
    where Label = 'HDM Schedule Time Sheet Creation Batch'
    limit 1
];
HDM_TimeSheetCreationBatch newBatch = new HDM_TimeSheetCreationBatch(batchCMT);
Id batchJobId = Database.executeBatch(newBatch, 200);