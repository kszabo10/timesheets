List<TimeSheet> timesheets = new List<TimeSheet>([
    select Id, OwnerId, ServiceResource.OwnerId, HDM_Sales_Organisation__c, HDM_SalesOrganization__c
    from TimeSheet
	where HDM_Sales_Organisation__c = 'S450'
	and EndDate > 2024-12-31
]);
System.debug('timesheets size1 = ' + timesheets.size());
for(TimeSheet ts : timesheets){
    ts.HDM_SalesOrganization__c = 'S450';
}
update timesheets;
System.debug('timesheets size2 = ' + timesheets.size());
