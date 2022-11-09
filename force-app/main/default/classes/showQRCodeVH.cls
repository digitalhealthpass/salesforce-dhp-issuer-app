/**
* @author Srikanth Kottam
* @date 4/1/2021
* @group Bluewolf an IBM Company
* @description Show QR code
**/
public with sharing class showQRCodeVH{
    public List<ContentDocumentLink> files{get;set;}
    public ContentVersion contentVersion{get;set;}
    public Vaccination_History__c vaccineHistoryRec{get;set;}
    public string currentvfpage{get;set;}
    public showQRCodeVH( ApexPages.StandardController controller){
        
        Vaccination_History__c vaccineHistoryRec = (Vaccination_History__c)controller.getRecord();
        if(vaccineHistoryRec != null){
            //files = [SELECT Id, LinkedEntityId, ContentDocumentId
            //         FROM ContentDocumentLink WHERE LinkedEntityId = :vaccineHistoryRec.Id];
            files = utilityClass_IDHP.getContentDocumentLinks(vaccineHistoryRec.Id);
            if(files != null && !files.isEmpty()){        
                if(Schema.sObjectType.ContentVersion.fields.ContentDocumentId.isAccessible() &&
                   Schema.sObjectType.ContentVersion.fields.Id.isAccessible() &&
                   Schema.sObjectType.ContentVersion.isAccessible()){
                       List<ContentVersion> contentVersionList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =:files[0].ContentDocumentId];
                       contentVersion = contentVersionList[0];
                   }
            }
        }   
    }
}