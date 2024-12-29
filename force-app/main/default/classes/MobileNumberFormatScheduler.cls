global class MobileNumberFormatScheduler implements Schedulable {
   global void execute(SchedulableContext SC) {
      MobileNumberFormatter.formatMobileNumbers(); 
   }
}