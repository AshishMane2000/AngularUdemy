import { Component } from '@angular/core';

@Component({
  selector: 'app-assignment2',
  templateUrl: './assignment2.component.html',
 })
export class Assignment2Component {
  username:String=""
  disabledflag=true;

  usernameaction(){
    this.username.length>0?this.disabledflag=false:this.disabledflag=true;
  }
  resetnamefield(){
    this.username=""
  }
}
