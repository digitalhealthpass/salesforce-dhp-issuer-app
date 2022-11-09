trigger DHPInboundEventTrigger on DHP_Inbound__e (after insert) {
    try{
        DHPInbountEventTriggerHandler.OnAfterInsert(Trigger.New);
    } catch (Exception ex){
        Errorlogger.createIntegrationLogs('Update Failed Vaccine Record', ex.getMessage(), 'DHPInboundEventTrigger',null,'Inbound Event');
    }
}