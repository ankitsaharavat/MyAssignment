/*
*class name: ProductOrderController
*created by: Ankit 5/7/2022
*description: To return the products and inserting the orders and it's items
*/

public with sharing class ProductOrderController {
    // To store the standard PriceBook2Id
    public static String STD_PRICEBOOK_ID; 

    /*
    *method name: getProductList
    *return type: List<PricebookEntry>
    *created by: Ankit 5/7/2022
    *description: To return the products to LWC on pageload
    */
    @AuraEnabled(cacheable=true)
    public static List<PricebookEntry> getProductList() {
        if(System.Test.isRunningTest()){
            STD_PRICEBOOK_ID = System.Test.getStandardPricebookId();
        }
        else{
            Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
            STD_PRICEBOOK_ID = standardPB.Id;
        }
        return [select id, Name, UnitPrice, ProductCode, Product2Id, PriceBook2Id
             from PricebookEntry where Pricebook2Id = :STD_PRICEBOOK_ID order by Name];
    }

    /*
    *method name: insertOrder
    *return type and param: string, accepting the selected products in JSON format
    *created by: Ankit 5/7/2022
    *description: Inserting the orders and it's items
    */
    @AuraEnabled
    public static String insertOrder(String productJSON, String existingOrderId){
        system.debug('existingOrderId==> '+existingOrderId);
        try {
            //checking existing order id if available else inserting new orde+/items
            if(String.isEmpty(existingOrderId)){
                system.debug('productJSON==> ' + productJSON);
                //Getting one Account, since account is needed to insert an order.
                Account acc = [Select Id from Account limit 1];
                Order order = new Order(
                    AccountId = acc.Id,
                    EffectiveDate = System.today(),
                    Status = Util.Draft,
                    PriceBook2Id = STD_PRICEBOOK_ID,
                    Type = Util.NewVal
                );
                insert order;

                List<OrderItem> orderItemList = new List<OrderItem>();
                List<Object> items = (List<Object>) JSON.deserializeUntyped(productJSON);
                for (Object itemObj : items) {
                    Map<String, Object> item = (Map<String, Object>) itemObj;
                    OrderItem lineItem = new OrderItem();
                    lineItem.OrderId = order.id;
                    lineItem.Quantity = Integer.valueOf(item.get(Util.Quantity));
                    lineItem.UnitPrice = Integer.valueOf(item.get(Util.UnitPrice));
                    lineItem.Product2id = String.valueOf(item.get(Util.Product2Id));
                    lineItem.PricebookEntryId = String.valueOf(item.get(Util.PricebookEntryId));
                    orderItemList.add(lineItem);
                }

                system.debug('orderItemList ==> ' + orderItemList);
                if(!orderItemList.isEmpty()){
                    insert orderItemList;
                }
                
                //Sending products to external system
                ProductOrderContHelper objHelper = new ProductOrderContHelper();
                objHelper.sendProductsToExtSystem(order.Id);
                return order.Id;
            }
            else{
                //Sending products to external system
                ProductOrderContHelper objHelper = new ProductOrderContHelper();
                //sending existing order id if available 
                objHelper.sendProductsToExtSystem(existingOrderId);
                return existingOrderId;
            }       
        } catch (Exception exp) {
            //Excepting Handling
            HandlerException hExp = new HandlerException(exp, exp.getMessage(), null, null);
            return null;
        }
    }
    
}
