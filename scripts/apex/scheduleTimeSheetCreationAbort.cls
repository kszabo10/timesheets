// Replace with your AsyncApexJob ID
String asyncJobId = '7079Q00000c5nuC';

// Get the ApexClassId from AsyncApexJob
AsyncApexJob job = [SELECT ApexClassId FROM AsyncApexJob WHERE Id = :asyncJobId LIMIT 1];

if (job != null) {
    // Find the CronTrigger record associated with the Apex class
    CronTrigger cronTrigger = [
        SELECT Id FROM CronTrigger 
        WHERE CronJobDetail.ApexClassId = :job.ApexClassId
        LIMIT 1
    ];

    if (cronTrigger != null) {
        System.abortJob(cronTrigger.Id);
        System.debug('Scheduled job with CronTrigger ID ' + cronTrigger.Id + ' has been aborted.');
    } else {
        System.debug('No CronTrigger found for the provided AsyncApexJob ID.');
    }
} else {
    System.debug('No AsyncApexJob found with the provided ID.');
}
