/*
*class name: HandlerException
*created by: Ankit 5/7/2022
*description: To handle the exceptions
*/

global with sharing class HandlerException extends Exception{

    global HandlerException(Exception ex, String displayMessage, HttpRequest req, HttpResponse res) {
        Error_Detail__c er = new Error_Detail__c();
        er.Error_Message__c = ex.getMessage();
        er.Stack_Trace__c = ex.getStackTraceString();
        er.Display_Message__c = displayMessage;
        er.Logged_User__c = UserInfo.getUserId();
        if(req != null){
            er.Request__c = req.getEndpoint();
            er.Request_Body__c = req.getBody();
        }
        if(res != null){
            er.Response_Code__c = res.getStatusCode();
            er.Response_Body__c = res.getBody();
        }

        insert er;
    }
}
