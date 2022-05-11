import { LightningElement, track } from 'lwc';
import insertOrder from '@salesforce/apex/ProductOrderController.insertOrder';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {
    subscribe,
    onError
} from 'lightning/empApi';

export default class MasterOrderTemplate extends LightningElement {
    channelName = '/event/ProductOrderEvent__e';
    @track selectedProducts = [];
    @track disableOrderButton = false;
    @track isLoaded = false;
    orderId = '';

    // Initializes the component
    connectedCallback() {
        // Register error listener
        this.handleSubscribe();
        // Register error listener
        this.registerErrorListener();
    }

    // Handles subscribe button click
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const messageCallback =  (response) => {
            console.log('New message received: ', JSON.stringify(response));
            if(response.data.payload.isOrderSuccess__c){
                this.disabledButtons();
                this.isLoaded = false;
                const toastEvent = new ShowToastEvent({
                    title:'Success!',
                    message:'Order submitted successfully',
                    variant:'success'
                });
                this.dispatchEvent(toastEvent);
            }
            else{
                const toastEvent = new ShowToastEvent({
                    title:'Some unexpected error!',
                    message:'Connection failed!! please try again later',
                    variant:'error'
                });
                this.dispatchEvent(toastEvent);
                this.isLoaded = false;
            }
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then((response) => {
            // Response contains the subscription information on subscribe call
            console.log(
                'Subscription request sent to: ',
                JSON.stringify(response.channel)
            );
        });
    }

    registerErrorListener() {
        // Invoke onError empApi method
        onError((error) => {
            // Error contains the server-side error
            const toastEvent = new ShowToastEvent({
                title:'Some unexpected error!',
                message: error,
                variant:'error'
            });
            this.dispatchEvent(toastEvent);
            this.isLoaded = false;
        });
    }

    getValueFromChild( event ) {
        //console.log( 'Value from Child2 LWC is ' + JSON.stringify(event.detail) );
        this.selectedProducts = event.detail;
    }

    handleClick(){
        this.isLoaded = true;
        insertOrder({productJSON : JSON.stringify(this.selectedProducts),
            existingOrderId: this.orderId})
        .then(result=>{
            if(result !== undefined){
                this.orderId = result;
            }
        })
        .catch(error=>{
           window.console.log(error.message);
           const toastEvent = new ShowToastEvent({
                title:'Some unexpected error!',
                message:'Connection failed!! please try again later',
                variant:'error'
            });
            this.dispatchEvent(toastEvent);
            this.isLoaded = false;
        });
    }

    disabledButtons(){
        this.disableOrderButton = true;
        const objChild = this.template.querySelector('c-product-template');
        objChild.disableButton();
    }

}