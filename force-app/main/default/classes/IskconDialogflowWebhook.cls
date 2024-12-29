@RestResource(urlMapping='/iskcon/dialogflow/webhook')
global with sharing class IskconDialogflowWebhook {

    @HttpPost
    global static void handleWebhook() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
		System.debug('Received request: ' + req.requestBody.toString());
        try {
            String providedToken = req.headers.get('authorization-token');
            String expectedToken = 'sp7XodruHar47Rod8er'; // Replace with your actual expected token
            
            if (providedToken != expectedToken) {
                RestContext.response.statusCode = 401;
                RestContext.response.responseBody = Blob.valueOf('{"error": "Unauthorized"}');
                return;
            }
            
            // Parse the request JSON
            String requestBody = req.requestBody.toString();
            Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            
            String session  = (String) requestMap.get('session');
            String[] sessionParts = session.split('/');
			String projectId = sessionParts[1];
			String sessionId = sessionParts[4];
            // Extract the necessary data from the request
            Map<String, Object> queryResult = (Map<String, Object>) requestMap.get('queryResult');
            Map<String, Object> intent = (Map<String, Object>) queryResult.get('intent');
            String intentName = (String) intent.get('displayName');
            List<object> outputContexts = (List<object>) queryResult.get('outputContexts');
            Map<String, Object> parameters = new Map<String, Object>();
            for(Object outputContextObj : outputContexts){
                Map<String, Object> outputContext = (Map<String, Object>) outputContextObj;
                String contextName = (String) outputContext.get('name');
                if(contextName.contains('contexts/tour-group-id')){
                    parameters = (Map<String, Object>) outputContext.get('parameters');
                    Map<String, Object> nameParam = (Map<String, Object>) parameters.get('name');
                    parameters.put('name', (String) nameParam.get('name'));
                    break;
                }
            }
            // Process the request based on the intent name
            String responseMessage;
            if (intentName == 'Mobile Number Confirm #7') {
                // Handle your specific intent
                String tourGroupId = (String) parameters.get('TourGroupID');
                String phone = (String) parameters.get('phone');
                phone = '+' + phone;
                String name = (String) parameters.get('name');
                responseMessage = 'Received parameter: ' + tourGroupId;
                String url = 'https://script.google.com/macros/s/AKfycbzWdXp0OMeJV36MK3_U_MrFVhFTUshQ_6_3m71iL3t2CF1UHrCZy6PxmfuoYncO6xjbCw/exec';
               
        		String photoLink = null;
                // Set up the HTTP request
                HttpRequest photReq = new HttpRequest();
                photReq.setEndpoint(url);
                photReq.setMethod('POST');
                
                // Create the request body
                Map<String, String> photRequestBody = new Map<String, String>();
                photRequestBody.put('tourGroupId', tourGroupId);
                photRequestBody.put('token', 'saflnasl!hfl3q@i4$ql3nflaen');
                photRequestBody.put('name', (String) parameters.get('name'));
                photRequestBody.put('OverallRating', (String) parameters.get('OverallRating'));
                photRequestBody.put('FoodRating', (String) parameters.get('FoodRating'));
                photRequestBody.put('TourGuideRating', (String) parameters.get('TourGuideRating'));
                photRequestBody.put('phone', phone);
                photRequestBody.put('feedback', (String) parameters.get('Feedback'));
                photRequestBody.put('sessionId', sessionId);
                String logfeedback = (String) parameters.get('Feedback');
                // Serialize the request body to JSON
                String requestBodyJson = JSON.serialize(photRequestBody);
                photReq.setBody(requestBodyJson);
                photReq.setHeader('Content-Type', 'application/json');
                
                Http http = new Http();
                HttpResponse photoRes = http.send(photReq);
                Integer statusCode = photoRes.getStatusCode();
                if (statusCode == 301 || statusCode == 302) {
                    HttpRequest redirectReq = new HttpRequest();
                    redirectReq.setEndpoint(photoRes.getHeader('Location'));
                    redirectReq.setMethod('GET');
   					photoRes = http.send(redirectReq);
                }
                statusCode = photoRes.getStatusCode();
                if (statusCode == 200) {
                    // Parse the JSON response
                    Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(photoRes.getBody());
                    if (response.get('status') == 'Success') {
                        photoLink = (String) response.get('photoLink');
                    } else {
                        // Handle error messages
                        System.debug('Error: ' + response.get('message'));
                    }
                } else {
                    // Handle HTTP error
                    System.debug('HTTP Error: ' + photoRes.getStatusCode());
                }
                
            
                if(! String.isBlank(photoLink)){
                    IskconDialogflowWebhook.sendPhoto(photoLink, phone, name);
                }
            }
            else {
                    responseMessage = 'Unknown intent: ' + intentName;
           	}

            // Create the response
            Map<String, Object> responseMap = new Map<String, Object>();
            Map<String, String> fulfillmentText = new Map<String, String>();
            fulfillmentText.put('fulfillmentText', responseMessage);
            responseMap.put('fulfillmentMessages', new List<Map<String, String>>{fulfillmentText});

            // Send the response
            res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            res.statusCode = 200;

        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('{"error": "' + e.getMessage() + '"}');
        }
    }
    
    public static void sendPhoto(String photoLink, String phone, String name){
        Map<String,String> media = new Map<String,String>{
            'url' => photoLink,
                'filename'=> 'KurukshetraTourismGiftPhoto.png'
                };
        String media_str = JSON.serialize(media);
        String source_str = 'KurukshetraTourismFeedbackForm';
        String param_str = '[]';
        SendWhatsappMsg.sendToAiSensy(phone, name, source_str, media_str, param_str, 'sendKTPhotoRus', 'iskcon');
    }
}