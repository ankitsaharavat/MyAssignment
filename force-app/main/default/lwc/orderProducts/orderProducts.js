import { LightningElement, track } from 'lwc';
import { APPLICATION_SCOPE, subscribe, createMessageContext } from 'lightning/messageService';
import productMC from "@salesforce/messageChannel/ProductMessageChannel__c";

const columns = [
    { label: 'Name', fieldName: 'name' },
    { label: 'Unit Price', fieldName: 'UnitPrice' },
    { label: 'Quantity', fieldName: 'Quantity' },
    { label: 'Total Price', fieldName: 'TotalPrice' },
];

export default class OrderProducts extends LightningElement {
    @track selectedProductData = [];
    @track productData = [];
    @track columns = columns;
    @track subscription = null;
    @track showPagination = false;

    // for pagination
    @track page = 1; //this will initialize 1st page
    @track items = []; //it contains all the records.
    @track data = []; //data to be displayed in the table
    @track startingRecord = 1; //start record position per page
    @track endingRecord = 0; //end record position per page
    @track pageSize = 5; //default value we are assigning
    @track totalRecountCount = 0; //total record count received from all retrieved records
    @track totalPage = 0; //total number of page is needed to display all records

    async connectedCallback() {
        //subscribe the LMS
        this.handleSubscribe();
    }

    context = createMessageContext();
    handleSubscribe(){
        if(this.subscription){
            return;
        }

        this.context = createMessageContext();
        this.subscription = subscribe(this.context, productMC, (message) => {
            this.handleMessage(message);
        }, { scope : APPLICATION_SCOPE  });
    }

    handleMessage(event){
        var rowMatched = false;
        var i;
        if(event){
            let receiveProducts = event.productsToSend;
            console.log('receiveProducts==>'+receiveProducts.name);
            for(i=0; i<this.selectedProductData.length; i++){
                if(this.selectedProductData[i].productCode === receiveProducts.productCode){
                    this.selectedProductData[i].Quantity += 1;
                    this.selectedProductData[i].TotalPrice = this.selectedProductData[i].Quantity * this.selectedProductData[i].UnitPrice;
                    rowMatched = true;
                    break;
                }
            }
            if(!rowMatched){
                this.selectedProductData.push(JSON.parse(JSON.stringify(receiveProducts)));
            }
            this.productData = [...this.selectedProductData];
            console.log( 'Value from Child 1 LWC is []' + JSON.stringify(this.productData) );

            //paginaions
            this.items = this.productData;
            this.totalRecountCount = this.productData.length;
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); //here it is 5
            
            //initial data to be displayed ----------->
            //slice will take 0th element and ends with 5, but it doesn't include 5th element
            //so 0 to 4th rows will be displayed in the table
            this.productData = this.items.slice(0,this.pageSize); 
            this.endingRecord = this.pageSize;
            this.columns = columns;
            this.error = undefined;
            if(this.productData.length > 0){
                this.showPagination = true;
            }
            // sending the products array to master/parent component
            this.dispatchEvent( new CustomEvent( 'pass', {
                detail: this.items
            } ) );
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

        /*let's say for 2nd page, it will be => "Displaying 6 to 10 of toal records.
        so, slice(5,10) will give 5th to 9th records.
        */
        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                            ? this.totalRecountCount : this.endingRecord; 
        this.productData = this.items.slice(this.startingRecord, this.endingRecord);
        //this.productData = this.data;
        //increment by 1 to display the startingRecord count
        this.startingRecord = this.startingRecord + 1;
    }
}