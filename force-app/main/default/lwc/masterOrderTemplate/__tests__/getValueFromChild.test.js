import {createElement} from 'lwc';
import MasterOrderTemplate from 'c/masterOrderTemplate'
//import { sum } from '../sum';
    
describe('c-master-order-template test suite', () => {
  test('check handleClick', () => {
    const element = createElement('c-master-order-template', {
        is: MasterOrderTemplate
    })
    document.body.appendChild(element);
  });
});