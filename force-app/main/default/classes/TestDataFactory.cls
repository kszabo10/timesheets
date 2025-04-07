@isTest
public class TestDataFactory {

    // Variables created for test methods

    public static List<Account> accounts = null;
    public static List<Product2> products = null;
    public static List<Case> cases = null;
    static String profileName = 'HDM Service Technician User';
    public static List<SalesOrganization__c> serviceSalesOrgs = null;
    public static List<User> users = null;
    public static List<ServiceResource> serviceResources = null;
    public static List<TimeSheet> timeSheets = null;
    public static List<WorkOrder> workOrders = null;


    // create Service Territories, no hierarchy used
/*    public static void createServiceTerritories(){
        DemoDataCreation.createRecords('ServiceTerritory', true, true);
    }*/


    // create Operating Hours
/*    public static void createOperatingHours(){
        DemoDataCreation.createRecords('OperatingHours', true, true);
    }*/

    // create Service Sales Organizations
    public static void createSalesOrganizations(){
        DemoDataCreation.createRecords('SalesOrganization__c', true, true);
    }


    // Create Service Resource records
    public static List<ServiceResource> createServiceResources(){
        serviceResources = new List<ServiceResource>();
        List<User> testUsers = new List<User>([
            select Id, Name, IsActive
            from User
            where firstName like 'Fs%'
        ]);
        if(testUsers.size() == 0){
            System.debug('No users retrieved, process ends');
            return null;
        }
        for (Integer i = 0; i < testUsers.size(); i++) {
            ServiceResource sr = new ServiceResource(
                Name = 'Test Service Resource ' + i,
                RelatedRecordId = testUsers.get(i).Id,
                ResourceType = 'T',
                IsActive = true
            );
            serviceResources.add(sr);
        }
        for(ServiceResource sr : serviceResources){
            System.debug('Next serviceResource before Insert = ' + sr);
        }

        insert serviceResources;

        return serviceResources;
    }


    // Create users
    @future
    public static void createUsers(){
        users = (List<User>) DemoDataCreation.createRecords('User', true, true);
        System.debug('users size = ' + users.size());
/*        List<PermissionSetAssignment> toSavePermissionSetAssignments = new List<PermissionSetAssignment>();
        // Set PermissionSetLicenseAssign relationship records: PermissionSet + User
        // Assign Field Service Scheduling Permission Set License
        Id permissionSetLicenseId = [
            select Id 
            from PermissionSetLicense 
            where DeveloperName like '%FieldServiceSchedulingPsl%'
            limit 1
        ].Id;
        List<PermissionSetLicenseAssign> assignments = new List<PermissionSetLicenseAssign>();

        for(User usr : users){
            PermissionSetLicenseAssign newAssign = new PermissionSetLicenseAssign(
                PermissionSetLicenseId = permissionSetLicenseId,
                AssigneeId = usr.Id
            );
            assignments.add(newAssign);
        }
        insert assignments;*/

        // Assign Field Mobile Scheduling Permission Set License
/*        Id permissionSetLicenseId_FSM = [
            select Id 
            from PermissionSetLicense 
            where MasterLabel = 'Field Service Mobile'
            limit 1
        ].Id;

        List<PermissionSetLicenseAssign> assignments_FSM = new List<PermissionSetLicenseAssign>();
        for(User usr : users){
            PermissionSetLicenseAssign newAssign = new PermissionSetLicenseAssign(
                PermissionSetLicenseId = permissionSetLicenseId_FSM,
                AssigneeId = usr.Id
            );
            assignments_FSM.add(newAssign);
        }
        insert assignments_FSM;*/

        // Assign PermissionSets to users which are part of the HDM FS Techicial Group Permission Set
        // This is to be used instead of assigning the Permission Set Group.
        // Field Service Mobile Licence Permission Set
/*        Id fieldServiceMobileLicensePS = [
            select Id, Label 
            from permissionSet
            where Label = 'Field Service Mobile License'
            limit 1
        ].Id;
        for(User usr : users){
            PermissionSetAssignment newps = new PermissionSetAssignment(
                PermissionSetId = fieldServiceMobileLicensePS,
                AssigneeId = usr.Id
            );
            toSavePermissionSetAssignments.add(newps);
        }*/


        // Field Service Resource Licence Permission Set
/*        Id fieldServiceResourceLicensePS = [
            select Id, Label 
            from permissionSet
            where Label = 'Field Service Resource License'
            limit 1
        ].Id;
        for(User usr : users){
            PermissionSetAssignment newps = new PermissionSetAssignment(
                PermissionSetId = fieldServiceResourceLicensePS,
                AssigneeId = usr.Id
            );
            toSavePermissionSetAssignments.add(newps);
        }

        // Field Service Resource Permissions Permission Set
        Id fieldServiceResourcePermissionsPS = [
            select Id, Label 
            from permissionSet
            where Label = 'Field Service Resource Permissions'
            limit 1
        ].Id;
        for(User usr : users){
            PermissionSetAssignment newps = new PermissionSetAssignment(
                PermissionSetId = fieldServiceResourcePermissionsPS,
                AssigneeId = usr.Id
            );
            toSavePermissionSetAssignments.add(newps);
        }*/

        // HDM FS Technician Permission Set
/*        Id hdmFSTechnicianPS = [
            select Id, Label 
            from permissionSet
            where Label = 'HDM FS Technician'
            limit 1
        ].Id;
        for(User usr : users){
            PermissionSetAssignment newps = new PermissionSetAssignment(
                PermissionSetId = hdmFSTechnicianPS,
                AssigneeId = usr.Id
            );
            toSavePermissionSetAssignments.add(newps);
        }

        // TimeLine user Permission Set         
        Id TimelineUserPS = [
            select Id, Label 
            from permissionSet
            where Label = 'Timeline User'
            limit 1
        ].Id;
        for(User usr : users){
            PermissionSetAssignment newps = new PermissionSetAssignment(
                PermissionSetId = TimelineUserPS,
                AssigneeId = usr.Id
            );
            toSavePermissionSetAssignments.add(newps);
        }
        insert toSavePermissionSetAssignments;*/

        // Assign the HDM FS Technician Group Permission Set Group to all users
/*        Id permissionSetGroupId = [
            select Id 
            from PermissionSetGroup
            where MasterLabel = 'HDM FS Technician Group'
            limit 1
        ].Id;

        List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>();
        for(User usr : users){
            PermissionSetAssignment newpsa = new PermissionSetAssignment(
                PermissionSetGroupId = permissionSetGroupId,
                AssigneeId = usr.Id
            );
            psas.add(newpsa);
        }
        insert psas;*/
    }

/*    public static void createAccounts(){
        accounts = (List<Account>) DemoDataCreation.createRecords('Account', true, true);
    }*/


    public static void createContacts(){
        DemoDataCreation.createRecords('Contact', true, true);
    }

/*    public static void createCases(){
        cases = (List<Case>) DemoDataCreation.createRecords('Case', true, true);
    }

    public static void createWorkOrders(){
        workOrders = (List<WorkOrder>) DemoDataCreation.createRecords('WorkOrder', true, true);
        Integer sapOrderNumber = 10000;
        // Update with an HDM_SAP_Order_Number__c needed here,
        // .. otherwise the WO.SAP_service_order_created Validation Rule failed
        for(WorkOrder wo : workOrders){
            //wo.HDM_SAP_Order_Number__c = String.valueOf(sapOrderNumber++);
        }
        update workOrders;
        System.debug('createWorkOrders. Printing records');
        for(WorkOrder wo : workOrders){
            System.debug('wo.Id = ' + wo.Id + ', wo.Subject = ' + wo.Subject + ', wo.CaseId = ' + wo.CaseId + ', wo.RecordTypeId = ' + wo.RecordTypeId + ', wo.Case.HDM_SAPNotificationNumber__c = ' +  wo.Case.HDM_SAPNotificationNumber__c);
        }
    }

    public static void createWorkOrderLineItems(){
        System.debug('TestDataFactroyBulk.createWorkOrderLineItem STARTS');
        DemoDataCreation.createRecords('WorkOrderLineItem', true, true);
        System.debug('TestDataFactroyBulk.createWorkOrderLineItem ENDS');
    }*/

    public static void createTimeSheets(){
        if(serviceResources == null){
            return;
        }

        // Create TimeSheet records for the given week when the test is run
        timeSheets = new List<TimeSheet>();
        Date startDate = TimeSheetUtils.getLatestSunday(Date.today().addDays(-1)).addDays(1);
        Date endDate = startDate.addDays(6);
        for(ServiceResource sr : serviceResources){
            TimeSheet newSheet = new timeSheet(
                StartDate = startDate,
                EndDate = endDate,
                ServiceResourceId = sr.Id,
                OwnerId = sr.RelatedRecordId
            );
            timeSheets.add(newSheet);
        }
        insert timeSheets;
    }


}