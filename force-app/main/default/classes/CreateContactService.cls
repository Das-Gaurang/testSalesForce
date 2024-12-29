@RestResource(urlMapping='/createContact')
global with sharing class CreateContactService {
    @HttpPost
    global static void createContact() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        // Validate secret_app_key in header
        String secretAppKey = req.headers.get('secret_app_key');
        String expectedSecretAppKey = 'ekusdmbnjwehv9178'; // Replace with your actual secret app key
        if (secretAppKey != expectedSecretAppKey) {
            res.statusCode = 403;
            res.responseBody = Blob.valueOf('Forbidden: Invalid Secret App Key');
            return;
        }

        // Parse the request body
        String requestBody = req.requestBody.toString();
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(requestBody);

        // Extract parameters from the request body
        String email = (String) params.get('Email');
        String firstName = (String) params.get('firstName');
        String lastName = (String) params.get('lastName');
        String PhoneNumber = (String) params.get('Number');
        String AgeGroup = (String) params.get('Group');
        String city = (String) params.get('City');
        String occupation = (String) params.get('Occupation');
        String leadSource = (String) params.get('LeadSource');
        String comments = (String) params.get('Comments');
        String country = 'India';
        String state = 'Haryana';
        // String city = 'Panipat';
       

        if (String.isEmpty(lastName) || String.isEmpty(AgeGroup)){
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('Bad Request: Missing required fields');
            return;
        }

        try {
            Contact newContact = new Contact();
            newContact.Email = email;
            newContact.FirstName = firstName;
            newContact.LastName = lastName;
            newContact.Phone = PhoneNumber;
            newContact.phoneId__c = PhoneNumber;
            newContact.MobilePhone = PhoneNumber;
 			newContact.LeadSource = leadSource;
            if(city!= 'ONLINE'){
                newContact.City__c = city;
            }
            // newContact.City__c = city;
            newContact.States_UT__c = state;
            newContact.Country__c = country;
            //newContact.Occupation__c = occupation;
            newContact.Profession__c = occupation;
            newContact.Comments__c = comments;
            
            
            // Set Group related fields
            if (AgeGroup == 'Youth') {
                newContact.IYF__c = '5. All new entries for unmarried';
            } else if (AgeGroup == 'Congregation') {
                newContact.Congregation__c = '5. All new entries';
            }

          

            insert newContact;

            res.statusCode = 201;
            res.responseBody = Blob.valueOf('Contact created successfully');
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('Internal Server Error: ' + e.getMessage());
        }
    }
}