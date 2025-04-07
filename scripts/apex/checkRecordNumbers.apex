// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

List<Account> accounts = [select Id from Account];
List<Contact> contacts = [select Id from Contact];
List<Case> cases = [select Id from Case];
List<HDM_Expense_Type__c> expenseTypes = [select Id from HDM_Expense_Type__c];
List<OperatingHours> operatingHours = [select Id from OperatingHours];
List<ServiceTerritory> serviceTerritories = [select Id from ServiceTerritory];
List<HDM_Time_Code__c> timeCodes = [select Id from HDM_Time_Code__c];
List<HDM_Service_Sales_Organization__c> serviceSalesOrgs = [select Id from HDM_Service_Sales_Organization__c];
List<HDM_Technician_Questionnaire__c> technicianQuestionnaires = [select Id from HDM_Technician_Questionnaire__c];
List<HDM_Technician_Questionnaire_Question__c> technicianQuestionnaireQuestions = [select Id from HDM_Technician_Questionnaire_Question__c];
List<HDM_WorkCenter__c> workCenters = [select Id from HDM_WorkCenter__c];
List<HDM_Assigned_Work_Center__c> assignedWorkCenters = [select Id from HDM_Assigned_Work_Center__c];
List<WorkType> workTypes = [select Id from WorkType];
List<HDM_Return_Method__c> returnMethods = [select Id from HDM_Return_Method__c];
List<HDM_Time_Sheet_Validation__c> timeSheetValidations = [select Id from HDM_Time_Sheet_Validation__c];

System.debug('accounts number = ' + accounts.size());
System.debug('contacts number = ' + contacts.size());
System.debug('cases number = ' + cases.size());
System.debug('expenseTypes number = ' + expenseTypes.size());
System.debug('operatingHours number = ' + operatingHours.size());
System.debug('serviceTerritories number = ' + serviceTerritories.size());
System.debug('timeCodes number = ' + timeCodes.size());
System.debug('serviceSalesOrgs number = ' + serviceSalesOrgs.size());
System.debug('technicianQuestionnaires number = ' + technicianQuestionnaires.size());
System.debug('technicianQuestionnaireQuestions number = ' + technicianQuestionnaireQuestions.size());

System.debug('workCenters number = ' + workCenters.size());
System.debug('assignedWorkCenters number = ' + assignedWorkCenters.size());
System.debug('assignedWorkCenters number = ' + assignedWorkCenters.size());
System.debug('workTypes number = ' + workTypes.size());
System.debug('timeSheetValidations number = ' + timeSheetValidations.size());
