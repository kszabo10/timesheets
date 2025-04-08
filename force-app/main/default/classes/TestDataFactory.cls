@isTest
public class TestDataFactory {

    // Variables created for test methods
    static String profileName = 'HDM Service Technician User';
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
        Profile stdUserProfile = [
            select Id, Name from Profile
            where Name = 'Standard User'
            limit 1
        ];
        System.debug('stdUserProfile = ' + stdUserProfile);
        users = New List<User>();
        DateTime timeNow = dateTime.now();
        Long msecTime = timeNow.getTime();
        String strMsecTime = String.valueOf(msecTime);
        User user1 = new User( 
            ProfileId = stdUserProfile.Id,
            Alias = 'fs1de',
            Email = 'fs1.de@fs1.de.demoorg.com.technician',
            EmailEncodingKey = 'UTF-8',
            LastName =  'De',
            FirstName = 'Fs1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'fs1.de' + strMsecTime + '@fs1.de.demoorg.com',
            IsActive = true,
            SalesOrganization__c = 'DE'
        );
        users.add(user1);

        // Increase strMsecTime to avoid user duplicates
        strMsecTime = String.valueOf(msecTime + 1);
        User user2 = new User( 
            ProfileId = stdUserProfile.Id,
            Alias = 'fs2it',
            Email = 'fs2.it@fs2.it.demoorg.com.technician',
            EmailEncodingKey = 'UTF-8',
            LastName =  'It',
            FirstName = 'Fs2',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'fs2.it' + strMsecTime + '@fs2.it.demoorg.com',
            IsActive = true,
            SalesOrganization__c = 'DE'
        );
        users.add(user2);
        insert users;

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