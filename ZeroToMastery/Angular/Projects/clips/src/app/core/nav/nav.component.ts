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
  authService = inject(AuthService);

  openModal($event: Event) {
    $event.preventDefault();
    this.modal.toggle('auth');
  }

  async logOut($event: Event) {
    $event.preventDefault();

    try {
      await this.authService.logOut();
    } catch (e) {
      console.error(e);
    }
    
  }

}
