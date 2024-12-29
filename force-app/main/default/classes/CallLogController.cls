@RestResource(urlMapping='/CallLogEndpoint')
global class CallLogController {

    @HttpPost
    global static String handleCallLog() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            // Parse JSON body for call log details
            String requestBody = req.requestBody.toString();
            Map<String, Object> callLogDetails = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
			
            // Extract call log details
            Integer callDurationInSeconds = (Integer) callLogDetails.get('CallDurationInSeconds');
            String callType = (String) callLogDetails.get('CallType');
            String status = (String) callLogDetails.get('Status');
            String mobileNo = (String) callLogDetails.get('mobileNo'); // Lead or Contact ID
            String recordingFileBase64 = (String) callLogDetails.get('recordingFile');
            String userId = (String) callLogDetails.get('userId');
            
            Contact contact = [SELECT Id FROM Contact WHERE Phone ='+919999999999' LIMIT 1][0];
			
            res.statusCode = 201;
            return JSON.serialize(new Map<String, Object>{
                'message' => mobileNo
            });

 /*
            Contact contact = [SELECT Id FROM Contact WHERE Phone = :mobileNo LIMIT 1];
            
            // Create a Task record for call log
            Task callLog = new Task();
            callLog.Subject = CallType + ' : ' + status;
            callLog.Description = 'Logged';
            callLog.OwnerId = userId;
            callLog.Status = 'Completed';
            callLog.WhoId = contact.Id;
            callLog.Priority = 'Normal';
            callLog.ActivityDate = Date.today();
            callLog.Type = 'Call'; // Ensure Type is set to "Call"
            callLog.CallType = callType;
            callLog.CallDurationInSeconds = callDurationInSeconds;
            insert callLog;

            // Save the call recording file (if provided)
            if (req.headers.get('Content-Type') != null && req.headers.get('Content-Type').contains('multipart/form-data')) {
                // Create a ContentVersion record
                Blob recordingFileBlob = EncodingUtil.base64Decode(recordingFileBase64);
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.Title = 'Call Recording - ' + callLog.Id;
                contentVersion.PathOnClient = 'CallRecording.mp3'; // Update file extension based on the actual file type
                contentVersion.VersionData = recordingFileBlob;
                contentVersion.FirstPublishLocationId = callLog.Id;
                insert contentVersion;
            }

            // Return success response
            res.statusCode = 201;
            return JSON.serialize(new Map<String, Object>{
                'message' => 'Call log and recording saved successfully.',
                'taskId' => callLog.Id
            });
*/

        } catch (Exception e) {
            res.statusCode = 500;
            return JSON.serialize(new Map<String, Object>{
                'message' => 'An error occurred while saving the call log.',
                'error' => e.getMessage()
            });
        }
    }
}