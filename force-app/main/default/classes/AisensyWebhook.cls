@RestResource(urlMapping='/aisensy/webhook')
global class AisensyWebhook {

    @HttpPost
    global static void handleWebhook() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
		System.debug('Received request: ' + req.requestBody.toString());
        try {
            String providedToken = req.headers.get('authorization-token');
            String expectedToken = 'sp7XodruHar47Rod8erreqq'; // Replace with your actual expected token
            
            if (providedToken != expectedToken) {
                RestContext.response.statusCode = 401;
                RestContext.response.responseBody = Blob.valueOf('{"error": "Unauthorized"}');
                return;
            }
            
            // Parse the request JSON
            String requestBody = req.requestBody.toString();
            System.debug('HTTP Error: ' + requestBody);
            Map<String, object> requestMap = (Map<String, object>) JSON.deserializeUntyped(requestBody);
            
            String name  = (String) requestMap.get('name');
            String phone  = '+' + (String) requestMap.get('phone');
            String tourGroupId = (String) requestMap.get('TourGroupId');
            String OverallRating = (String) requestMap.get('OverallRating');
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
            photRequestBody.put('name', name);
            photRequestBody.put('OverallRating', OverallRating);
            photRequestBody.put('phone', phone);
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
            res.statusCode = 200;

        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('{"error": "' + e.getMessage() + '"}');
        }
    }

}