import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent {
  title = '03_angular';

   servers: object[] = [
     ]

  addserver() {
    this.servers.push(new Object({"servername": "s", "serverdescription": "this is server  " ,type:"server" }))
    console.log(this.servers);
    
  }
  addblueprint() {
    this.servers.push(new Object({"servername": "b", "serverdescription": "this is blueprint  " ,type:"blueprint" }))
  }
}
