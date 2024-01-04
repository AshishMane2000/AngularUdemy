import { Component } from '@angular/core';

@Component({
  selector: 'app-servers',
  templateUrl:   'servers.component.html',
  styleUrl: './servers.component.css'
})
export class ServersComponent {
flag=true;
color="black";
name="ashish";
company="Accenture"
constructor(  ){
  setTimeout(() => {
    Math.random()>0.5?this.flag=true:this.flag=false;
     this.color="green"
    //  this.flag=false
  }, 2000);
}
changeColor(){
  this.color="yellow"
}
inputchanged(event :Event){
  this.name=(<HTMLInputElement>event.target).value;
}
}
