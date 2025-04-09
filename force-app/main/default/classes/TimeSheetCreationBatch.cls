/*
 * Create Time Sheet records for the active Service Resources as a batch process
 * @version	1.1
 * @date        October 21st, 2024
 * @date		January 8th, 2025
 * @description	Ensure that month-end split weeks are split even if the month-end day is Saturday or Sunday
 */

public without sharing class TimeSheetCreationBatch implements Database.Batchable<sObject>, Database.Stateful {
	public Integer countRecords = 0; // Service Resource records count
	Integer weeksAhead = 12; // Defines how many full weeks ahead need Time Sheets to be generated
	Date allTimeSheetsEndDate; // The highest End Date till the batch Time Sheet records should generate

	public TimeSheetCreationBatch(Integer iWeeksAhead) {
		weeksAhead = iWeeksAhead;
	}

	public Database.QueryLocator start(Database.BatchableContext bc) {
		// check what is the next endDate ahead

		allTimeSheetsEndDate = TimeSheetUtils.getAllTimeSheetsEndDate(weeksAhead);
		// Also query the Service Resource User's SAP Sales Organization
		String queryString = 'select Id, Name, RelatedRecordId, RelatedRecord.SalesOrganization__c, ';
		queryString += '(select Id, StartDate, EndDate, OwnerId from TimeSheets Order by EndDate desc limit 6) ';
		queryString += 'from ServiceResource where isActive = true'; 
		return Database.getQueryLocator(queryString);
	}

	public void execute( Database.BatchableContext bc, List<ServiceResource> scope) {
		List<TimeSheet> toSaveTimeSheets = new List<TimeSheet>();
		// Get the Service Sales Organizations which belong to the SR users
		Set<String> salesOrgNames = new Set<String>();
		for (ServiceResource sr : scope) {
			salesOrgNames.add(sr.RelatedRecord.SalesOrganization__c);
		}
		List<SalesOrganization__c> salesOrgs = new List<SalesOrganization__c>(
		[
			SELECT Id, Name, TimeSheetGeneration__c, SalesOrganizationName__c
			FROM SalesOrganization__c
			WHERE SalesOrganizationName__c IN :salesOrgNames
		]);
		Map<String, String> soNametoTSGeneration = new Map<String, String>();
		for (SalesOrganization__c so : salesOrgs) {
			soNametoTSGeneration.put(
				so.SalesOrganizationName__c,
				so.TimeSheetGeneration__c
			);
		}

		for (ServiceResource sr : scope) {
			countRecords++;
			// Define the isMonthEndSplit value: weekly or weekly with month-end split
			Boolean isMonthEndSplit = true;

			if(sr.RelatedRecord.SalesOrganization__c == null){
				// The user's SalesOrganization is not filled in -> No Time Sheet to generate for the Service Resource
				continue;
			}

			if( sr.RelatedRecord.SalesOrganization__c != null &&
				soNametoTSGeneration.get( sr.RelatedRecord.SalesOrganization__c) == 'Weekly'){
				
					isMonthEndSplit = false;
			}
			if(soNametoTSGeneration.get( sr.RelatedRecord.SalesOrganization__c) == 'No'){
				// No TimeSheet generation for this Service Resource for this Service Sales Org
				continue;
			}
			// Create all Time sheets required for the particulare Service Resource
			List<TimeSheet> srToSaveTimeSheets = TimeSheetUtils.createTimeSheets(sr, isMonthEndSplit, weeksAhead);
			toSaveTimeSheets.addAll(srToSaveTimeSheets);
		}
		insert toSaveTimeSheets;
	}

	public void finish(Database.BatchableContext bc) {
		System.debug(
			'Batch ends. Total number of activeResources = ' + countRecords
		);
	}

}