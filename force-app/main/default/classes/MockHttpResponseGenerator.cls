/*
*class name: MockHttpResponseGenerator
*created by: Ankit 5/7/2022
*description: To set the mock response in test execution
*/

@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        System.assertEquals(Util.POST, req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader(Util.CONTENT_TYPE, Util.APPLICATION_JSON);
        res.setBody(Util.MOCKBODY);
        res.setStatusCode(200);
        return res;
    }
}