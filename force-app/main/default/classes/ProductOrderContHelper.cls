/*
*class name: ProductOrderContHelper
*created by: Ankit 5/6/2022
*description: sending the products to external system and setting the status as "Activated"
*/

public with sharing class ProductOrderContHelper {
    //constructor
    public ProductOrderContHelper() {

    }

    /*
    *method name: sendProductsToExtSystem
    *return type and param: void, accepting the orderid
    *created by: Ankit 5/5/2022
    *description: preparing the JSON of orders and it's items to sendout to  external system
    */
    public void sendProductsToExtSystem(String orderId){
        // Sending products data to external server
        ProductOrderContHelper.callout(orderId);
    }

    /*
    *method name: callout
    *return type and param: void, accepting the JSON of Order/items and orderid
    *created by: Ankit 5/5/2022
    *description: sending orders and it's items to  external system
    */
    @future(callout = true)
    public static void callout(String orderId){

        List<Order> orderResults = [
                SELECT Account.Name, OrderNumber, ActivatedDate, Type, Status,
                    (SELECT OrderItemNumber, Product2.Name, Product2.ProductCode, UnitPrice, Quantity
                        FROM OrderItems)
                FROM Order WHERE Id = :orderId
        ];

        //preparing the JSON
        List<Map<String, Object>> orders = new List<Map<String, Object>>();
        for (Order o : orderResults) {
            Map<String, Object> thisOrderMap = new Map<String, Object>();
            // construct the Map details
            thisOrderMap.put(Util.ACCOUNTNUMBER, o.Account.Name);
            thisOrderMap.put(Util.ORDERNUMBER, o.OrderNumber);
            thisOrderMap.put(Util.TYPE, o.Type);
            thisOrderMap.put(Util.STATUS, o.Status);

            List<Map<String, Object>> thisOrderItems = new List<Map<String, Object>>();
            for (OrderItem ol : o.OrderItems) {
                thisOrderItems.add(new Map<String, Object>{
                    Util.NAME => ol.Product2.Name, 
                    Util.CODE => ol.Product2.ProductCode,
                    Util.UNITPRICE_SMALL => ol.UnitPrice,
                    Util.QUANTITY_SMALL => Integer.ValueOf(ol.Quantity)
                });
            }
            thisOrderMap.put(Util.ORDERPRODUCTS, thisOrderItems);
            orders.add(thisOrderMap);
        }
        system.debug('orders==== > '+JSON.serialize(orders));

        HTTP h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        HTTPResponse res = new HttpResponse();
        String payload = '';
        if(orders != null){
            payload = JSON.serialize(orders);
        }
        try {
            Service_Endpoints__c serviceEndpoint = Service_Endpoints__c.getValues(Util.PUSHPRODUCTS);
            req.setHeader(Util.CONTENT_TYPE,Util.APPLICATION_JSON);
            req.setEndpoint(serviceEndpoint.Service_URL__c);
            req.setMethod(serviceEndpoint.Method__c);   
            req.setTimeout(Integer.valueOf(serviceEndpoint.Timeout__c)); // timeout in milliseconds
            req.setBody(payload);   
            res = h.send(req);
            system.debug('response Body==> ' + res.getBody() + ' StatusCode==> ' + res.getStatusCode());
            
            if(res.getStatusCode() == 200){
                ProductOrderContHelper.updateOrderStatus(orderId);
            }
            else{
                // Publishing the event to capture the response value and setting to false
                List<ProductOrderEvent__e> pEventList = new List<ProductOrderEvent__e>();
                ProductOrderEvent__e pEvent = new ProductOrderEvent__e();
                pEvent.isOrderSuccess__c = false;
                pEventList.add(pEvent);

                // Publish
                List<Database.SaveResult> results = Eventbus.publish(pEventList);

                HandlerException hExp = new HandlerException(null, null,req,res);
            }
        } catch (Exception ex) {
            HandlerException hExp = new HandlerException(ex, ex.getMessage(),req,res);
        }
        
    }

    /*
    *method name: updateOrderStatus
    *return type and param: void, accepting the orderid
    *created by: Ankit 5/5/2022
    *description: setting status to "Activated" of orders and it's items
    */
    public static void updateOrderStatus(String orderId){
        try {
            List<sObject> allObjects = new List<sObject>();
            List<OrderItem> oItemList = new List<OrderItem>();
            List<Order> orderResults = [
                    SELECT Id, Status, (SELECT Id, Status__c FROM OrderItems)
                    FROM Order WHERE Id = :orderId
            ];
            for (Order o : orderResults) {
                o.Status = Util.ACTIVATED;
                for (OrderItem ol : o.OrderItems) {
                    ol.Status__c = Util.ACTIVATED;
                    oItemList.add(ol);
                }
            }
            allObjects.addAll(orderResults);
            allObjects.addAll(oItemList);
            if(!allObjects.isEmpty()){
                update allObjects;
            }

            // Publishing the event to capture the success value
            List<ProductOrderEvent__e> pEventList = new List<ProductOrderEvent__e>();
            ProductOrderEvent__e pEvent = new ProductOrderEvent__e();
            pEvent.isOrderSuccess__c = true;
            pEventList.add(pEvent);

            // Publish
            List<Database.SaveResult> results = Eventbus.publish(pEventList);
        } 
        
        catch (Exception ex) {
            //Exception Handling
            HandlerException hExp = new HandlerException(ex, ex.getMessage(), null, null);
        }
    }
}