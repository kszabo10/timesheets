Id stanpacId = '0019Q00000cYMbNQAW';
Id serviceCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Case').getRecordTypeId();
Id productCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Product Case').getRecordTypeId();

Case serviceCase = new Case(
    RecordTypeId = serviceCaseRTId,
    AccountId = stanpacId,
    Subject = 'Zoltan Test Subject'
);
insert serviceCase;
System.debug('Service Case create = ' + serviceCase);

