Id serviceResourceId = '0Hn9Q0000010HJdSAM';

Integer weeksAhead = 12;
Boolean isMonthEndSplit = false;

ServiceResource sr = [
    select Id, RelatedRecordId, RelatedRecord.HDM_SAPSalesOrganization__c
    from ServiceResource
    where Id = :serviceResourceId
    limit 1
];
List<TimeSheet> generatedTimeSheets = HDM_TimeSheetutils.createTimeSheets(sr, isMonthEndSplit, weeksAhead);
insert generatedTimeSheets;

