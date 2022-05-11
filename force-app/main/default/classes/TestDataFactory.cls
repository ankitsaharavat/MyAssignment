/*
*class name: TestDataFactory
*created by: Ankit 5/7/2022
*description: TestDataFactory class to create test data in test execution
*/

@isTest
public with sharing class TestDataFactory {
    /** 
    * ********************************************************
    * This method is test data to create Products
    * ********************************************************
    */
    public static List<Product2> createProducts(Boolean doInsert, Integer records, String name){
        List<Product2> productList = new List<Product2>();
        for(Integer i=0; i<records; i++){
            Product2 product = new Product2();
            product.Name = name + ' ' + i;
            product.IsActive = true;
            productList.add(product);
        }
        
        if(doInsert && !productList.isEmpty()){
            insert productList;
        }
        return productList;
    }

    /** 
    * ********************************************************
    * This method is test data to create PricebookEntry
    * ********************************************************
    */
    public static List<PricebookEntry> createPricebookEntry(Boolean doInsert, List<Product2> pList, String pricebookId){
        List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();
        for(Product2 p : pList){
            PricebookEntry pEntry = new PricebookEntry();
            pEntry.Pricebook2Id = pricebookId;
            pEntry.Product2id = p.Id;
            pEntry.UnitPrice = 1250.0;
            pEntry.isactive = true;
            pricebookEntryList.add(pEntry);
        }
        
        if(doInsert && !pricebookEntryList.isEmpty()){
            insert pricebookEntryList;
        }
        return pricebookEntryList;
    }

    /** 
    * ********************************************************
    * This method is test data to create Accounts
    * ********************************************************
    */
    public static List<Account> createAccounts(Boolean doInsert, Integer records, String name){
        List<Account> accList = new List<Account>();
        for(Integer i=0; i<records; i++){
            Account a = new Account();
            a.Name = name + ' ' + i;
            accList.add(a);
        }
        
        if(doInsert && !accList.isEmpty()){
            insert accList;
        }
        return accList;
    }

    /** 
    * ********************************************************
    * This method is test data to create Service_Endpoints__c
    * ********************************************************
    */
    public static Service_Endpoints__c createServiceCS(Boolean doInsert, String name){
        Service_Endpoints__c se = new Service_Endpoints__c();
        se.Name = name;
        se.Service_URL__c = 'https://test.com';
        se.Method__c = 'POST';
        se.Timeout__c = 3000;
        insert se;
        return se;
    }
}

