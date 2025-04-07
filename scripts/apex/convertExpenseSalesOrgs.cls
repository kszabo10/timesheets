List<Expense> expenses = new List<Expense>([
    select Id, HDM_SalesOrganization__c, HDM_Time_Sheet__r.ServiceResource.RelatedRecord.HDM_SAPSalesOrganization__c
    from Expense
]);
System.debug('expenses size1 = ' + expenses.size());
for(Expense exp : expenses){
    exp.HDM_SalesOrganization__c = exp.HDM_Time_Sheet__r.ServiceResource.RelatedRecord.HDM_SAPSalesOrganization__c;
    System.debug('to be updated expense = ' + exp + ',  input Sales Org = ' + exp.HDM_Time_Sheet__r.ServiceResource.RelatedRecord.HDM_SAPSalesOrganization__c);
}
update expenses;
System.debug('Expense update ends');
