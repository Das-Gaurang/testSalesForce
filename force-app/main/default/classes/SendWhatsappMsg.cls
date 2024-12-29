global class SendWhatsappMsg implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.stateful{
    @InvocableMethod(callout=true label='Send Whatsapp Msg') 
    public static void excecuteSendWhatsappMsg(){
        Database.executeBatch(new SendWhatsappMsg(),100);
    }
    global Database.QueryLocator start (Database.BatchableContext BC){
        String query;
        try{
        	query = 'SELECT Id, firstname, lastname, phone, OtherPhone, Birthdate FROM Contact WHERE DAY_IN_MONTH(Birthdate) = ' + String.valueOf(Date.today().Day()) + ' AND CALENDAR_MONTH(Birthdate) =' + String.valueOf(Date.today().Month());
        }catch (Exception e){
			System.debug('<<----An Error Occur---->>');
		}
		return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> contactList){
        System.debug('contactList---->'+contactList);
        boolean is_contactList_empty = True;
        for(Contact con : contactList){
            if(con.Birthdate.Day() == Date.today().Day() && con.Birthdate.Month() == Date.today().Month()){
                String phone = con.Phone;
                IF(String.isempty(phone)){
                    phone = con.OtherPhone;
                }
                IF(String.isempty(phone)){
                    continue;
                }
                String name = con.firstname;
                IF(String.isempty(name)){
                	name = con.LastName;
                }
               Map<String,String> media = new Map<String,String>{
                   		'url' => 'https://aisensy-project-media-library.s3.ap-south-1.amazonaws.com/IMAGE/639c22906b33f95f6de35932/442769_birhtday.png',
                       'filename'=> 'GitaQuestBirthdayWishes.png'
                   };
               String media_str = JSON.serialize(media);
          	   String source_str = String.valueOf(Date.today()) + 'Birthday';
               String param_str = '["'+ name +'"]';
               SendWhatsappMsg.sendToAiSensy(phone, name, source_str, media_str, param_str, 'DailyBirthdayWish', 'gitaquest');
            }
        }
    }
    
    public static String sendToAiSensy(String phone, String name, String source_str, String media_str, String param_str, String campaignName, String domain){
        Map<String,String> apiKeyMap = new Map<String,String>{
            'gitaquest' => 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYzOWMyMjkwNmIzM2Y5NWY2ZGUzNTkzMiIsIm5hbWUiOiJHaXRhUXVlc3QiLCJhcHBOYW1lIjoiQWlTZW5zeSIsImNsaWVudElkIjoiNjM1YmJjN2U4YzYyYjM2MWJmMDVmMTIyIiwiYWN0aXZlUGxhbiI6Ik5PTkUiLCJpYXQiOjE2NzExNzY4NDh9.wP-p2q8sG9z2zukH6dmm56Lo5IgjMwCaJQCtMuN9trk',
            'iskcon' => 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYzNmY1YjYwNDIzOGY3MGViNjI1MTQ5NyIsIm5hbWUiOiJJU0tDT04gS3VydWtzaGV0cmEgNTc3NSIsImFwcE5hbWUiOiJBaVNlbnN5IiwiY2xpZW50SWQiOiI2MzZmNWI1ZjQyMzhmNzBlYjYyNTE0OTYiLCJhY3RpdmVQbGFuIjoiQkFTSUNfVFJJQUwiLCJpYXQiOjE2NjgyNDIyNzJ9.BWKUMv-ULqnUp6AH4LXQa0wOyDAaxazTTsFmjpH8K9Q'
        };
        String mybody = '{\n' +
                              ' "apiKey": "' + apiKeyMap.get(domain) +'",\n' + 
                              ' "campaignName": "' + campaignName + '",\n' +
                              ' "destination": "'+ phone +'" ,\n'  +
                              ' "userName": "' + name +'",\n' +
                              ' "source": "' + source_str + '",\n' +
                              ' "media": '+ media_str +',' +
                              ' "templateParams": ' + param_str + ',\n' +
                              '"tags": [],\n'+
                             ' "attributes": {}\n'+
                          '}';
            
            Http http = new Http();
        	HttpRequest request = new HttpRequest();
            request.setEndpoint('https://backend.aisensy.com/campaign/t1/api');
            System.debug('bd -- ' + mybody);
            request.setMethod('POST');
            request.setHeader('method','POST');
            request.setHeader('Content-Type','application/json');
            request.setBody(mybody);
            HttpResponse response = http.send(request);
            System.debug('response code--'+response.getStatusCode());
            System.debug('response body--'+response.getBody());
        	return response.getBody();
    }
    
    public static String sendToWati(String broadcast_name, String template_name, String receivers){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://live-server-8160.wati.io/api/v1/sendTemplateMessages');    
        string mybody= '{"template_name": "'+ template_name +'","broadcast_name": "'+ broadcast_name +'","receivers": ' + receivers + '}';
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiIyMmYyMTRmMC05OTEwLTRkZDgtYWJkMi01ZWZmNjdjODlkMmUiLCJ1bmlxdWVfbmFtZSI6Im1rdW1hckBnaXRhcXVlc3QuaW4iLCJuYW1laWQiOiJta3VtYXJAZ2l0YXF1ZXN0LmluIiwiZW1haWwiOiJta3VtYXJAZ2l0YXF1ZXN0LmluIiwiYXV0aF90aW1lIjoiMDQvMjAvMjAyMiAwOToxNjoyOSIsImRiX25hbWUiOiI4MTYwIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQURNSU5JU1RSQVRPUiIsImV4cCI6MjUzNDAyMzAwODAwLCJpc3MiOiJDbGFyZV9BSSIsImF1ZCI6IkNsYXJlX0FJIn0.RsExb8F_OmeSj8gJAOw-ikOxqkL7rIFs-NxVONLuK0g');
        request.setHeader('Content-Type','application/json');
        request.setBody(mybody);
        HttpResponse response = http.send(request);
        System.debug('response code--'+response.getStatusCode());
        System.debug('response body--'+response.getBody());
        return response.getBody();
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}