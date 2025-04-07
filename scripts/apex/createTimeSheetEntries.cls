Id timeSheetId = '1ts9Z000000J9mgQAC';
List<TimeSheetEntry> tses = new List<TimeSheetEntry>();

TimeSheet ts = [
    select Id, ServiceResourceId
    from TimeSheet
    where Id = :timeSheetId
    limit 1
];

List<HDM_Time_Code__c> timeCodes = new List<HDM_Time_Code__c>([
    select Id, Name, HDM_Sales_Organisation__c
    from HDM_Time_Code__c
    where HDM_Sales_Organisation__c = 'S440'
]);
for(HDM_Time_Code__c tc : timeCodes){
    System.debug('Next TimeCode = ' + tc);
}

Map<String, Id> timeCodeMap = new Map<String, Id>();
for(HDM_Time_Code__c tc : timeCodes){
    timeCodeMap.put(tc.Name, tc.Id);
}
for(String timeCodeName : timeCodeMap.keySet()){
    System.debug('Next Timecode Name = ' + timeCodeName);
}


Id workOrderId = '0WO9Z000004R3ltWAC';
List<WorkOrderLineItem> wolis = new List<WorkOrderLineItem>([
    select Id
    from WorkOrderLineItem
    where WorkOrderId = :workOrderId
]);
System.debug('WorkOrderLineItem size = ' + wolis.size());

// 1
Date startDate = Date.newInstance(2025, 01, 23);
Time startT = Time.newInstance(10,45,0,0);
Time endT = Time.newInstance(11,0,0,0);
TimeSheetEntry tse = new TimeSheetEntry(
    TimeSheetId = ts.Id,
    StartTime = DateTime.newInstance(startDate, startT),
    EndTime = DateTime.newInstance(startDate, endT),
    HDM_Time_Code__c = timeCodeMap.get('Viaje (OR)'),
    WorkOrderId = workOrderId,
    WorkOrderLineItemId = wolis.get(0).Id
);
tses.add(tse);

// 2
startT = Time.newInstance(11,00,0,0);
endT = Time.newInstance(11,15,0,0);
tse = new TimeSheetEntry(
    TimeSheetId = ts.Id,
    StartTime = DateTime.newInstance(startDate, startT),
    EndTime = DateTime.newInstance(startDate, endT),
    HDM_Time_Code__c = timeCodeMap.get('Asueto (ABS)'),
    WorkOrderId = workOrderId,
    WorkOrderLineItemId = wolis.get(0).Id
);
tses.add(tse);

// 3
startT = Time.newInstance(12,00,0,0);
endT = Time.newInstance(12,30,0,0);
tse = new TimeSheetEntry(
    TimeSheetId = ts.Id,
    StartTime = DateTime.newInstance(startDate, startT),
    EndTime = DateTime.newInstance(startDate, endT),
    HDM_Time_Code__c = timeCodeMap.get('Servicio (OR)'),
    WorkOrderId = workOrderId,
    WorkOrderLineItemId = wolis.get(0).Id
);
tses.add(tse);

// 4
startT = Time.newInstance(12,30,0,0);
endT = Time.newInstance(12,45,0,0);
tse = new TimeSheetEntry(
    TimeSheetId = ts.Id,
    StartTime = DateTime.newInstance(startDate, startT),
    EndTime = DateTime.newInstance(startDate, endT),
    HDM_Time_Code__c = timeCodeMap.get('Apoyo a GSC en campo(NOR)'),
    WorkOrderId = workOrderId,
    WorkOrderLineItemId = wolis.get(0).Id
);
tses.add(tse);

// 5
startT = Time.newInstance(13,0,0,0);
endT = Time.newInstance(13,30,0,0);
tse = new TimeSheetEntry(
    TimeSheetId = ts.Id,
    StartTime = DateTime.newInstance(startDate, startT),
    EndTime = DateTime.newInstance(startDate, endT),
    HDM_Time_Code__c = timeCodeMap.get('Servicio (OR)'),
    WorkOrderId = workOrderId,
    WorkOrderLineItemId = wolis.get(0).Id
);
tses.add(tse);

// 6
startT = Time.newInstance(14,0,0,0);
endT = Time.newInstance(14,45,0,0);
tse = new TimeSheetEntry(
    TimeSheetId = ts.Id,
    StartTime = DateTime.newInstance(startDate, startT),
    EndTime = DateTime.newInstance(startDate, endT),
    HDM_Time_Code__c = timeCodeMap.get('Viaje (OR)'),
    WorkOrderId = workOrderId,
    WorkOrderLineItemId = wolis.get(0).Id
);
tses.add(tse);
insert tses;