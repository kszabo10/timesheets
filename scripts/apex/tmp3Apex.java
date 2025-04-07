/**
 * @author Irina Skovorodko
 * @description Batch to check open and Won opportunities to set ShortTermPriority checkbox on opportunities and accounts
 * @jira SFSL-118
 */
public with sharing class HDM_OpportunityShortTermPriorityBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {

    public Map<Id, List<HDM_ShortTermPriorityAssignment__c>> criteriaSTPBySSUId = new Map<Id, List<HDM_ShortTermPriorityAssignment__c>>();


    public Database.QueryLocator start(Database.BatchableContext bc) {
        

        List<HDM_ShortTermPriorityAssignment__c> criteria = [SELECT Id, HDM_Technology__c, HDM_Stage__c, HDM_SSU__c, HDM_MinProjectViability__c, HDM_MinHeidelbergProbability__c, convertCurrency(HDM_MinSalesVolumeInTechnology__c), HDM_GracePeriod__c, HDM_DaysUntilCloseDate__c FROM HDM_ShortTermPriorityAssignment__c];
        for (HDM_ShortTermPriorityAssignment__c assignment : criteria) {
            if (!criteriaSTPBySSUId.containsKey(assignment.HDM_SSU__c)) {
                criteriaSTPBySSUId.put(assignment.HDM_SSU__c, new List<HDM_ShortTermPriorityAssignment__c>());
            }
            criteriaSTPBySSUId.get(assignment.HDM_SSU__c).add(assignment);
        }
        System.debug(criteriaSTPBySSUId);
        
        String query = ' SELECT Id, Name, StageName, HDM_ProjectViability__c, HDM_HeidelbergProbability__c, CloseDate, IsClosed, HDM_ShortTermPriority__c, ' +
                            ' Account.HDM_SSU__c, Account.HDM_SSU__r.Name, Account.HDM_LatestShortTermPriorityOppo__c, Account.HDM_EndOfGracePeriod__c, ' +
                            ' convertCurrency(HDM_BindingVolume__c), ' +
                            ' convertCurrency(HDM_BlankingVolume__c), ' +
                            ' convertCurrency(HDM_CtPVolume__c), ' +
                            ' convertCurrency(HDM_CuttingVolume__c), ' +
                            ' convertCurrency(HDM_DieCuttingVolume__c), ' +
                            ' convertCurrency(HDM_DigitalPrintVolume__c), ' +
                            ' convertCurrency(HDM_FlexoPrintVolume__c), ' +
                            ' convertCurrency(HDM_FoldergluingVolume__c), ' +
                            ' convertCurrency(HDM_FoldingVolume__c), ' +
                            ' convertCurrency(HDM_HotFoilingVolume__c), ' +
                            ' convertCurrency(HDM_InspectionVolume__c), ' +
                            ' convertCurrency(HDM_LifecycleVolume__c), ' +
                            ' convertCurrency(HDM_NewspaperVolume__c), ' +
                            ' convertCurrency(HDM_OffsetPrintSfVolume__c), ' +
                            ' convertCurrency(HDM_OffsetPrintWebVolume__c), ' +
                            ' convertCurrency(HDM_PostpressVolume__c), ' +
                            ' convertCurrency(HDM_PrepressVolume__c), ' +
                            ' convertCurrency(HDM_PressroomVolume__c), ' +
                            ' convertCurrency(HDM_StichingVolume__c), ' +
                            ' convertCurrency(HDM_WorkflowVolume__c) ' +
                       ' FROM Opportunity' +
                       ' WHERE (Account.HDM_SSU__c != null) '+
                       ' AND ((IsClosed = FALSE AND CloseDate > TODAY) OR (IsClosed = TRUE AND StageName = \'Closed Won\' AND CloseDate = LAST_N_DAYS:150) ' +
                       ' OR (IsClosed = TRUE AND (StageName = \'Closed Lost\' OR StageName = \'Closed Canceled\') AND HDM_ShortTermPriority__c = true)) ' +
                       ' ORDER BY AccountId, CloseDate';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Opportunity> opportunities) {
        Map<Id, Opportunity> oppsToUpdate = new Map<Id, Opportunity>();
        Map<Id, Account> accsToUpdate = new Map<Id, Account>();
        Map<Id, STPOpportunity> accIdToLatestSTPOpp = new Map<Id, STPOpportunity>();
        System.debug('....criteriaSTPBySSUId: '+criteriaSTPBySSUId);

        try {
            for (Opportunity opp : opportunities) {
                Boolean oppCriteriaRiched = false;
                if (criteriaSTPBySSUId.containsKey(opp.Account.HDM_SSU__c)) {
                    List<HDM_ShortTermPriorityAssignment__c> oppCriteriaList = criteriaSTPBySSUId.get(opp.Account.HDM_SSU__c);
                    for (HDM_ShortTermPriorityAssignment__c oppCriteria : oppCriteriaList) {
                        String technologyFieldName = HDM_OpportunityVolumeConstants.productTechnologyToOppVolume.get(oppCriteria.HDM_Technology__c);
                        
                        Boolean criteriaReached = HDM_OpportunityVolumeConstants.stageValues.get(opp.StageName) >= HDM_OpportunityVolumeConstants.stageValues.get(oppCriteria.HDM_Stage__c)
                                                && (opp.HDM_ProjectViability__c != null && oppCriteria.HDM_MinProjectViability__c != null && Integer.valueOf(opp.HDM_ProjectViability__c) >= Integer.valueOf(oppCriteria.HDM_MinProjectViability__c) || oppCriteria.HDM_MinProjectViability__c == null)
                                                && (opp.HDM_HeidelbergProbability__c != null && oppCriteria.HDM_MinHeidelbergProbability__c != null && Integer.valueOf(opp.HDM_HeidelbergProbability__c) >= Integer.valueOf(oppCriteria.HDM_MinHeidelbergProbability__c) || oppCriteria.HDM_MinHeidelbergProbability__c == null)
                                                && (String.IsNotBlank(technologyFieldName) && (Double)opp.get(technologyFieldName) >= oppCriteria.HDM_MinSalesVolumeInTechnology__c)
                                                && (opp.IsClosed == false && opp.CloseDate <= Date.today().addDays((Integer)oppCriteria.HDM_DaysUntilCloseDate__c) 
                                                    || opp.IsClosed == true && opp.StageName == 'Closed Won' && opp.CloseDate.addDays((Integer)oppCriteria.HDM_GracePeriod__c) >= Date.today());
                        // let's leave temporary the next comments for the testing on QA    
                        System.debug('....opp: '+opp.Id + ' : '+opp.Name);
                        System.debug('....1: '+(HDM_OpportunityVolumeConstants.stageValues.get(opp.StageName) >= HDM_OpportunityVolumeConstants.stageValues.get(oppCriteria.HDM_Stage__c)));
                        System.debug('....1.1: '+HDM_OpportunityVolumeConstants.stageValues.get(opp.StageName));
                        System.debug('....1.2: '+HDM_OpportunityVolumeConstants.stageValues.get(oppCriteria.HDM_Stage__c));
                        System.debug('....2: '+(opp.HDM_ProjectViability__c != null && oppCriteria.HDM_MinProjectViability__c != null && Integer.valueOf(opp.HDM_ProjectViability__c) >= Integer.valueOf(oppCriteria.HDM_MinProjectViability__c)));
                        System.debug('....3: '+(opp.HDM_HeidelbergProbability__c != null && oppCriteria.HDM_MinHeidelbergProbability__c != null && Integer.valueOf(opp.HDM_HeidelbergProbability__c) >= Integer.valueOf(oppCriteria.HDM_MinHeidelbergProbability__c)));
                        System.debug('....4: '+(String.IsNotBlank(technologyFieldName) && (Double)opp.get(technologyFieldName) >= oppCriteria.HDM_MinSalesVolumeInTechnology__c));
                        System.debug('....4.0: '+oppCriteria.HDM_Technology__c);
                        System.debug('....4.1: '+technologyFieldName);
                        System.debug('....4.2: '+(Double)opp.get(technologyFieldName));
                        System.debug('....4.3: '+oppCriteria.HDM_MinSalesVolumeInTechnology__c);
                        System.debug('....5: '+(opp.CloseDate <= Date.today().addDays((Integer)oppCriteria.HDM_DaysUntilCloseDate__c)));
                        System.debug('....criteriaReached: '+criteriaReached);

                        if (criteriaReached) {
                            oppCriteriaRiched = true;
                            opp.HDM_ShortTermPriority__c = true;
                            oppsToUpdate.put(opp.Id, opp); 
                            // check the lates opp on acc
                            if (accIdToLatestSTPOpp.containsKey(opp.AccountId) && accIdToLatestSTPOpp.get(opp.AccountId).isNewOppTheLatest(opp, oppCriteria) 
                            || !accIdToLatestSTPOpp.containsKey(opp.AccountId)) {
                                accIdToLatestSTPOpp.put(opp.AccountId, new STPOpportunity(opp, oppCriteria));
                            }
                        }
                    }
                }
                // removes checkbox from opportunity
                if (!oppCriteriaRiched && opp.HDM_ShortTermPriority__c == true) {
                    opp.HDM_ShortTermPriority__c = false;
                    oppsToUpdate.put(opp.Id, opp); 
                }

                for (Id accId : accIdToLatestSTPOpp.keySet()) {
                    Opportunity latestOpp = accIdToLatestSTPOpp.get(accId).opp;
                    HDM_ShortTermPriorityAssignment__c latestOppCriteria = accIdToLatestSTPOpp.get(accId).criteria;
                    if (latestOpp.IsClosed == true && latestOpp.StageName == 'Closed Won') {
                        accsToUpdate.put(latestOpp.AccountId, new Account(Id = latestOpp.AccountId, 
                            HDM_ShortTermPriority__c = true,
                            HDM_LatestShortTermPriorityOppo__c = latestOpp.Id,
                            HDM_EndOfGracePeriod__c = latestOpp.CloseDate.addDays((Integer)latestOppCriteria.HDM_GracePeriod__c)
                        ));
                    } else {
                        accsToUpdate.put(latestOpp.AccountId, new Account(Id = latestOpp.AccountId, 
                            HDM_ShortTermPriority__c = true,
                            HDM_LatestShortTermPriorityOppo__c = latestOpp.Id,
                            HDM_EndOfGracePeriod__c = null
                        ));
                    }
                }
            }

            System.debug('....oppsToUpdate: ' + JSON.serializePretty(oppsToUpdate));
            if (!oppsToUpdate.isEmpty()) {
                List<Database.SaveResult> saveResults = Database.update(oppsToUpdate.values(), false);
                handleResults(saveResults);

                update accsToUpdate.values();
            }
        } catch (Exception ex) {
            System.debug(Logginglevel.ERROR, '....exception: ' + ex.getMessage() + '\n....stack trace:' + ex.getStackTraceString());
            insertErrorLog(ex.getStackTraceString(), ex.getMessage(), 'HDM_OpportunityShortTermPriorityBatch.execute: Exception', '');
        }

    }

    public void finish(Database.BatchableContext bc) {
        Database.executeBatch(new HDM_AccountShortTermPriorityBatch());
    }

    public void execute(SchedulableContext context) {
        Database.executeBatch(new HDM_OpportunityShortTermPriorityBatch());
    }

    public static void handleResults(List<Database.SaveResult> saveResults) {
        List<Id> failedIds = new List<Id>();
        String errorMessages = '';
        List<HDM_ErrorLog__c> errorLogs = new List<HDM_ErrorLog__c>();
        for (Database.SaveResult saveResult : saveResults) {
            if (!saveResult.isSuccess()) {
                failedIds.add(saveResult.getId());
                Database.Error error = saveResult.getErrors().get(0);
                String message = '....error: ' + error.getMessage() + '\nId: ' + saveResult.getId() + '\nStatusCode: ' + error.getStatusCode() + '\nfields: ' + error.getFields();
                System.debug(Logginglevel.ERROR, message);
                errorMessages += (message + '\n');
            }
        }
        if (!failedIds.isEmpty()) {
            insertErrorLog(errorMessages, '', 'HDM_OpportunityShortTermPriorityBatch.execute: Database.update', String.join(failedIds, ';'));
        }
    }

    public static void insertErrorLog(String stackTrace, String message, String className, String recordIds) {
        insert new HDM_ErrorLog__c(
            HDM_ErrorStackTrace__c = String.isNotBlank(stackTrace) ? stackTrace.abbreviate(32768) : '',
            HDM_ErrorMessage__c = String.isNotBlank(message) ? message.abbreviate(255) : '',
            HDM_ClassMethodName__c = className,
            HDM_RecordIds__c = recordIds
        );
    }

    private class STPOpportunity {
        Opportunity opp;
        HDM_ShortTermPriorityAssignment__c criteria;

        public STPOpportunity (Opportunity opp, HDM_ShortTermPriorityAssignment__c criteria) {
            this.opp = opp;
            this.criteria = criteria;
            this.opp.Account.HDM_EndOfGracePeriod__c = this.opp.CloseDate.addDays((Integer)this.criteria.HDM_GracePeriod__c);
        }

        public Boolean isNewOppTheLatest(Opportunity newOpp, HDM_ShortTermPriorityAssignment__c newCriteria) {
            Boolean newOppIsLatest = false;
            if (this.opp.Account.HDM_EndOfGracePeriod__c < newOpp.CloseDate.addDays((Integer)newCriteria.HDM_GracePeriod__c)) {
                newOppIsLatest = true;
            }
            return newOppIsLatest;
        }
    }
}