import { Component, contentChildren, AfterContentInit } from '@angular/core';
import { NgClass } from '@angular/common';
import { TabComponent } from '../tab/tab.component';

@Component({
  standalone: true,
  selector: 'app-tabs-container',
  imports: [NgClass],
  templateUrl: './tabs-container.component.html',
  styleUrl: './tabs-container.component.scss'
})
export class TabsContainerComponent implements AfterContentInit {
  tabs = contentChildren(TabComponent);

  ngAfterContentInit() {
    const activeTabs = this.tabs().find(tab => tab.active());
    if (!activeTabs) {
      this.selectTab(this.tabs()[0]);
    }
  }

  selectTab(tab: TabComponent) {
    this.tabs().forEach(t => t.active.set(false));
    tab.active.set(true);
    return false;
  }
} 
