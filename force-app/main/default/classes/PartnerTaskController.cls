public with sharing class PartnerTaskController {
    
    // Method to get tasks assigned to the logged-in partner user
    @AuraEnabled
    public static List<Task> getTasksForLoggedInUser() {
        // Get the current logged-in user Id
        Id currentUserId = UserInfo.getUserId();
        
        // Query tasks assigned to the current user, respecting the sharing rules
        List<Task> userTasks = [
            SELECT Id, Subject, Status, Priority, ActivityDate, WhoId, WhatId
            FROM Task
            WHERE OwnerId = :currentUserId
            ORDER BY ActivityDate DESC
            LIMIT 50
        ];
        
        return userTasks;
    }
}