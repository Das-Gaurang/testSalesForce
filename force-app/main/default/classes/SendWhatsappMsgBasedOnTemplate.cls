public class SendWhatsappMsgBasedOnTemplate {
    @AuraEnabled
    public static String getTemplateList(){      
        List<String> templateList = new List<String>();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://live-server-8160.wati.io/api/v1/getMessageTemplates');
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiIyMmYyMTRmMC05OTEwLTRkZDgtYWJkMi01ZWZmNjdjODlkMmUiLCJ1bmlxdWVfbmFtZSI6Im1rdW1hckBnaXRhcXVlc3QuaW4iLCJuYW1laWQiOiJta3VtYXJAZ2l0YXF1ZXN0LmluIiwiZW1haWwiOiJta3VtYXJAZ2l0YXF1ZXN0LmluIiwiYXV0aF90aW1lIjoiMDQvMjAvMjAyMiAwOToxNjoyOSIsImRiX25hbWUiOiI4MTYwIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQURNSU5JU1RSQVRPUiIsImV4cCI6MjUzNDAyMzAwODAwLCJpc3MiOiJDbGFyZV9BSSIsImF1ZCI6IkNsYXJlX0FJIn0.RsExb8F_OmeSj8gJAOw-ikOxqkL7rIFs-NxVONLuK0g');
        request.setHeader('Content-Type','application/json');
        HttpResponse response = http.send(request);
        return response.getBody();
    }
    
    
    @AuraEnabled
    public static void sendWhatsapp(String listViewId, String templateName, String constParamKeys, String constParamVals, String paramKeys){
        	System.debug('listViewId'+ listViewId +'constantParam -- '+ constParamKeys + ' -- ' + constParamVals + ' == ' + paramKeys);
            if(constParamVals == null){
                constParamVals = '';
            }
            String sessionId = SendWhatsappMsgBasedOnTemplate.getSessionId();
            IF(String.isNotBlank(sessionId)){
                List<string> contactIdList = SendWhatsappMsgBasedOnTemplate.getListViewIds(listViewId, sessionId, 'Contact');
                System.debug('contactIdList ----> '+ contactIdList);
                
                List<string> constParamKeyList = constParamKeys.split('\\|\\|');
                List<string> constParamValList = constParamVals.split('\\|\\|');
                System.debug('constParamKeyList ----> '+ constParamKeyList);
                System.debug('constParamValList ----> '+ constParamValList);
                Map<string, string> templateParams = new Map<string, string>();
                for (Integer i = 0; i < constParamValList.size(); i++) {
                    templateParams.put(constParamKeyList[i], constParamValList[i]);
                }
                List<string> ParamKeyList = paramKeys.split('\\|\\|');
                System.debug('ParamKeyList ----> '+ ParamKeyList);
                for (Integer i = 0; i < ParamKeyList.size(); i++) {
                    if(!templateParams.containsKey(ParamKeyList[i])){
                        System.debug('templateParam ----> '+ ParamKeyList[i]);
                        templateParams.put(ParamKeyList[i], 'xyz');
                    }
                }
				System.debug('templateParams ----> '+ templateParams);                
                System.enqueueJob(new WatiBroadcast(contactIdList, templateName, templateParams));
            }
    }
    
    @AuraEnabled
    public static String getSessionId(){
        String clientId = System.label.ClientId;
        String clientSecret = System.label.ClientSecret;
        String securityToken = System.label.SecurityToken;
        String username = System.label.Username;
        String password = System.label.PassSecTok;
        String requestBody = 'grant_type=password&client_id='+clientId+'&client_secret='+clientSecret
            +'&username='+username+'&password='+password;
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        String endPointUrl = System.label.OrgEndPoint;
        httpReq.SetEndPoint(endPointUrl+'oauth2/token');
        httpReq.SetHeader('Content-Type','application/x-www-form-urlencoded');
        //httpReq.setTimeout(12000);
        httpReq.setMethod('POST');
        httpReq.setBody(requestBody);
        
        httpRes = new http().send(httpReq);
        System.debug('#### responseBody '+httpRes.getBody());
        System.debug('#### responseBody '+httpRes.getStatusCode());
        IF(httpRes.getStatusCode() == 200 ){
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());
            return (String)responseMap.get('access_token');
        }ELSE{
            return '';
        }
    }
    
    @AuraEnabled
    public static List<string> getListViewIds(String listViewId, String SessionId, String obj_name){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String endPointUrl = System.label.OrgEndPoint;
        request.setEndpoint(endPointUrl+'data/v55.0/sobjects/' + obj_name + '/listviews/'+listViewId+'/results');
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + sessionId);
        HttpResponse response = http.send(request);
        System.debug('response code--'+response.getStatusCode());
        System.debug('response body--'+response.getBody());
        JSON2Apex obj = JSON2Apex.parse(response.getBody());
        System.debug('JSON obj ----> '+ obj.records[0].columns);
        List<string> IdList = new List<String>();
        for(JSON2Apex.Records rec: obj.records){
            for(JSON2Apex.Columns_Z col: rec.columns){
                if(col.fieldNameOrPath == 'Id'){
                    IdList.add(col.value);
                }
            }
        }
        return IdList;
    }
    
}