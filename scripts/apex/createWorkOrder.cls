Id accountId = '0019Q00000cYMbNQAW';
Id caseId = '5009Q00000KdI84QAF';

Id serviceWORTId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Service Work Order').getRecordTypeId();

WorkOrder serviceWO = new WorkOrder(
    RecordTypeId = serviceWORTId,
    AccountId = accountId,
    CaseId = caseId
);
insert serviceWO;
System.debug('Service WorkOrder created = ' + serviceWO);
