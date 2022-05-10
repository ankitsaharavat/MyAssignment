import { LightningElement, track, api, wire } from 'lwc';
import getProductList from '@salesforce/apex/ProductOrderController.getProductList'; 
import { publish, MessageContext } from 'lightning/messageService';
import productMC from "@salesforce/messageChannel/ProductMessageChannel__c"; 

export default class ProductTemplate extends LightningElement {
    disableButtons = false;
    //holds column info.
    get columns(){
        return [
            { label: 'Name', fieldName: 'Name' },
            { label: 'UnitPrice', fieldName: 'UnitPrice' },
            { type: "button", initialWidth: 60, typeAttributes: {  
                label: '+',  
                name: '+',  
                title: 'Add',  
                disabled: this.disableButtons,  
                value: '+',  
                iconPosition: 'left'
                },
                cellAttributes: { class: 'slds-p-vertical_none slds-m-vertical_none' }
            } 
        ];
    }
    @track productData = [];umns;
    @track disa = true;
    @wire(MessageContext)
            messageContext;

    // for paginations
    @track page = 1; //this will initialize 1st page
    @track items = []; //it contains all the records.
    @track data = []; //data to be displayed in the table
    @track startingRecord = 1; //start record position per page
    @track endingRecord = 0; //end record position per page
    @track pageSize = 5; //default value we are assigning
    @track totalRecountCount = 0; //total record count received from all retrieved records
    @track totalPage = 0; //total number of page is needed to display all records

    @api
    disableButton() {
        this.disableButtons = true;
    }

    @wire(getProductList)
    wiredProductss({ error, data }) {
        if (data) {
            this.items = data;
            this.totalRecountCount = data.length;
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
            
            //initial data to be displayed ----------->
            //slice will take 0th element and ends with 5
            //so 0 to 4th rows will be displayed in the data table
            this.productData = this.items.slice(0,this.pageSize); 
            this.endingRecord = this.pageSize;
            this.error = undefined;
        } 
        else if (error) {
            this.error = error;
            this.data = undefined;
        }
    }

    //clicking on previous button this method will be called
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    //clicking on next button this method will be called
    nextHandler() {
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);            
        }             
    }

    //this method displays records page by page
    displayRecordPerPage(page){

        /*let's say for 2nd page, it will be => "Displaying 6 to 10 of total records.
        so, slice(5,10) will give 5th to 9th records.
        */
        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                            ? this.totalRecountCount : this.endingRecord; 

        this.productData = this.items.slice(this.startingRecord, this.endingRecord);
        //increment by 1 to display the startingRecord count
        this.startingRecord = this.startingRecord + 1;
    }  

    handleRowAction(event) {
        var myProduct = {"name": event.detail.row.Name, 
                        "productCode": event.detail.row.ProductCode,
                        "UnitPrice": event.detail.row.UnitPrice, 
                        "Quantity": 1, 
                        "TotalPrice": event.detail.row.UnitPrice,
                        "PricebookEntryId" : event.detail.row.Id,
                        "Product2Id" : event.detail.row.Product2Id,
                        "Pricebook2Id" : event.detail.row.Pricebook2Id};

        let products = {productsToSend: myProduct};
        // Publishing the LMS to send this product to 2nd component
        publish(this.messageContext, productMC, products);
    }
}