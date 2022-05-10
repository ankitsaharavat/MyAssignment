import { LightningElement } from 'lwc';

export default class ProductPagination extends LightningElement {
    previousHandler() {
        this.dispatchEvent(new CustomEvent('previous'));
        console.log('in previous');
    }

    nextHandler() {
        this.dispatchEvent(new CustomEvent('next'));
        console.log('in next');
    }
}