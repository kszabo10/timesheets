# Salesforce Field Service Timesheet Management

The package contains the following functions:
- Create Timesheet records for a Service Resource via the desktop User Interface
- Create Timesheet records for all active Service Users in a batch process
- Timesheets are based on calendar weeks, starting with Monday. If the related SalesOrgnaization__c record contains, Timesheets are split at month-end. 
- Use various Apex methods deinfed and teste din the TimeSheetUtils Apex class
- Rely on Apex test records and demo data defined in Static Resources

## Setup

The package can be deployed by the standard sf CLI commands to a scratch org. The scratch definition file can be found at /config/project-scratch-def.json.

After cloning the repository, define the scratch org named as "lookup_rollup" as described here:

- sf org create scratch --target-dev-hub MyHub --alias timesheet --definition-file config/project-scratch-def.json --set-default --duration-days 3

Once the scratch org is created, enable the Field Service application in Setup -> Field Service Settings.
Add the Timehseet management Permission Set

The following command will push the metadata to the newly created scratch org:

- sf project deploy start --target-org timesheet (where "path/to/source" denotes the source metadata).
Usage

Add the Timesheet management Permission Set to your Syste, Admoinistrator Account. 


# Create Demo Data

Run the following Apex command as anonymous Apex: 
- DemoDataCreation.createAll();


This will create 
- two SalesOrganization__c records for DE and IT, woth different TimeSheetManagement picklist values
- two users, fs1 DE and fs2 IT

Manually create two Service Resources, one for each user. 

Once the Service users are active, click their Create Timesheet button as Quick Action. 

Alternatively, as another anonymous Apex, run the following script:
```
        TimesheetGeneration__mdt batchConfig = TimesheetGeneration__mdt.getInstance(
            'Timesheet_info'
        );
        Database.executeBatch(
            new TimeSheetCreationBatch((Integer) batchConfig.WeeksAhead__c)
        );
```

The batch will create Timesheet records for all active Service Resources. 