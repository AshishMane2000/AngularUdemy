import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent {
  title = '03_angular';
  name:string="The name is John Doe";
  description:string="Class is a user defined datatype which binds data member ,member function  into a single unit";

   servers: object[] = [
     ]

  addserver() {
     this.servers.push(new Object({"servername": this.name, "serverdescription": this. description ,type:"server" }))
     console.log(this.servers)
     
  }
  addblueprint() {
    this.servers.push(new Object({"servername": this. name, "serverdescription": this. description,type:"blueprint" }))
  }
}
