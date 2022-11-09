/**
* @author Srikanth Kottam
* @date 4/1/2021
* @group Bluewolf an IBM Company
* @description DHP Credentials Wrapper class
**/
public class StringQRCredentials_IDHP{
    public String schemaID; 
    public cls_data data;
    public String expirationDate;   
    public class cls_data {
        public String type; 
        public cls_subject subject;
        public String status;   
        public String display;  
        public String targetDisease;    
        public String vaccine;  
        public String vaccineCode;  
        public String manufacturer; 
        public String lotNumber;    
        public String occurrenceDateTime;   
        public cls_history[] history;
    }
    public class cls_subject {
        public cls_identity[] identity;
        public cls_name name;
        public String birthDate;    
        public String gender;   
        public String phone;    
        public String email;    
        public String address;  
    }
    public class cls_identity {
        public String type; 
        public String Sourcesystem;   
        public String value;    
    }
    public class cls_name {
        public String given;    
        public String family;   
    }
    public class cls_history {
        public String vaccine;  
        public String vaccineCode;  
        public String manufacturer; 
        public String lotNumber;    
        public String occurrenceDateTime;   
    }
    public static StringQRCredentials_IDHP parse(String json){
        return (StringQRCredentials_IDHP) System.JSON.deserialize(json, StringQRCredentials_IDHP.class);
    }
    
  }