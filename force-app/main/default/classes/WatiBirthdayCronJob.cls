global class WatiBirthdayCronJob implements Schedulable{    
     //mandatory function called by the Apex Scheduler  
     global void execute(SchedulableContext SC) {
       SendWhatsappMsg.excecuteSendWhatsappMsg();  
     }
}