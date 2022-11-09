@isTest
private class showQRCodeVH_IDHPTest {

    @testSetup static void setup() {
    
    
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
                                    PersonMailingStreet='test@yahoo.com',
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
                                                                    Vaccine_Administered_IDHP__c=  vaccine.Id, Vaccine_Code_IDHP__c='208',Occurrence_Date_Time__c = dt.date()
                                                                    );
                                    
    insert vaccineHistory;   
        
        
        
    ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = 'VaccineQRCode.png';
        conVer.Title = 'Vaccine QRCode';
        conVer.VersionData = Blob.valueOf('Test Content');
        insert conVer;
        
        
        // First get the Content Document Id from ContentVersion Object
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        //create ContentDocumentLink  record 
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = vaccineHistory.Id;
        conDocLink.ContentDocumentId = conDoc;
        conDocLink.shareType = 'V';
        insert conDocLink;
        
   }      
    
        static testMethod void updateVaccinewithDHPProof() {
        
        Vaccination_History__c vaccineHistoryDetails = [SELECT Id,DHP_Proof_IDHP__c FROM Vaccination_History__c LIMIT 1];
        PageReference pageRef = Page.QRCode_IDHPVH;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(vaccineHistoryDetails.Id));
        
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(vaccineHistoryDetails); 
        showQRCodeVH vaccineProofTest = new showQRCodeVH(sc); 
        // Start of changes by SRK
        system.debug('vaccineProofTest>>>'+vaccineProofTest);
        system.assertNotEquals(null, vaccineProofTest);
        // End of changes by SRK
        Test.stopTest();
        
        
        
        }
    
    
    
    
    
    
    
    
    
}