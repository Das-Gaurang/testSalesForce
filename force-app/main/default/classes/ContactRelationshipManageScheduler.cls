global class ContactRelationshipManageScheduler implements Schedulable {
	global void execute(SchedulableContext SC) {
      ContactRelationshipManager.establishDummyContactRelationships(); 
   }
}