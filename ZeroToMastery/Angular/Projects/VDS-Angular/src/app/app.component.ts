import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { PackagesComponent } from './components/packages/packages.component';

@Component({
  selector: 'app-root',
  imports: [PackagesComponent, RouterOutlet],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss'
})
export class AppComponent {
  title = 'VDS-Angular';
}
