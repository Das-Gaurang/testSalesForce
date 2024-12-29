public class WatiBroadcast implements Queueable, Database.AllowsCallouts {
    private List<string> contactIdList;
    private string templateName;
    private string broadcastName;
    private Map<string, string> templateParams;
    private final Map<string, string> WATI_SALESFORCE_PARAM_MAP = new Map<String, String>{'contact__name' => 'firstName', 'contact__batch' => 'gq_batch__c', 'contact__coord_name' => ''};

    public WatiBroadcast(List<string> contactIdList, string templateName, Map<string, string> templateParams) {
        this.contactIdList = contactIdList;
        this.templateName = templateName;
        this.broadcastName = templateName + '_' + String.ValueOf(contactIdList.size()) + '_' + String.ValueOf(System.now());
        this.templateParams = templateParams;
    }
    public void execute(QueueableContext context) {
        List<Contact> contactList = [select id, FirstName, gq_batch__c, phone from contact Where Id IN :this.contactIdList];
        System.debug('contactList ----> '+ contactList);
        for(Contact con : contactList){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://live-server-8160.wati.io/api/v1/sendTemplateMessage?whatsappNumber='+con.phone);
            List<Map<string, string>> templateParamList = new List<Map<string, string>>();
            for (string key : this.templateParams.keySet()) {
                if(this.WATI_SALESFORCE_PARAM_MAP.containsKey(key)){
                    this.templateParams.put(key, String.valueOf(con.get(this.WATI_SALESFORCE_PARAM_MAP.get(key))));
                }
                templateParamList.add(new Map<string, string>{'name'=>key, 'value'=>this.templateParams.get(key)});
            }
            System.debug('template params -- ' + JSON.serialize(templateParamList));
            string mybody= '{"template_name": "' + this.templateName +'","broadcast_name": "' + this.broadcastName + '","parameters": ' + JSON.serialize(templateParamList) + '}';
            System.debug('bd -- ' + mybody);
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiIyMmYyMTRmMC05OTEwLTRkZDgtYWJkMi01ZWZmNjdjODlkMmUiLCJ1bmlxdWVfbmFtZSI6Im1rdW1hckBnaXRhcXVlc3QuaW4iLCJuYW1laWQiOiJta3VtYXJAZ2l0YXF1ZXN0LmluIiwiZW1haWwiOiJta3VtYXJAZ2l0YXF1ZXN0LmluIiwiYXV0aF90aW1lIjoiMDQvMjAvMjAyMiAwOToxNjoyOSIsImRiX25hbWUiOiI4MTYwIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQURNSU5JU1RSQVRPUiIsImV4cCI6MjUzNDAyMzAwODAwLCJpc3MiOiJDbGFyZV9BSSIsImF1ZCI6IkNsYXJlX0FJIn0.RsExb8F_OmeSj8gJAOw-ikOxqkL7rIFs-NxVONLuK0g');
            request.setHeader('Content-Type','application/json');
            request.setBody(mybody);
            HttpResponse response = http.send(request);
            System.debug('response code--'+response.getStatusCode());
            System.debug('response body--'+response.getBody());
        }  
    }
}