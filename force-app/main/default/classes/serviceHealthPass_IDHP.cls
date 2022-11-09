/**
* @author Srikanth Kottam
* @date 4/1/2021
* @group Bluewolf an IBM Company
* @description Generate Vaccine Proof
**/

public with sharing class serviceHealthPass_IDHP{
    
    public static Account dhpHolder { get; set; }
    public static List<Vaccination__c> vaccineDetails;
    private static final string VACCINE_SCHEMA_ID = System.Label.Vaccine_Schema_ID;
    private static final string VACCINE_SCHEMA_ID_QR = System.Label.Vaccine_Schema_ID_QR;
    
    public  serviceHealthPass_IDHP(ApexPages.StandardController controller){
        initializeStaticVar();
    } 
    
    /**
    * @return none
    * @description initializes static variables
    */
    public static void initializeStaticVar(){
        Vaccination__c vaccineRecord;
        dhpHolder = null;
        Id vaccineId = ApexPages.currentPage().getParameters().get('id');        
        vaccineDetails = utilityClass_IDHP.getInitialvaccineDetails(vaccineId);
        List<Account> accountList = utilityClass_IDHP.getAccountDetails(vaccineDetails[0].Person_Vaccinated_IDHP__r.accountId);
        dhpHolder = accountList[0];
    }
    
    /**
    * @return pagereference
    * @description performs integration and captures the reponse details , once the input wrapper is formed
    */
    public static pagereference getDHPProof(){
        
        initializeStaticVar();
        
        StringQRCredentials_IDHP dhpProofService = new StringQRCredentials_IDHP();
        List<DHP_Issuer_Registration__mdt> issuerRegestrationDetails = utilityClass_IDHP.getDHPIssuerDetails(VACCINE_SCHEMA_ID);
        List<DHP_Issuer_Registration__mdt> issuerRegestrationDetailsQR = utilityClass_IDHP.getDHPIssuerDetails(VACCINE_SCHEMA_ID_QR);
        dhpProofService.schemaID = issuerRegestrationDetails[0].SchemaID_IDHP__c; 
        
        if(vaccineDetails != null ){  
            string expirationDate = string.valueOf(vaccineDetails[0].Expiration_Date_Time_IDHP__c.date());                                                       
            string expirationTime = string.valueOf(vaccineDetails[0].Expiration_Date_Time_IDHP__c.time()).replace('.',';');
            List<string> expiryTimeList = expirationTime.split(';');
            string expiryDatefinal = expirationDate + 'T' + expiryTimeList[0] + 'Z';  
            dhpProofService.expirationDate = string.valueOf(expiryDatefinal);  
            
            StringQRCredentials_IDHP.cls_data dhpProofServiceData = new StringQRCredentials_IDHP.cls_data();    
            
            dhpProofServiceData.type = vaccineDetails[0].Credential_Type_IDHP__c;
            dhpProofServiceData.status = vaccineDetails[0].Status_IDHP__c;
            dhpProofServiceData.targetDisease = vaccineDetails[0].Target_Disease_IDHP__c;
            dhpProofServiceData.vaccine = vaccineDetails[0].Vaccine_Type_IDHP__c;
            dhpProofServiceData.vaccineCode = vaccineDetails[0].Vaccine_Code_IDHP__c;
            dhpProofServiceData.manufacturer = vaccineDetails[0].Manufacturer_Name_IDHP__c;
            dhpProofServiceData.lotNumber = vaccineDetails[0].Lot_Number_IDHP__c;  
            dhpProofServiceData.occurrenceDateTime = string.valueOf(vaccineDetails[0].Occurrence_Date_Time__c);
            dhpProofServiceData.display = vaccineDetails[0].Display_IDHP__c;
            dhpProofService.data = dhpProofServiceData;
            
            StringQRCredentials_IDHP.cls_subject dhpProofServiceSubject = new StringQRCredentials_IDHP.cls_subject(); 
            
            dhpProofServiceSubject.birthDate = string.valueOf(dhpHolder.Resident_Birthdate_IDHP__pc);
            dhpProofServiceSubject.gender = dhpHolder.Resident_Gender_IDHP__pc;
            dhpProofServiceSubject.phone = string.valueOf(dhpHolder.Phone);
            dhpProofServiceSubject.email = String.ValueOf(dhpHolder.PersonEmail);
            dhpProofServiceSubject.address = string.valueOf(dhpHolder.BillingAddress);
            
            
            StringQRCredentials_IDHP.cls_name dhpProofServiceName = new StringQRCredentials_IDHP.cls_name(); 
            
            dhpProofServiceName.given = dhpHolder.FirstName;
            dhpProofServiceName.family = dhpHolder.LastName;
            dhpProofServiceSubject.name = dhpProofServiceName;
            
            List<StringQRCredentials_IDHP.cls_identity> dhpProofServiceIdentityList = new List<StringQRCredentials_IDHP.cls_identity>(); 
            StringQRCredentials_IDHP.cls_identity dhpProofServiceIdentity = new StringQRCredentials_IDHP.cls_identity();
            dhpProofServiceIdentity.type = dhpHolder.Identity_Type_IDHP__c; 
            dhpProofServiceIdentity.Sourcesystem = dhpHolder.Source_System_IDHP__c; 
            dhpProofServiceIdentity.value = dhpHolder.Identity_Value_IDHP__c; 
            dhpProofServiceIdentityList.add(dhpProofServiceIdentity);
            dhpProofServiceSubject.identity = dhpProofServiceIdentityList;
            dhpProofService.data.subject = dhpProofServiceSubject;
            
            List<StringQRCredentials_IDHP.cls_history> vaccinationDetails = new List<StringQRCredentials_IDHP.cls_history>(); 
            for(Vaccination_History__c vh  :utilityClass_IDHP.getVaccineHistoryDetails(vaccineDetails[0].Id))
            {
                StringQRCredentials_IDHP.cls_history historyDetails = new StringQRCredentials_IDHP.cls_history();                   
                historyDetails.vaccineCode = vh.Vaccine_Code_IDHP__c;
                historyDetails.vaccine = vh.Vaccine_Administered_IDHP__r.Vaccine_Type_IDHP__c; 
                historyDetails.manufacturer = vh.Vaccine_Administered_IDHP__r.Manufacturer_Name_IDHP__c; 
                historyDetails.occurrenceDateTime = string.valueof(vh.Occurrence_Date_Time__c);
                historyDetails.lotNumber = vh.Lot_Number_IDHP__c;
                vaccinationDetails.add(historyDetails);                
            }
            
            dhpProofService.data.history = vaccinationDetails;
            
            try{
                if(issuerRegestrationDetails != null && !issuerRegestrationDetails.isEmpty()){
                    String payload = JSON.Serialize(dhpProofService);
                    
                    //Publish the Event to DHP Outbound
                    // Create an instance of the event and store it in the DHP Outbound Event variable
                    DHP_Outbound__e postEvent = new DHP_Outbound__e(
                        RecordId__c = vaccineDetails[0].Id,
                        Payload__c = payload);
                    // Call method to publish events
                    Database.SaveResult sr = EventBus.publish(postEvent);
                    // Inspect publishing result
                    if (sr.isSuccess()) {
                       // System.debug('Successfully published event');
                    } else {
                        String errorMessage;
                        for(Database.Error err : sr.getErrors()) {
                            errorMessage = err.getMessage();
                            System.debug('Error returned: ' +
                                         err.getStatusCode() +
                                         ' - ' +
                                         err.getMessage());
                        }
                        Errorlogger.createIntegrationLogs('Error Posting Credential: ', errorMessage, 'serviceHealthPass_IDHP.getDHPProof',vaccineDetails[0].Id,'Vaccination');
                    }
                }
            }catch(exception e){
                system.debug('check the message'+e.getmessage());
                system.debug('check the message'+e.getLineNumber());
                Errorlogger.createIntegrationLogs('Error Posting Credential at: '+e.getLineNumber(), e.getmessage(), 'serviceHealthPass_IDHP.getDHPProof',vaccineDetails[0].Id,'Vaccination');
            }   
        } 
        
        for(integer i=0; i<400000; i++){
            //Do nothing -- time for processing the event
        }
        
        PageReference pageRef = new PageReference('/'+vaccineDetails[0].Id);
        pageRef.setRedirect(true);
        return pageRef; //Returns to the VaccineRecord page
    }
}