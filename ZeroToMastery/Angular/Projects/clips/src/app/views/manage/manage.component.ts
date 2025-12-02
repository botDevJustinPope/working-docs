import { Component, inject, OnInit, signal, WritableSignal } from '@angular/core';
import { RouteNames } from '../../app.routes';
import { RoutesService } from '../../services/routes.service';
import { FormsModule } from '@angular/forms';
import { AuthService } from '../../services/auth.service';
import { UploadsService } from '../../services/uploads.service';
import { Clip } from '../../models/clip.model';
import { EditComponent } from '../../video/edit/edit.component';
import { Modals, ModalService } from '../../services/modal.service';

@Component({
  selector: 'app-manage',
  imports: [FormsModule, EditComponent],
  templateUrl: './manage.component.html',
  styleUrls: ['./manage.component.scss']
})
export class ManageComponent implements OnInit {
  RouteNames = RouteNames;

  #routes = inject(RoutesService);
  #auth = inject(AuthService);
  #uploads = inject(UploadsService);
  #modal = inject(ModalService);

  videoOrder = signal('1');
  clips : WritableSignal<Clip[]> = signal<Clip[]>([]);
  activeClip : WritableSignal<Clip | null> = signal<Clip | null>(null);

  get videoOrderValue() {
    return this.videoOrder();
  }
  set videoOrderValue(value: string) {
    this.videoOrder.set(value);
  }

  async ngOnInit(): Promise<void> {
    this.#routes.routeParams$.subscribe(params => {
      if (params && params['sort']){
        this.videoOrder.set(params['sort']);
      } else {
        this.videoOrder.set('1');
      }
    });   
    
    await this.loadClips();

  }

  public async loadClips() {
    this.clips.set([]);
    const results = await this.#uploads.getClipsByUser(this.#auth.currentUser()!.uid);

    results.forEach(clip => {
      this.clips.set([...this.clips(), new Clip(clip.fid, clip.uid, clip.displayName, clip.fileTitle, clip.fileName, clip.clipURL, clip.docID)]);
    });
  }

  public navigate(routeName: RouteNames) {
    this.#routes.navigateToRoute(routeName);
  }

  public sort(event: Event) {
    const { value } = event.target as HTMLSelectElement;   
    this.#routes.navigateToRoute(RouteNames.Manage, null, [{ 'sort':value}]);
  }

  public async openEditModal(event: Event, clip: Clip) {
    event.preventDefault();
    
    this.activeClip.set(clip);

    this.#modal.toggle(Modals.VideoEdit);

  }

}

