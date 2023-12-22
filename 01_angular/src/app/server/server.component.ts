import { Component } from '@angular/core';

@Component({
  // selector: 'app-server',
  
  // selector: '[app-server]',

  selector: '.app-serverxx',

  templateUrl: './server.component.html',
  // styleUrl: './server.component.css'
  styles:[`
    h4{
      color:red ;
    }
  `]
})
export class ServerComponent {
  id :number=1;
  port:number=5500;
  status="ok"
  getStartupTime(){
    return 11;
  }
}
