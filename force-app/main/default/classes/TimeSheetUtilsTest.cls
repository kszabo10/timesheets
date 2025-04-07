/*
 * @description Tests for the TimeSheetUtils Apex class
 * @version     1.1
 * @date        January 13th, 2025
 */

@IsTest
public with sharing class TimeSheetUtilsTest {

    @TestSetup
    static void setup(){
        // startTest and stopTest are needed to separate governor limits from the real test method executions
        test.startTest();
        TestDataFactory.createSalesOrganizations();
/*        TestDataFactory.createServiceTerritories();

        TestDataFactory.createAccounts();
        TestDataFactory.createContacts();*/
        TestDataFactory.createUsers();

        test.stopTest();
    }


    @isTest
    public static void isSundayTest(){
        Date sundayDate = Date.newInstance(2025, 1, 12);
        Boolean isSunday = TimeSheetUtils.isSunday(sundayDate);
        Assert.isTrue(isSunday, 'isSundayTest error: sundayDate should be a Sunday');
        Date notSundayDate = Date.newInstance(2025, 01, 13);
        Boolean isNotSunday = TimeSheetUtils.isSunday(notSundayDate);
        Assert.isFalse(isNotSunday, 'isSundayTest error: notSundayDate should not be a Sunday');
    }

    @isTest
	public static void isWorkdayTest() {
        Date workdayDate = Date.newInstance(2025, 1, 13);
        Boolean isWorkday = TimeSheetUtils.isWorkday(workdayDate);
        Assert.isTrue(isWorkday, 'isWorkdayTest error: workdayDate should be a Workday');
        Date notWorkdayDate = Date.newInstance(2025, 01, 12);
        Boolean isNotWorkday = TimeSheetUtils.isWorkday(notWorkdayDate);
        Assert.isFalse(isNotWorkday, 'isWorkdayTest error: notWorkdayDate should not be a Workday');
	}

	@isTest
    public static void getLatestSundayTest(){
        Date notSundayDate = Date.newInstance(2025, 01, 14);
        Date referenceSunday = Date.newInstance(2025, 01, 12);
        Date latestSunday = TimeSheetUtils.getLatestSunday(notSundayDate);
        Assert.isTrue(referenceSunday == latestSunday, 'getLatestSundayTest error: wrongly calculated latestSunday');
	}


    @isTest
	public static void getAllTimeSheetsEndDateTest(){
        Integer weeksAhead = 4;
        Date aheadDate = TimeSheetUtils.getAllTimeSheetsEndDate(weeksAhead);
        Assert.isTrue(aheadDate >= Date.today().addDays(weeksAhead * 7), 'getAllTimeSheetsEndDateTest error: aheadDate is not farther from weeksAhed date = ' + aheadDate);
    }

    @isTest
	public static void findLatestEndDateTest(){
        TestDataFactory.createServiceResources();
        TestDataFactory.createTimeSheets();

        List<ServiceResource> serviceResources = new List<ServiceResource>([
            select Id
            from ServiceResource
        ]);
        System.debug('serviceResource size = ' + serviceResources.size());
        Date lastTimeSheetDate = TimeSheetUtils.findLatestEndDate(serviceResources.get(0));
        Assert.isTrue(lastTimeSheetDate <= Date.today(), 'findLatestEndDateTest error: lasTimeSheetDate should be not later than today');
	}

    
    @isTest
	public static void createTimeSheetsTest(){		
        TestDataFactory.createServiceResources();
        TestDataFactory.createTimeSheets();

        Integer weeksAhead = 4;
        Boolean isMonthEndSplit = true;

        List<ServiceResource> serviceResources = new List<ServiceResource>([
            select Id, Name, RelatedRecordId, RelatedRecord.SalesOrganization__c
            from ServiceResource
        ]);
        TimeSheetUtils.createTimeSheets(serviceResources.get(0), isMonthEndSplit, weeksAhead);
        List<TimeSheet> timeSheets = new List<TimeSheet>([
            select Id, ServiceResourceId, ServiceResource.RelatedRecordId, ServiceResource.RelatedRecord.SalesOrganization__c
            from TimeSheet
        ]);
        Assert.isTrue(timeSheets.size() > 0, 'createTimeSheetsTest error: not TimeSheets were created');
	}

    @isTest
	public static void createSRTimeSheetsTest(){		
        TestDataFactory.createServiceResources();
        TestDataFactory.createTimeSheets();

        Integer weeksAhead = 4;
        Boolean isMonthEndSplit = true;

        ServiceResource serviceResource = [
            SELECT Id, Name, RelatedRecordId, RelatedRecord.SalesOrganization__c
            FROM ServiceResource
            LIMIT 1
        ];
        List<Id> srIds = new List<Id>();
        srIds.add(serviceResource.Id);
        TimeSheetUtils.createSRTimeSheets(srIds);
        List<TimeSheet> timeSheets = new List<TimeSheet>([
            SELECT Id, ServiceResourceId, ServiceResource.RelatedRecordId, ServiceResource.RelatedRecord.SalesOrganization__c
            FROM TimeSheet
        ]);
        Assert.isTrue(timeSheets.size() > 0, 'createSRTimeSheetsTest error: not TimeSheets were created for the single Service Resource record');
	}



}