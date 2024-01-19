import { Component,Input, ViewEncapsulation } from '@angular/core';

@Component({
  selector: 'app-server-element',
  templateUrl: './server-element.component.html',
  styleUrl: './server-element.component.css',
  encapsulation:ViewEncapsulation.None
})
export class ServerElementComponent {

  @Input() element: { type: string, name: string, content: string }
}
