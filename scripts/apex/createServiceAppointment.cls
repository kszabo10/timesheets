Id serviceUserId = '0052p00000AfKvAAAV';        // Andreas Baumgarten
Id WOLIServiceWokrOrderRTId =  Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByName().get('Service Work Order Line Item').getRecordTypeId();
Id workOrderLineItemId = '1WL9Q000001Zt4KWAS';
Id accountId = '0019Q00000kt9oiQAA'; // Hornberger Druck GmbH
System.debug('WOLIServiceWokrOrderRTId = ' + WOLIServiceWokrOrderRTId);

User usr = [
    select Id, UserName, FirstName, LastName 
    from User
    where Id = : serviceUserId
    limit 1
];



system.debug('service User = ' + usr);

/* Required fields to create an SA
WOLI
WO
Parent Record
Status
Case ?
Subject

*/

ServiceResource sr = [
    select Id, RelatedRecordId, RelatedRecord.HDM_SAPSalesOrganization__c
    from ServiceResource
    where RelatedRecordId = :serviceUserId
    limit 1
];

System.debug('sr = ' + sr);

ServiceAppointment sa = new ServiceAppointment(
    HDM_Assigned_Service_Resource__c = sr.Id,
    AccountId = accountId,
    Description = 'ApexTest Description',
    HDM_Parent_Work_Order_Line_Item__c = workOrderLineItemId,
    Status = 'Created'

);
insert sa;


//List<TimeSheet> generatedTimeSheets = HDM_TimeSheetutils.createTimeSheets(sr, isMonthEndSplit, weeksAhead);
//insert generatedTimeSheets;

