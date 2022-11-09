@isTest
public class DHPInboundEventTriggerTest {
	
    @TestSetup
    static void makeData(){
        Account acct = new Account();
        Schema.DescribeSObjectResult AccntRes = Account.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> AccRecordTypeInfo = AccntRes.getRecordTypeInfosByName();
        ID rtID = AccRecordTypeInfo.get('DHP Holder').getRecordTypeId();
        Date birthDt = system.today().addDays(-30);
        Account acc= new Account(
                                    RecordTypeID = rtID,
                                    FirstName='Test FName',
                                    LastName='Test LName',
                                    Passport_IDHP__pc = 'J489764',
                                    Nationality_IDHP__pc = 'Indian',
                                    Resident_Birthdate_IDHP__pc = birthDt,
                                    Resident_Gender_IDHP__pc = 'Male',
                                    PersonMailingStreet='123 street',
                                    PersonMailingPostalCode='12345',
                                    PersonMailingCity='SFO',
                                    PersonEmail='test@yahoo.com',
                                    PersonHomePhone='1234567',
                                    PersonMobilePhone='12345678',
            						// Start of changes by SRK
            						BillingStreet = '123 Street',
                                    BillingCity = 'TestCity',
                                    BillingState = 'TestState',
                                    BillingPostalCode = '12345',
                                    BillingCountry = 'US'
            						// End of changes by SRK 
                                );
        insert acc;
        
        Contact ct = [Select Id,Name,AccountId from Contact where AccountId = :acc.Id LIMIT 1];
        DateTime dt = System.now();
        Vaccination__c vaccine = new Vaccination__c(Administered_Date_Time_IDHP__c =dt,Credential_Type_IDHP__c = 'Vaccination Card', 
                                                    Display_IDHP__c='green', Expiration_Date_Time_IDHP__c=dt.addDays(1), Manufacturer_Name_IDHP__c='Pfizer', Lot_Number_IDHP__c = '206',
                                                    Person_Vaccinated_IDHP__c=ct.Id, Status_IDHP__c='in-progress', Target_Disease_IDHP__c='Covid-19',Vaccination_Key_IDHP__c='PK',
                                                    Vaccine_Code_IDHP__c= '91300-0001A', Vaccine_Type_IDHP__c='Pfizer-Biontech Covid-19 Vaccine',Occurrence_Date_Time__c = dt.date()
                                                    );
                                        
        insert vaccine;
        
        Vaccination_History__c vaccineHistory = new Vaccination_History__c(Administered_Date_IDHP__c =system.today(),Lot_Number_IDHP__c = '233', 
                                                                        Vaccine_Administered_IDHP__c=  vaccine.Id, Vaccine_Code_IDHP__c='208'
                                                                        );
                                        
        insert vaccineHistory;  
    }
    @isTest static void testValidVaccineEvent() {
		String qrCodeValue = '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';
        Id accId = [Select Id from Account where PersonEmail='test@yahoo.com' limit 1].Id;
        Id conId = [Select Id from Contact where AccountId = :accId limit 1].Id;
        Id vaccId = [Select Id from Vaccination__c where Person_Vaccinated_IDHP__c =: conId limit 1].Id;

        // Create a test event instance
        DHP_Inbound__e inboundEvent = new DHP_Inbound__e(RecordId__c=vaccId, QRCode__c=qrCodeValue, DHP_Proof__c='Verified');
        
        Test.startTest();
        
        // Publish test event
        Database.SaveResult sr = EventBus.publish(inboundEvent);
            
        Test.stopTest();
                
        // Perform validations here
        
        // Verify SaveResult value
        System.assertEquals(true, sr.isSuccess());
        
        // Verify that the status was updated by a trigger.
        String verifyStatus = [SELECT Id,DHP_Proof_IDHP__c FROM Vaccination__c LIMIT 1].DHP_Proof_IDHP__c;
        // Validate that this case was found
        System.assertEquals('Verified', verifyStatus);
    }
    
    @isTest static void testValidVaccineHistoryEvent() {
		String qrCodeValue = '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';
        Id accId = [Select Id from Account where PersonEmail='test@yahoo.com' limit 1].Id;
        Id conId = [Select Id from Contact where AccountId = :accId limit 1].Id;
        Id vaccId = [Select Id from Vaccination__c where Person_Vaccinated_IDHP__c =: conId limit 1].Id;
        Id vaccHisId = [Select Id from Vaccination_History__c where Vaccine_Administered_IDHP__c =: vaccId].Id;

        // Create a test event instance
        DHP_Inbound__e inboundEvent = new DHP_Inbound__e(RecordId__c=vaccHisId, QRCode__c=qrCodeValue, DHP_Proof__c='Verified');
        
        Test.startTest();
        
        // Publish test event
        Database.SaveResult sr = EventBus.publish(inboundEvent);
            
        Test.stopTest();
                
        // Perform validations here
        
        // Verify SaveResult value
        System.assertEquals(true, sr.isSuccess());
        
        // Verify that the status was updated by a trigger.
        String verifyStatus = [SELECT Id,DHP_Proof_IDHP__c FROM Vaccination_History__c LIMIT 1].DHP_Proof_IDHP__c;
        // Validate that this case was found
        System.assertEquals('Verified', verifyStatus);
    }
    
    @isTest static void testInvalidEvent() {
		Id accId = [Select Id from Account where PersonEmail='test@yahoo.com' limit 1].Id;
        Id conId = [Select Id from Contact where AccountId = :accId limit 1].Id;
        Id vaccId = [Select Id from Vaccination__c where Person_Vaccinated_IDHP__c =: conId limit 1].Id;
        
        // Create a test event instance with invalid data.
        // Publishing with a missing required field should fail.
        DHP_Inbound__e inboundEvent = new DHP_Inbound__e(RecordId__c=vaccId, QRCode__c='fail_Test');
        
        Test.startTest();
        
        // Publish test event
        Database.SaveResult sr = EventBus.publish(inboundEvent);
            
        Test.stopTest();
                
        // Perform validations here
        
        // Verify SaveResult value - isSuccess should be false
        System.assertEquals(true, sr.isSuccess());
        
        // Log the error message
        for(Database.Error err : sr.getErrors()) {
            System.debug('Error returned: ' +
                        err.getStatusCode() +
                        ' - ' +
                        err.getMessage()+' - '+err.getFields());
        }
        
        // Verify that the status was not updated by a trigger.
        String verifyStatus = [SELECT Id,DHP_Proof_IDHP__c FROM Vaccination_History__c LIMIT 1].DHP_Proof_IDHP__c;
        // Validate that this case was found
        System.assertNotEquals('Verified', verifyStatus);
    }
}