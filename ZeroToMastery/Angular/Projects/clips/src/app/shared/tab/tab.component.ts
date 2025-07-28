import { Component, input, signal } from '@angular/core';

@Component({
  standalone: true,
  selector: 'app-tab',
  imports: [],
  templateUrl: './tab.component.html',
  styleUrl: './tab.component.scss'
})
export class TabComponent {
  tabTitle = input<string>('');
  active = signal(false);

}
