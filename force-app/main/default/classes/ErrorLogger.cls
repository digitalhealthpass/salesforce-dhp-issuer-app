/**
 * @author Srikanth Kottam
 * @date 2/12/2021
 * @group Bluewolf an IBM Company
 * @description Error logging framework
 **/
public class ErrorLogger {
	/**
    * @return Void
    * @description  ICaptures the log information when integration with DHP has gone wrong
    */
    public static void createIntegrationLogs(String Status, String Json, String ClassMethod, String vaccineHistoryId,String ObjectName){
    
        Integration_Logs__c log = new Integration_Logs__c();
        
        log.Status__c = Status;
        log.JSON__c = Json;
        log.Class_Name__c = ClassMethod;
        log.ObjectId__c = vaccineHistoryId;
        log.Object_Name__c = ObjectName;
        // Start of changes by SRK
        // insert log; -- Commented
        if(Schema.sObjectType.Integration_Logs__c.isCreateable() && 
           Schema.sObjectType.Integration_Logs__c.fields.Status__c.isCreateable() &&
           Schema.sObjectType.Integration_Logs__c.fields.JSON__c.isCreateable() &&
           Schema.sObjectType.Integration_Logs__c.fields.Class_Name__c.isCreateable() &&
           Schema.sObjectType.Integration_Logs__c.fields.ObjectId__c.isCreateable() &&
           Schema.sObjectType.Integration_Logs__c.fields.Object_Name__c.isCreateable()){
            insert log;
        } else{
            system.debug('Cannot insert');
        }    
    }
}