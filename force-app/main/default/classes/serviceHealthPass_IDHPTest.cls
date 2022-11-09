@isTest
private class serviceHealthPass_IDHPTest {

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
        pageRef.getParameters().put('Id', String.valueOf(vaccine.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(vaccine);
        serviceHealthPass_IDHP vaccineProofTest = new serviceHealthPass_IDHP(sc);
        string jsonBody = '{"message":"Credential created successfully","payload":{"@context":["https://www.w3.org/2018/credentials/v1"],"id":"did:hpass:095573b3ed146d92780bb6a51fadb9c64e0bc975079723b5f93db666ee44a67d:30b208fca96eb609644fd16ad1c5280c49240ef69df86d50183ea209b0338f19#vc-f1fedba3-c7bc-48e7-b96a-3ccf90fedbe5","type":["VerifiableCredential"],"issuer":"did:hpass:095573b3ed146d92780bb6a51fadb9c64e0bc975079723b5f93db666ee44a67d:30b208fca96eb609644fd16ad1c5280c49240ef69df86d50183ea209b0338f19","issuanceDate":"2021-01-13T11:25:08Z","expirationDate":"2021-01-28T03:22:00Z","credentialSchema":{"id":"did:hpass:095573b3ed146d92780bb6a51fadb9c64e0bc975079723b5f93db666ee44a67d:023e5571d0824bb43a74608c47043af51581bcb7e370499fd471ccb1c87c7639;id=pfizercovidvaccine;version=0.2","type":"JsonSchemaValidator2018"},"credentialSubject":{"date":"2021-01-05T15:00:00Z","display":"green","history":[],"key":"PK","manufacturer":"Pfizer","status":"completed","subject":{"birthDate":"1993-01-06","gender":"Male","name":{"firstname":"Jack","lastname":"Bowman"},"nationality":"Indian","passport":"J7864678"},"targetDisease":"Covid-19","type":"Vaccination Card","vaccine":"Pfizer-Biontech Covid-19 Vaccine","vaccineCode":"91300-0001A"},"proof":{"created":"2021-01-13T11:25:08Z","creator":"did:hpass:095573b3ed146d92780bb6a51fadb9c64e0bc975079723b5f93db666ee44a67d:30b208fca96eb609644fd16ad1c5280c49240ef69df86d50183ea209b0338f19#key-1","nonce":"0f25fcb4-9078-4757-a057-bed0f9336d70","signatureValue":"MEUCIQCHrr76tTzKkDenz8U4w97igFqO1MEkrve3NgOEXaJKUAIgGS8QgLAN_h9rgS0lYarinYdArcSjAxtckmRe7tRQTb0","type":"EcdsaSecp256r1Signature2019"}}}';
        HttpMockFactory mock = new HttpMockFactory(200, 'OK', jsonBody, new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
            serviceHealthPass_IDHP.getDHPProof();
        Test.stopTest();

        Vaccination__c vaccineDetails = [SELECT Id,DHP_Proof_IDHP__c FROM Vaccination__c LIMIT 1];
        System.assert(vaccineDetails.DHP_Proof_IDHP__c == null);

    }

}