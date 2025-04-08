/***
 * ============================================================================
 * @author    	
 * @email		
 * @version     
 * @date        
 * @description JSON-based record mgmt for Demo and Apex Test data purposes
 * ============================================================================
**/
public with sharing class DemoDataCreation {


	private static final String CONFIRM_DELETE = 'DELETE-ALL-RECORDS-FROM-ORG';
	private static final List<String> ALL_DELETE_OBJECTS = new List<String>{
		'SalesOrganization__c'
	};

	private static final List<String> ALL_CREATE_OBJECTS = new List<String>{
        'SalesOrganization__c'
	};

	/**
    * @description:		Inserts records for SObject names in 'ALL_OBJECTS' constant,
	* 					if there is a matching StaticResource
    */
	public static void createAll(){
		createRecordsBySobjectNames(ALL_CREATE_OBJECTS, true);
	}

	/**
    * @description			Deletes ALL records for SObjects in 'ALL_OBJECTS' constant
	* @param confirm		[String] User has to confirm the deletion in parameter
    */
	public static void deleteAll(String confirm){
		if(confirm == CONFIRM_DELETE){
			deleteRecordsBySobjectNames(ALL_DELETE_OBJECTS);
		} else {
			System.debug('WARNING: DemoDataCreation.deleteAll called without confirmation.');
		}
	}

	/**
    * @description			Creates records for given SObject names if there is a matching StaticResource
	* @param sObjectNames	List[String] SObject API names
	* @param doInsert		Boolean
	* @return				Map<String, List[SObject]>
    */
	public static Map<String, List<SObject>> createRecordsBySobjectNames(List<String> sObjectNames, Boolean doInsert){
		Map<String, List<SObject>> objRecordsMap = new Map<String, List<SObject>>();

		for(String currentObject : sObjectNames){
			objRecordsMap.put(currentObject, createRecords(currentObject, doInsert, true));
		}
		return objRecordsMap;
	}

	
	public static List<SObject> createRecords(String sObjectName, Boolean isToInsert, Boolean isBulkify) {   
		//List<SObject> records = isBulkify ? getTestDataFromJSONBulkify(sObjectName) : getTestDataFromJSONSingle(sObjectName);
		List<SObject> records = getTestDataFromJSONBulkify(sObjectName);

        if(records.isEmpty()){
			return records;
        }
        
		if(isToInsert){        
			Database.SaveResult[] srList = Database.insert(records, true);

			// Check for errors in the SaveResult array
			List<String> errorMessages = new List<String>();

			for(Database.SaveResult sr : srList){
				if(!sr.isSuccess()){
					// Iterate through errors if there are any
					for(Database.Error err : sr.getErrors()){
						errorMessages.add('Error Message: ' + err.getMessage());
						errorMessages.add('Fields affected: ' + err.getFields());
						errorMessages.add('Status Code: ' + err.getStatusCode());
					}
				}
			}
			if (!errorMessages.isEmpty()) {
				throw new DemoDataCreationException(String.join(errorMessages, '\n'));
			}
		}
		return records;
	}


	/** 
	* @description			Deletes ALL records for given SObject names
	* @param sObjectNames	List[String] SObject API names
    */
	public static void deleteRecordsBySobjectNames(List<String> sObjectNames){
		for(String currentObject : sObjectNames){
			List<SObject> recordsToDelete = Database.query('SELECT Id FROM ' + currentObject);

			Database.DeleteResult[] drList = Database.delete(recordsToDelete, false);

			Integer deleted = 0;
			for(Database.DeleteResult dr : drList){
				if(!dr.isSuccess()){
					// Iterate through errors if there are any
					for(Database.Error err : dr.getErrors()){
						System.debug(err.getStatusCode() + ': ' + err.getMessage() + ': FIELD: ' + err.getFields());
					}
				} else {
					deleted++;
				}
			}
			// Ex.: Deleted Contact: 2/3
			System.debug('Deleted ' + currentObject + ': ' + deleted + '/' + drList.size());
		}
	}

	/**
    * @description              Converts a static JSON file into a list of sObject records
    * @param objectName         The sObject's API name, include '__c' if a custom object
    * @return List[Sobject]     List of sObject records created from the stored static resource
    */
    private static List<Sobject> getTestDataFromJSONBulkify(String objectName){
        List<sObject> sObjectList = new List<sObject>();
		String objectNameTrunc = objectName.contains('__c') ? objectName.substringBefore('__c') : objectName;
		String fileName = objectNameTrunc + 'TestData';
        
        // Get the static resource which should be named as (objectName + TestData), without __c
		List<StaticResource> sr = [
			SELECT Body 
			FROM StaticResource 
			WHERE Name = :fileName
			LIMIT 1
        ];

        if(sr.isEmpty()){
            throw new DemoDataCreationException('No Static Resource found for Object name: ' + objectName);
        }

        String  jsonText = sr[0].body.toString();
        Map<String, Object> deserialized = (Map<String, Object>)JSON.deserializeUntyped(jsonText);
        List<String> finalJsonString = new List<String>();

        // Store all RecordTypes for this Object in a Map (Name-Id)
        Map<String, Id> rtNameIdMap = new Map<String, Id>();
        Map<String, Schema.RecordTypeInfo> rtSchemaMap = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName();
        for(String rtName : rtSchemaMap.keySet()){
            rtNameIdMap.put(rtName, rtSchemaMap.get(rtName).recordtypeid);
        }
        
        // Iterate through records in the JSON and add them to a List finalJsonString
        for(Object instance : (List<Object>)deserialized.get('records')){

            // Check if the current Record has a RecordType in the JSON
            Map<String, Object> fieldValuesMap = (Map<String, Object>) instance;
            if(fieldValuesMap.containsKey('RecordType')){

                // Make sure there are RecordTypes in the Org for this Object
                if(!rtNameIdMap.values().isEmpty()){
                    replaceRTObjectWithId(fieldValuesMap, rtNameIdMap, objectName);
                } else {
                    System.debug('WARNING: ' + objectName + ' Static Resource specifies a RecordType but NO RecordType found for this object in the org.');
                }
            }
            
            finalJsonString.add(JSON.serialize((Object)fieldValuesMap));
        }

        try {
            // Deserialize and add Records to an SObject List
            for(String str : finalJsonString){
                SObject customObject = (SObject) JSON.deserialize(str, sObject.class);
                sObjectList.add(customObject);
            }
        } catch(Exception ex){
            System.debug('Error when adding ' + objectName + ' SObject record to list: ' + ex.getMessage());
        }
        return sObjectList;
    }

    /**
    * @description                  Replaces the RecordType object with "RecordTypeId" for the current
    *                               record.
    * @param fieldValuesMap         (Field-Value) Map of the current Record
    * @param rtNameIdMap            RecordType (Name-Id) Map of the current Object from the Org
    */
    private static void replaceRTObjectWithId(Map<String, Object> fieldValuesMap, Map<String, Id> rtNameIdMap, String objectName){
        
        //get the Record Type name of the current record
        String recordTypeName = (String) ((Map<String, Object>) fieldValuesMap.get('RecordType'))?.get('Name');
        
        if(recordTypeName != null && rtNameIdMap.containsKey(recordTypeName)){
            //Add RecordTypeId and remove RecordType object
            fieldValuesMap.put('RecordTypeId', rtNameIdMap.get(recordTypeName));
            fieldValuesMap.remove('RecordType');
        }else {
            throw new DemoDataCreationException('ERR: Cannot find the following RecordType on ' + objectName + ': ' + recordTypeName);
        }
    }


}