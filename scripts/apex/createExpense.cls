Id workOrderId = '0WO9Q000003ibWnWAI';
Id serviceAppointmentId = '08p9Q000001yLCHQA2';
Id workOrderLineItemId = '1WL9Q000001TNwjWAG';
Id timeSheetId = '1ts9Q000002AgQjQAK';
Id expenseTypeId = 'a8H9Q0000002JhhUAE';

Expense testExpense = new Expense(
    WorkOrderId = workOrderId,
    HDM_SA_Number__c = serviceAppointmentId,
    HDM_Work_Order_Line_Item__c = workOrderLineItemId,
    HDM_Time_Sheet__c = timeSheetId,
    HDM_Expense_Type__c = expenseTypeId,
    ExpenseType = 'Flight Ticket',
    Amount = 250.0,
    TransactionDate = Date.today()
);
insert testExpense;
System.debug('testExpense created = ' + testExpense);

