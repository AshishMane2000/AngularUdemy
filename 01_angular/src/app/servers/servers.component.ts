import { Component } from '@angular/core';

@Component({
  selector: 'app-servers',
  templateUrl:   'servers.component.html',
  styleUrl: './servers.component.css'
})
export class ServersComponent {
flag=true;
color="black";
constructor(  ){
  setTimeout(() => {
    this.flag=false;
    this.color="green"
  }, 2000);
}
}
