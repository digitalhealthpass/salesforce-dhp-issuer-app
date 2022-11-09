public with sharing class DHPInbountEventTriggerHandler {
    public static void OnAfterInsert(List<DHP_Inbound__e> dhpEventsList){
        Map<Id, Vaccination__c> vaccMap = new Map<Id, Vaccination__c>();
        Map<Id, Vaccination_History__c> vaccHisMap = new Map<Id, Vaccination_History__c>();
        Map<Id, ContentVersion> conVerMap = new Map<Id, ContentVersion>();
        Id recId;
        if(!dhpEventsList.isEmpty()){
            for(DHP_Inbound__e dhpEvent : dhpEventsList){
                if(dhpEvent.RecordId__c != null && !String.isBlank(dhpEvent.RecordId__c)){
                    recId = dhpEvent.RecordId__c;
                    String objApiName = String.valueOf(recId.getsobjecttype());
                    //DHP Proof
                    if(dhpEvent.DHP_Proof__c != null && !String.isBlank(dhpEvent.DHP_Proof__c)){
                        if(objApiName == 'Vaccination__c'){
                            Vaccination__c vaccRec = new Vaccination__c();
                            vaccRec.DHP_Proof_IDHP__c = dhpEvent.DHP_Proof__c;
                            vaccRec.Id = dhpEvent.RecordId__c;
                            vaccMap.put(dhpEvent.RecordId__c, vaccRec);
                        } else if(objApiName == 'Vaccination_History__c'){
                            Vaccination_History__c vaccHisRec = new Vaccination_History__c();
                            vaccHisRec.Id = dhpEvent.RecordId__c;
                            vaccHisRec.DHP_Proof_IDHP__c = dhpEvent.DHP_Proof__c;
                            vaccHisMap.put(dhpEvent.RecordId__c, vaccHisRec);
                        }
                    }
                    //QRcode
                    if(dhpEvent.QRCode__c != null && !String.isBlank(dhpEvent.QRCode__c)){
                        //String qrcodeStr = ( String ) JSON.deserialize( dhpEvent.QRCode__c, String.class );
                        //System.debug('qrcodeStr>>>'+qrcodeStr);
                        Blob image = EncodingUtil.base64Decode(dhpEvent.QRCode__c);
                        
                        ContentVersion conVer = new ContentVersion();
                        conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
                        conVer.PathOnClient = 'VaccineQRCode.png'; // The files name, extension is very important here which will help the file in preview.
                        conVer.Title = 'Vaccine QRCode'; // Display name of the files
                        conVer.VersionData = image;
                        conVerMap.put(dhpEvent.RecordId__c, conVer);
                        recId = dhpEvent.RecordId__c;
                    }
                    
                } else {
                    //Do nothing
                    //System.debug('Payload Type should be either Claim or Steps');
                }
            }
        }
        if(!vaccMap.isEmpty()){
            try{
                List<Vaccination__c> vaccList = vaccMap.values();
                if(Schema.sObjectType.Vaccination__c.isUpdateable() && Schema.sObjectType.Vaccination__c.fields.DHP_Proof_IDHP__c.isUpdateable()){
                    update vaccList;
                }
            } catch(DmlException ex){
                System.debug('Update Failed Vaccine Record>>>'+ex.getMessage());
                Errorlogger.createIntegrationLogs('Update Failed Vaccine Record', ex.getMessage(), 'DHPInbountEventTriggerHandler',recId,'Vaccination');
            }
        }
        
        if(!vaccHisMap.isEmpty()){
            try{
                List<Vaccination_History__c> vaccHistList = vaccHisMap.values();
                if(Schema.sObjectType.Vaccination_History__c.isUpdateable() && Schema.sObjectType.Vaccination_History__c.fields.DHP_Proof_IDHP__c.isUpdateable()){
                    update vaccHistList;
                }
            } catch(DmlException ex){
                System.debug('Update Failed Vaccine History Record>>>'+ex.getMessage());
                Errorlogger.createIntegrationLogs('Update Failed Vaccine History Record', ex.getMessage(), 'DHPInbountEventTriggerHandler',recId,'Vaccination History');
            }
        }
        
        if(!conVerMap.isEmpty()){
            List<ContentDocumentLink> contDocList = [Select Id, LinkedEntityId, ContentDocumentId, IsDeleted, SystemModstamp, ShareType, 
                                                     Visibility FROM ContentDocumentLink 
                                                     WHERE LinkedEntityId =: conVerMap.keySet()];
            if(contDocList.size()>0){
                try{
                    if(Schema.sObjectType.ContentDocumentLink.isDeletable()){
                        delete contDocList;
                    } else{
                        system.debug('Delete failed: Doesnt have Delete permissions - Object: ContentDocumentLink>>>'+contDocList);
                    } 
                } catch(DmlException ex){
                    System.debug('Delete failed contDocList>>>'+ex.getMessage());
                    Errorlogger.createIntegrationLogs('Delete failed contDocList', ex.getMessage(), 'DHPInbountEventTriggerHandler',recId,'ContentDocumentLink');
                }
                
            }
            
            List<ContentVersion> contVerList = new List<ContentVersion>();
            contVerList = conVerMap.values();
            if(!contVerList.isEmpty()){
                try{
                    if(Schema.sObjectType.ContentVersion.isCreateable() &&
                       Schema.sObjectType.ContentVersion.fields.ContentLocation.isCreateable() &&
                       Schema.sObjectType.ContentVersion.fields.PathOnClient.isCreateable() &&
                       Schema.sObjectType.ContentVersion.fields.Title.isCreateable() &&
                       Schema.sObjectType.ContentVersion.fields.VersionData.isCreateable()){
                           insert contVerList;
                       } else{
                           system.debug('Insert failed: Doesnt have insert permissions - Object: ContentVersion>>>'+contVerList);
                       } 
                    //querying only 1 record as we shall receive only 1 QR code at a time
                    Id contDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contVerList[0].Id].ContentDocumentId;
                    ContentDocumentLink conDocLink = New ContentDocumentLink();
                    conDocLink.LinkedEntityId = recId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
                    conDocLink.ContentDocumentId = contDocId;  //ContentDocumentId Id from ContentVersion
                    conDocLink.shareType = 'V';    
                    if(Schema.sObjectType.ContentDocumentLink.isCreateable() &&
                       Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isCreateable() &&
                       Schema.sObjectType.ContentDocumentLink.fields.ContentDocumentId.isCreateable() &&
                       Schema.sObjectType.ContentDocumentLink.fields.shareType.isCreateable()){
                           insert conDocLink;
                       } else{
                           System.debug('Insert failed -- Doesnt have insert permissions - Object: ContentDocumentLink' +conDocLink);
                       }    
                } catch(DmlException ex){
                    System.debug('Insert Failed contVerList/conDocLink>>>'+ex.getMessage());
                    Errorlogger.createIntegrationLogs('Insert Failed contVerList/conDocLink ', ex.getMessage(), 'DHPInbountEventTriggerHandler',recId,'ContentDocumentLink');
                }
            }
        }
    }
}