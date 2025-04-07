Datetime scheduleTime = Datetime.now().addSeconds(1);
String cronExp = '' + scheduleTime.second() + ' ' + scheduleTime.minute() + ' ' +
                 scheduleTime.hour() + ' ' + scheduleTime.day() + ' ' +
                 scheduleTime.month() + ' ? ' + scheduleTime.year();
HDM_ScheduleTimeSheetCreationBatch job = new HDM_ScheduleTimeSheetCreationBatch();
String jobID = System.schedule('One time run HDM Time Sheet Creation Batch', cronExp, job);