/**
 * ===================================================================
 * @author    	Zoltán K.Szabó
 * @email		zoltan.szabo@fluidogroup.com
 * @version     1.3
 * @date        Test class for DemoDataCreation
 * @description JSON-based record mgmt for Demo and Apex Test data purposes
 * * ===================================================================
**/
@isTest
public class DemoDataCreationTest {

    @TestSetup
    static void setup(){
        
    }

    @isTest
    public static void createAllDeleteAllTest(){
        Test.startTest();
        DemoDataCreation.createAll();
        List<SalesOrganization__c> ssos = [
            select Id, Name 
            from SalesOrganization__c
        ];
        Test.stopTest();
        System.assert(ssos.size() > 0);
    }
    
    @isTest
        public static void deleteAll(){
            Test.startTest();
            DemoDataCreation.createAll();
            List<SalesOrganization__c> ssos = [
                select Id, Name 
                from SalesOrganization__c
            ];
            //Delete all
            DemoDataCreation.deleteAll('DELETE-ALL-RECORDS-FROM-ORG');
    		ssos = [
                select Id, Name 
                from SalesOrganization__c
            ];
            Test.stopTest();
            System.assert(ssos.size() == 0);
        }
    
    @isTest
    public static void createSalesOrganizationsRecords(){
        Test.startTest();
        DemoDataCreation.createRecords('SalesOrganization__c', true,true);
        List<SalesOrganization__c> ssos = [
            select Id, Name 
            from SalesOrganization__c
        ];
        Test.stopTest();
        System.assert(ssos.size() > 0);
    }

/*    @isTest
    public static void deleteServiceSalesOrganizationsRecords(){
        Test.startTest();
        DemoDataCreation.deleteAllRecords('SalesOrganization');
        List<SalesOrganization__c> ssos = [
            select Id, Name 
            from SalesOrganization__c
        ];
        Test.stopTest();
        System.assert(ssos.size() == 0);
    }*/
/*    @isTest
	public static void createSingleRecordDeleteRecords(){
        Test.startTest();
        DemoDataCreation.createRecords('SalesOrganization', true,false);
        List<SalesOrganization__c> ssos = [
            select Id, Name 
            from SalesOrganization__c
        ];
        Test.stopTest();
        System.assert(ssos.size() > 0);
    }
    @isTest
    public static void createSingleAccountRecord(){
        Test.startTest();
        DemoDataCreation.createRecords('Account', true,false);
        List<Account> ssos = [
            select Id, Name 
            from Account
        ];
        Test.stopTest();
        System.assert(ssos.size() > 0);
    }*/
}