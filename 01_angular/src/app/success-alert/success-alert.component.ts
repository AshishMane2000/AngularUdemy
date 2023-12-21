import { Component } from '@angular/core';

@Component({
  // selector: 'app-success-alert',
  selector: '[success-alert]',

  // templateUrl: './success-alert.component.html',
  template: `<h2>success alert </h2>`,

  // styleUrl: './success-alert.component.css'
  styles: [`
  h2 {
    color:brown;
  }`]
})
export class SuccessAlertComponent {

}
