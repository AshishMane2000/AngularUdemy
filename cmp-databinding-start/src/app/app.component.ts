import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  serverElements = [{type:"server",name:"server1",content:'this is a test !'}];
 
  onServerAdded(event:Event){
    console.log(event);
  }
 
}
