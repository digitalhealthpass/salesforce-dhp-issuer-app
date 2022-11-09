/**
* @author Srikanth Kottam
* @date 4/1/2021
* @group Bluewolf an IBM Company
* @description Show QR code
**/
public with sharing class showQRCode{
    public List<ContentDocumentLink> files{get;set;}
    public ContentVersion contentVersion{get;set;}
    public Vaccination__c vaccineRec{get;set;}
    public string currentvfpage{get;set;}
    public showQRCode( ApexPages.StandardController controller){
        
        String pageName = ApexPages.currentPage().getParameters().get('currentvfpage');
        Vaccination__c vaccineRec = (Vaccination__c)controller.getRecord();
        if(vaccineRec != null){
            //files = [SELECT Id, LinkedEntityId, ContentDocumentId
            //         FROM ContentDocumentLink WHERE LinkedEntityId = :vaccineRec.Id];
            files = utilityClass_IDHP.getContentDocumentLinks(vaccineRec.Id);
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