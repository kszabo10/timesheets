@isTest
public class TestDataFactory {

    // Variables created for test methods
    public static List<SalesOrganization__c> serviceSalesOrgs = null;
    public static List<TimeSheet> timeSheets = null;    
    public static List<User> users = null;
    public static List<ServiceResource> serviceResources = null;

    // create Sales Organizations
    @IsTest
    public static void createSalesOrganizations(){
        DemoDataCreation.createRecords('SalesOrganization__c', true, true);
    }

    // Create Service Resource records
    @IsTest
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
        users = DemoDataCreation.createUsers();        
        System.debug('users size = ' + users.size());
    }

    @IsTest
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