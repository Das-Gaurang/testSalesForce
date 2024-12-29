@RestResource(urlMapping='/isbirthday')
global class ExotelBirthdayCheck {
    @HttpGet
    global static void doGet() {
        String CallFrom = RestContext.request.params.get('CallFrom');
        RestResponse res = RestContext.response;
        if(String.isEmpty(CallFrom)){
            res.statusCode = 404;
            return;
        }
        String ph_no = '%' + String.valueOf(Integer.valueOf(RestContext.request.params.get('CallFrom')));
        System.debug('exotel ph no -- ' + ph_no);
        Integer curr_month = Date.today().Month();
        Integer curr_day = Date.today().Day();
        List<Contact> birthdayIds = [select id from Contact where phone like :ph_no and 
                                     DAY_IN_MONTH(Birthdate) = :curr_day AND CALENDAR_MONTH(Birthdate) = :curr_month
                                     limit 1];
        if(birthdayIds.isEmpty()){
            res.statusCode = 404;
        }else{
            res.statusCode = 200;
        }
    }
}