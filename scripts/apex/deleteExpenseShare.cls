List<ExpenseShare> expenseShares = new List<ExpenseShare>([
    select Id, Parent.ExpenseNumber, RowCause
    from ExpenseShare
    where RowCause = 'Manual'
    limit 5000
]);
delete expenseShares;
