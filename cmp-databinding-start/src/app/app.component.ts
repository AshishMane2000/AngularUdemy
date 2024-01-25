import { Component, SimpleChanges, ViewEncapsulation } from '@angular/core';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
  // encapsulation:ViewEncapsulation.None
})
export class AppComponent {
  serverElements = [{ type: "server", name: "server1", content: 'this is a test !' }];

  onServerAdded(serverData: { 'serverName': string, 'serverContent': string }) {
    //this parameter should match the defination of emmiter in cockpit component
     this.serverElements.push({ type: "server", name: serverData.serverName, content: serverData.serverContent })

   }

  onBlueprintAdded(serverData: { 'serverName': string, 'serverContent': string }) {
    this.serverElements.push({ type: "blueprint", name: serverData.serverName, content: serverData.serverContent })
  }
  ngOnChanges(changes:SimpleChanges) {
    console.log(" ngOnChanges ...")
    console.log(changes)
  }
  ngOnInit() {
    console.log(" ngOnInit  ...")
  }
  ngDoCheck() {
    console.log("  ngDoCheck  ... ")
  }
  ngAfterContentInit() {
    console.log(" ngAfterContentInit...")
  }
  ngAfterContentChecked() {
    console.log(" ngAfterContentChecked...")
  }
  ngAfterViewInit() {
    console.log(" ngAfterViewInit  ... ")
  }
  ngAfterViewChecked() {
    console.log(" ngAfterViewChecked ...")
  }
  ngOnDestroy() {
    console.log(" ngOnDestroy ...")
  }
}
