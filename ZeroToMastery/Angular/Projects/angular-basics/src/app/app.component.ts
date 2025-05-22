import { Component, signal } from "@angular/core";

@Component({
  selector:'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss'],
})
export class AppComponent {
  name = signal('Justin');
  imageURL = signal('https://wallpapers.com/images/hd/darth-vader-pictures-qwlyfdkmyjirchwo.jpg');

  getName() {
    return this.name();
  }
}