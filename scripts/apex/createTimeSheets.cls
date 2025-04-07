List<ServiceResource> srs = TimeSheetCreation.queryServiceResources();
System.debug('srs size = ' + srs.size());
for(ServiceResource sr : srs){
    System.debug('Service Resource Name = ' + sr.Name);
    for(TimeSheet ts : sr.TimeSheets){
        System.debug('- - related next Time Sheet StartDate = ' + ts.StartDate + ', End Date = ' + ts.EndDate);
    }
}
TimeSheetCreation.generateTimeSheets(srs);

