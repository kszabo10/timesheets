Id serviceResourceId = '0Hn9Q0000010HJdSAM';

List<Id> srIds = new List<Id>();

srIds.add(serviceResourceId);
ServiceResource sr = [
    select Id, RelatedRecordId, RelatedRecord.HDM_SAPSalesOrganization__c
    from ServiceResource
    where Id = :serviceResourceId
    limit 1
];
List<Integer> generatedTimeSheets = HDM_TimeSheetutils.createSRTimeSheets(srIds);

