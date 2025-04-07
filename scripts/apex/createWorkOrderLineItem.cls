Id accountId = '0019Q00000cYMbNQAW';
//Id caseId = '5009Q00000KdI84QAF';
Id workOrderId = '0WO9Q000004hS3ZWAU';

Id serviceWOLIRTId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByName().get('Service Work Order Line Item').getRecordTypeId();

WorkOrderLineItem serviceWOLI = new WorkOrderLineItem(
    RecordTypeId = serviceWOLIRTId,
    HDM_Account__c = accountId,
    WorkOrderId = workOrderId
);
insert serviceWOLI;
System.debug('Service WorkOrder LineItem created = ' + serviceWOLI);
