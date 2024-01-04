import { Component } from '@angular/core';

@Component({
  selector: 'app-assignment3',
  templateUrl: './assignment3.component.html',
  styleUrl: './assignment3.component.css'
})
export class Assignment3Component {
  counter=0;

  showpara=false;
  
  clicksarray=[];

  toggleshowpara(){
    this.showpara=!this.showpara;
    this.clicksarray.push(++this.counter);
  }
  getcolor(item:number){
    return item>4?"blue":"";
  }

  getfontcolor(item:number){
    return item>4?"white":"";
  }
}
