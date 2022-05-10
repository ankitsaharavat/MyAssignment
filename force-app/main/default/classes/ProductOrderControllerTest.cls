@isTest
public with sharing class ProductOrderControllerTest {

    @TestSetup
    static void createTestData() {
        List<Product2> pList = TestDataFactory.createProducts(true, 2, 'SLA');
        List<PricebookEntry> pEntryList = TestDataFactory.createPricebookEntry(true , pList, System.Test.getStandardPricebookId());
        List<Account> accList = TestDataFactory.createAccounts(true, 1, 'TestName');
        Service_Endpoints__c se = TestDataFactory.createServiceCS(true, Util.PUSHPRODUCTS);
    }
    static testMethod void getProductListTest() {
        createTestData();
        System.Test.startTest();
        List<PricebookEntry> pricebookEntryList = ProductOrderController.getProductList();
        System.Test.stopTest();
        System.assertEquals(!pricebookEntryList.isEmpty(), true, 'PriceBookEntry list should not be empty');
    }

    static testMethod void insertOrderTest() {
        createTestData();
        System.Test.startTest();
        List<PricebookEntry> pricebookEntryList = [select id, Name, UnitPrice, ProductCode, Product2Id, PriceBook2Id from PricebookEntry];
        List<Map<String, Object>> thisOrderItems = new List<Map<String, Object>>();
        for (PricebookEntry pbe : pricebookEntryList) {
            thisOrderItems.add(new Map<String, Object>{
                'name' => pbe.Name, 
                'productCode' => pbe.ProductCode,
                'UnitPrice' => pbe.UnitPrice,
                'Quantity' => 2,
                'TotalPrice' => pbe.UnitPrice * 2,
                'PricebookEntryId' => pbe.Id,
                'Product2Id' => pbe.Product2Id
            });
        }
        system.debug('thisOrderItems===> '+JSON.serialize(thisOrderItems));

        // Set mock callout class 
        System.Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        ProductOrderController.STD_PRICEBOOK_ID = System.Test.getStandardPricebookId();
        String oId = ProductOrderController.insertOrder(JSON.serialize(thisOrderItems),null);
        System.assertEquals(!String.isEmpty(oId), true, 'Order Id should be return');
        String oIdExist = ProductOrderController.insertOrder(JSON.serialize(thisOrderItems),oId);
        System.assertEquals(!String.isEmpty(oIdExist), true, 'Order Id should be return');
        System.Test.stopTest();
        System.assertEquals(!pricebookEntryList.isEmpty(), true, 'PriceBookEntry list should not be empty');
        //System.assertEquals(!pricebookEntryList.isEmpty(), true, 'PriceBookEntry list should not be empty');
    }
}
