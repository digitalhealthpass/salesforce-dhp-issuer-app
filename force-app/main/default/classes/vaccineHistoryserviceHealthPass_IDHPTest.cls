@isTest
private class vaccineHistoryserviceHealthPass_IDHPTest {

    @testSetup static void setup() {

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
    }

    static testMethod void updateVaccinewithDHPProof() {
        DateTime dt = System.now();
        LIST<Account> actLIST = [Select Id from account LIMIT 1];
        Contact ct = [Select Id,Name,AccountId from Contact where AccountId = :actLIST[0].Id LIMIT 1];
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

        PageReference pageRef = Page.QRCode_IDHP;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(vaccineHistory.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(vaccineHistory);
        vaccineHistoryserviceHealthPass_IDHP vaccineProofTest = new vaccineHistoryserviceHealthPass_IDHP(sc);

        Test.startTest();
            vaccineHistoryserviceHealthPass_IDHP.getDHPProof();
        Test.stopTest();

        Vaccination_History__c vaccineHistoryDetails = [SELECT Id,DHP_Proof_IDHP__c FROM Vaccination_History__c LIMIT 1];
        System.assert(vaccineHistoryDetails.DHP_Proof_IDHP__c == null);
    }

}