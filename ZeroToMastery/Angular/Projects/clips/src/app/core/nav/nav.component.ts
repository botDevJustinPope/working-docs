import { Component, inject } from '@angular/core';
import { ModalService } from '../../services/modal.service';
import { AuthService } from '../../services/auth.service';
import { AsyncPipe } from '@angular/common';

@Component({
  selector: 'app-nav',
  standalone: true,
  imports: [AsyncPipe],
  templateUrl: './nav.component.html',
  styleUrl: './nav.component.scss'
})
export class NavComponent {
  modal = inject(ModalService);
  auth = inject(AuthService);

  openModal($event: Event) {
    $event.preventDefault();
    this.modal.toggle('auth');
  }

}
