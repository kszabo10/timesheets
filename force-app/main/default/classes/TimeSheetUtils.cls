/*
 * @description Time Sheet Utility methods
 * @version     1.1
 * @date        January 9th, 2025
 */

 public class TimeSheetUtils {

	/*
	* @description    	return true if the input Date is Sunday
	* @param		    Date endDate: input Date to check
	* @return     		Boolean: true if the endDate is Sunday
	*/
	public static Boolean isSunday(Date inputDate) {
		Set<String> holidays = new Set<String>{ 'Sunday' };
		Datetime inputDateTime = Datetime.newInstanceGmt( inputDate,Time.newInstance(0, 0, 0, 0));
		String dayOfWeek = inputDateTime.formatGmt('EEEE');
		if (holidays.contains(dayOfWeek)) {
			return true;
		}
		return false;
	}

	/*
	* @description    	return true if the input Date is Sunday
	* @param		    DateTime inputDateTime: input Date to check
	* @return     		Boolean: true if the endDate is Sunday
	*/
	public static Boolean isSunday(Datetime inputDateTime, String timeZone) {
		Set<String> holidays = new Set<String>{ 'Sunday' };
		String formattedDate = inputDateTime.format('EEEE', timeZone);
		return formattedDate == 'Sunday';
	}


	/*
	* @description    	return true if a Date is workday, ie. neither Saturday or Sunday
	* @param		    Date endDate: input Date to check
	* @return     		Boolean: true of the endDate is a workday
	*/
	public static Boolean isWorkday(Date endDate) {
		Set<String> holidays = new Set<String>{ 'Saturday', 'Sunday' };
		Datetime endDateTime = Datetime.newInstanceGmt( endDate,Time.newInstance(0, 0, 0, 0));
		String dayOfWeek = endDateTime.formatGmt('EEEE');
		if (holidays.contains(dayOfWeek)) {
			return false;
		}
		return true;
	}

	/*
	* @description    	return the latest Date which was Sunday
	* @param		    Date endDate: input Date to check
	* @return     		Date: The latest prvious Date which was Sunday
	*/
	public static Date getLatestSunday(Date endDate) {
		Set<String> holidays = new Set<String>{ 'Sunday' };
        Date latestSunday = endDate;
        while(isSunday(latestSunday) != true){
            latestSunday = latestSunday.addDays(-1);
        }
		return latestSunday;
	}

	public static Date getNextSunday(Date endDate) {
		Set<String> holidays = new Set<String>{ 'Sunday' };
        Date nextSunday = endDate;
        while(isSunday(nextSunday) != true){
            nextSunday = nextSunday.addDays(1);
        }
		return nextSunday;
	}

	/*
	* @description 	calculate the End Date till all Time Sheet records need to be generated from today.
	* @param 		Integer weeksAhead: defines how many weeks ahead need to be calculated
	* @return     	Date: the EndDate until Time Sheet records are to be generated in the batch process
	*/
	public static Date getAllTimeSheetsEndDate(Integer weeksAhead) {
		Date weeksAheadDate = Date.today().addDays(weeksAhead * 7);
		Date returnDate = null;
		for (Integer i = 0; i < 7; i++) {
			Date loopDate = weeksAheadDate.addDays(i);
			if (returnDate == null && isSunday(loopDate)) {
				returnDate = loopDate;
			}
		}
		return returnDate;
	}

	/*
	* @description    	find the last EndDate of TimeSheets belonging to the input Service Resource
	*                   if there is none, return the latest previous Sunday
	* @param		    ServiceResource sr: the active ServiceResource
	* @return     		Date: the last Date from what new TimeSheets will have to be created
	*/
	public static Date findLatestEndDate(ServiceResource sr) {
		if(sr.TimeSheets.size() == 0) {
			// no previous TimeSheets were generated
			Date toFindLastSunday = Date.today();
			while (isSunday(toFindLastSunday) == false) {
				toFindLastSunday = toFindLastSunday.addDays(-1);
			}
			if (toFindLastSunday == Date.today()) {
				// if no TS yet and today is Sunday, we need Sunday the week before
				return toFindLastSunday.addDays(-7);
			} else {
				return toFindLastSunday;
			}
		}
		return sr.TimeSheets.get(0).EndDate;
	}

	public static Date getEndDate(ServiceResource sr, Boolean isMonthEndSplit){
		if(sr.TimeSheets.size() == 0) {
			Date returnDate = findPreviousEndDate(Date.today(), isMonthEndSplit);
			return returnDate;
		}else{
			return sr.TimeSheets.get(0).EndDate;
		}
	}



	public static Date getStartDate(ServiceResource sr){
		if(sr.TimeSheets.size() == 0) {
			return Date.today();
		}else{
			return sr.TimeSheets.get(0).StartDate;
		}
	}

	
	public static Date findPreviousEndDate(Date startDate, Boolean isMonthEndSplit){
		Date previousEndDate;
		previousEndDate = getLatestSunday(startDate);
		if(previousEndDate.month() == startDate.month()){
			return previousEndDate;
		}
		if(isMonthEndSplit == false){
			return previousEndDate;
		}else{
			previousEndDate = startDate;
			while(previousEndDate.month() == startDate.month()){
				previousEndDate = previousEndDate.addDays(-1);
			}
			return previousEndDate;
		}
	}


	public static Date findNewEndDate(Date startDate, Boolean isMonthEndSplit){
		Date newEndDate;
		newEndDate = getNextSunday(startDate);
		if(newEndDate.month() == startDate.month()){
			return newEndDate;
		}
		if(isMonthEndSplit == false){
			return newEndDate;
		}else{
			newEndDate = startDate;
			while(newEndDate.month() == startDate.month()){
				newEndDate = newEndDate.addDays(1);
			}
			return newEndDate.addDays(-1);
		}
	}

	/**
	 * @description    	Create TimeSheet records related to the Service Resource (sr)
	 * @param			ServiceResource sr: the active ServiceResource to what TimeSheets will be created
	 * 					sr: it also has to contain the lookup User's fields like SalesOrganization__c and
	 * 					... related TimeSheet records, if any
	 * @return     		List<TimeSheet>: the created, not-yet saved TimeSheets
	 */
	public static List<TimeSheet> createTimeSheets( ServiceResource sr, Boolean isMonthEndSplit, Integer weeksAhead) {
		List<TimeSheet> retTimeSheets = new List<TimeSheet>();
		String timeSheetGeneration = sr.RelatedRecord.SalesOrganization__c;
		Date allTimeSheetsEndDate = TimeSheetUtils.getAllTimeSheetsEndDate(weeksAhead);
		Date latestEndDate = TimeSheetUtils.findLatestEndDate(sr);
		Date startDate = getStartDate(sr);			// default monthsStartDate
		Date endDate = getEndDate(sr, isMonthEndSplit);				// default monthEndDate

		// loop over until the new Time sheet EndDate reaches the allTimeSheetsEndDate value
		if (latestEndDate >= allTimeSheetsEndDate) {
			// All time sheets have been generated for this Service Resource within the time period
			return retTimeSheets;
		}
		while (endDate <= allTimeSheetsEndDate) {
			Date newStartDate = endDate.addDays(1);
			Date newEndDate = findNewEndDate(newStartDate, isMonthEndSplit);

			startDate = newStartDate;
			endDate = newEndDate;

			TimeSheet ts = new TimeSheet(
				StartDate = startDate,
				EndDate = endDate,
				ServiceResourceId = sr.Id,
				Status = 'New',
				OwnerId = sr.RelatedRecordId
			);
			retTimeSheets.add(ts);
		}
		return retTimeSheets;
	}

    @InvocableMethod(label='Create Service Resource related Time Sheets')
	public static List<Integer> createSRTimeSheets(List<Id> srIds){
		Id srId = srIds.get(0);
		ServiceResource sr = [
			SELECT Id, Name, RelatedRecordId,
				RelatedRecord.SalesOrganization__c, 
				(SELECT Id, StartDate, EndDate, OwnerId 
					FROM TimeSheets 
					ORDER BY EndDate 
					DESC LIMIT 6
				)
			FROM ServiceResource
			WHERE Id = :srId
			LIMIT 1
		];
		// Get the related month-end split checkbox
		// Get the Service Sales Organizations which belong to the SR users
		String serviceSalesOrgName = sr.RelatedRecord.SalesOrganization__c;
		SalesOrganization__c serviceSalesOrg = [
			SELECT Id, Name, TimeSheetGeneration__c, SalesOrganizationName__c
			FROM SalesOrganization__c
			WHERE SalesOrganizationName__c = :serviceSalesOrgName
			LIMIT 1
		];
		Boolean isMonthEndSplit = false;
		if(serviceSalesOrg.TimeSheetGeneration__c == 'Weekly with Month-End Closing'){
			isMonthEndSplit = true;
		}

		// Get the Custom Metadata for the weeks ahead number
		TimesheetGeneration__mdt batchConfig = TimesheetGeneration__mdt.getInstance(
            'Timesheet_info'
        );

		List<TimeSheet> timeSheets = createTimeSheets(sr, isMonthEndSplit, (Integer) batchConfig.WeeksAhead__c); 
		insert timeSheets;
		Integer retVal = timeSheets.size();
		return new List<Integer>{retVal};

	}

}