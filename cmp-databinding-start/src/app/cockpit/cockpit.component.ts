import { Component, ElementRef, EventEmitter, Output, ViewChild } from '@angular/core';

@Component({
  selector: 'app-cockpit',
  templateUrl: './cockpit.component.html',
  styleUrl: './cockpit.component.css'
})
export class CockpitComponent {
  @Output() serverCreated = new EventEmitter<{ 'serverName': string, 'serverContent': string }>();
  @Output('bpcreated') blueprintCreated = new EventEmitter<{ 'serverName': string, 'serverContent': string }>();

  // newServerName = 'asdf';


  // newServerContent = 'qwer';
@ViewChild('servercontInput',{static :true})serverconteleminput:ElementRef;

  onAddServer(myInput:HTMLInputElement) {
     this.serverCreated.emit({ "serverName": myInput.value, "serverContent": this.serverconteleminput.nativeElement.value })
  }

  onAddBlueprint(myInput:HTMLInputElement) {
    this.blueprintCreated.emit({ "serverName": myInput.value, "serverContent": this.serverconteleminput.nativeElement.value })
  }
}
