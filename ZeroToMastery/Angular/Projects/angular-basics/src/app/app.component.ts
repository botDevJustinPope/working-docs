import { Component, signal } from "@angular/core";
import { PostComponent } from "./post/post.component";

@Component({
  selector:'app-root',
  standalone: true,
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss'],
  imports: [PostComponent],
})
export class AppComponent {
  name = signal('Justin');
  imageURL = signal('https://wallpapers.com/images/hd/darth-vader-pictures-qwlyfdkmyjirchwo.jpg');

  getName() {
    return this.name();
  }

  changeImage(e: KeyboardEvent) {
    this.imageURL.set((e.target as HTMLInputElement).value);
  }
}