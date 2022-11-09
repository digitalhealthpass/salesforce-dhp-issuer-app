/**
* @author Srikanth Kottam
* @date 4/1/2021
* @group Bluewolf an IBM Company
* @description Utility Class which helps in querying records
**/
public  class utilityClass_IDHP{

    public  static list<DHP_Issuer_Registration__mdt> getDHPIssuerDetails(string IntegrationName){

        return [SELECT Id, developerName, Id_IDHP__c,End_Point__c,
        SchemaID_IDHP__c, Version_IDHP__c 
        FROM   DHP_Issuer_Registration__mdt 
        WHERE  developerName = :IntegrationName];
    }

    public  static List<Vaccination_History__c> getVaccineHistoryDetails(Id vaccineDetailsId){

        List<Vaccination_History__c> vacHisList = new List<Vaccination_History__c>();
        String [] vhFields = new String [] {'Id','Name','Administered_Date_IDHP__c','Lot_Number_IDHP__c', 'Vaccine_Code_IDHP__c',
            'Vaccine_Administered_IDHP__c','Occurrence_Date_Time__c'};
        String [] vFields = new String [] {'Manufacturer_Name_IDHP__c', 'Vaccine_Type_IDHP__c'};
        Map<String,Schema.SObjectField> vhFieldsMap = Schema.SObjectType.Vaccination_History__c.fields.getMap();
        Map<String,Schema.SObjectField> vFieldsMap = Schema.SObjectType.Vaccination__c.fields.getMap();
        if(Schema.sObjectType.Vaccination_History__c.isAccessible()){
            for (String fieldToCheck : vhFields) {
                // Check if the user has access on the each field
                if (!vhFieldsMap.get(fieldToCheck).getDescribe().isAccessible()) {
                    return vacHisList;
                }
            }
        } else {
            return vacHisList;
        }
        
        if(Schema.sObjectType.Vaccination__c.isAccessible()){
            for (String fieldToCheck : vFields) {
                // Check if the user has create access on the each field
                if (!vFieldsMap.get(fieldToCheck).getDescribe().isAccessible()) {
                    return vacHisList;
                }
            }
        } else {
            return vacHisList;
        }       
        
        return  [SELECT Id,Name,Administered_Date_IDHP__c,Lot_Number_IDHP__c,Vaccine_Administered_IDHP__r.Vaccine_Type_IDHP__c,
                 Vaccine_Administered_IDHP__c,Vaccine_Code_IDHP__c,Occurrence_Date_Time__c,Vaccine_Administered_IDHP__r.Manufacturer_Name_IDHP__c
                 FROM   Vaccination_History__c
                 WHERE  Vaccine_Administered_IDHP__c = :vaccineDetailsId];
    }
    
    public  static List<Vaccination_History__c> getVaccineHistoryList(Id vaccineHistoryDetailsId){

        List<Vaccination_History__c> vacHisList = new List<Vaccination_History__c>();
        String [] vhFields = new String [] {'Vaccine_Administered_IDHP__c', 'Vaccine_Code_IDHP__c', 'Occurrence_Date_Time__c', 'Lot_Number_IDHP__c'};
        String [] vFields = new String [] {'Vaccine_Type_IDHP__c', 'Manufacturer_Name_IDHP__c'};
        Map<String,Schema.SObjectField> vhFieldsMap = Schema.SObjectType.Vaccination_History__c.fields.getMap();
        Map<String,Schema.SObjectField> vFieldsMap = Schema.SObjectType.Vaccination__c.fields.getMap();
        
        if(Schema.sObjectType.Vaccination_History__c.isAccessible()){
            for (String fieldToCheck : vhFields) {
                // Check if the user has access on the each field
                if (!vhFieldsMap.get(fieldToCheck).getDescribe().isAccessible()) {
                    return vacHisList;
                }
            }
        } else {
            return vacHisList;
        }   
        
        if(Schema.sObjectType.Vaccination__c.isAccessible()){
            for (String fieldToCheck : vFields) {
                // Check if the user has create access on the each field
                if (!vFieldsMap.get(fieldToCheck).getDescribe().isAccessible()) {
                    return vacHisList;
                }
            }
        } else {
            return vacHisList;
        }   
        
        return  [SELECT Vaccine_Administered_IDHP__c, Vaccine_Code_IDHP__c, Occurrence_Date_Time__c, 
                 Lot_Number_IDHP__c,Vaccine_Administered_IDHP__r.Vaccine_Type_IDHP__c, Vaccine_Administered_IDHP__r.Manufacturer_Name_IDHP__c
                 FROM Vaccination_History__c WHERE  Id = :vaccineHistoryDetailsId];
    }

    public  static List<Account> getAccountDetails(Id accountRecordId){

        List<Account> accList = new List<Account>();
        String [] accFields = new String [] {'PersonContactId','Nationality_IDHP__pc','Passport_IDHP__pc','Source_System_IDHP__c','Identity_Value_IDHP__c','PersonEmail',
                 'Resident_Birthdate_IDHP__pc', 'Resident_Gender_IDHP__pc','FirstName', 'LastName','Identity_Type_IDHP__c','BillingAddress','Phone'};
        String [] conFields = new String [] {'Id', 'AccountId', 'Nationality_IDHP__c', 'Passport_IDHP__c', 
                  'Resident_Birthdate_IDHP__c', 'Resident_Gender_IDHP__c', 'FirstName', 'LastName'};
        Map<String,Schema.SObjectField> accFieldsMap = Schema.SObjectType.Account.fields.getMap();
        Map<String,Schema.SObjectField> conFieldsMap = Schema.SObjectType.Contact.fields.getMap();
        
        if(Schema.sObjectType.Account.isAccessible()){
            for (String fieldToCheck : accFields) {
                // Check if the user has create access on the each field
                if (!accFieldsMap.get(fieldToCheck).getDescribe().isAccessible()) {
                    return accList;
                }
            }
        } else {
            return accList;
        }
        
        if(Schema.sObjectType.Contact.isAccessible()){
            for (String fieldToCheck : conFields) {
                // Check if the user has create access on the each field
                if (!conFieldsMap.get(fieldToCheck).getDescribe().isAccessible()) {
                    return accList;
                }
            }
        } else {
            return accList;
        }
        
        return  [SELECT PersonContactId,Nationality_IDHP__pc,Passport_IDHP__pc,Source_System_IDHP__c,Identity_Value_IDHP__c,PersonEmail,
                 Resident_Birthdate_IDHP__pc, Resident_Gender_IDHP__pc,FirstName, LastName,Identity_Type_IDHP__c,BillingAddress,Phone,     
                 (SELECT Id, AccountId, Nationality_IDHP__c, Passport_IDHP__c, 
                  Resident_Birthdate_IDHP__c, Resident_Gender_IDHP__c, FirstName, LastName 
                  FROM Contacts) 
                 FROM Account 
                 WHERE Id = :accountRecordId];
    }
    
    public  static List<Vaccination__c> getInitialvaccineDetails(Id vaccineId){

        List<Vaccination__c> vaccList = new List<Vaccination__c>();
        String [] vFields = new String [] {'Id','Administered_Date_Time_IDHP__c','Credential_Type_IDHP__c','Lot_Number_IDHP__c','DHP_Proof_IDHP__c','Display_IDHP__c','Expiration_Date_Time_IDHP__c', 'Manufacturer_Name_IDHP__c','Person_Vaccinated_IDHP__c','Status_IDHP__c','Occurrence_Date_Time__c','Target_Disease_IDHP__c','Vaccination_Key_IDHP__c','Vaccine_Code_IDHP__c','Vaccine_Type_IDHP__c'};
        Map<String,Schema.SObjectField> vFieldsMap = Schema.SObjectType.Vaccination__c.fields.getMap();
        
        if(!Schema.sObjectType.Contact.fields.AccountId.isAccessible() && 
           !Schema.sObjectType.Contact.isAccessible()){
               return vaccList;
           }
        
        if(Schema.sObjectType.Vaccination__c.isAccessible()){
            for (String fieldToCheck : vFields) {
                // Check if the user has create access on the each field
                if (!vFieldsMap.get(fieldToCheck).getDescribe().isAccessible()) {
                    return vaccList;
                }
            }
        } else {
            return vaccList;
        }
        
        return  [Select Id,Administered_Date_Time_IDHP__c,Credential_Type_IDHP__c,Lot_Number_IDHP__c,
                 DHP_Proof_IDHP__c,Display_IDHP__c,Expiration_Date_Time_IDHP__c, Person_Vaccinated_IDHP__r.AccountId,
                 Manufacturer_Name_IDHP__c,Person_Vaccinated_IDHP__c,Status_IDHP__c,Occurrence_Date_Time__c,
                 Target_Disease_IDHP__c,Vaccination_Key_IDHP__c,Vaccine_Code_IDHP__c,Vaccine_Type_IDHP__c 
                 FROM   Vaccination__c 
                 WHERE Id = :vaccineId];
    }
    
    
    public  static List<ContentDocumentLink> getContentDocumentLinks(Id vaccineId){

        List<ContentDocumentLink> contList = new List<ContentDocumentLink>();
        String [] contDocFields = new String [] {'Id', 'LinkedEntityId', 'ContentDocumentId', 'IsDeleted', 'SystemModstamp', 'ShareType', 'Visibility'};
        Map<String,Schema.SObjectField> contDocFieldsMap = Schema.SObjectType.ContentDocumentLink.fields.getMap();
        
        if(Schema.sObjectType.ContentDocumentLink.isAccessible()){
            for (String fieldToCheck : contDocFields) {
                // Check if the user has create access on the each field
                if (!contDocFieldsMap.get(fieldToCheck).getDescribe().isAccessible()) {
                    return contList;
                }
            }
        } else {
            return contList;
        }
        return  [Select Id, LinkedEntityId, ContentDocumentId, IsDeleted, SystemModstamp, ShareType, 
                 Visibility FROM ContentDocumentLink 
                 WHERE LinkedEntityId = :vaccineId LIMIT 1];
    }
    
}