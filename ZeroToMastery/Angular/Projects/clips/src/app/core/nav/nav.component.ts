import { Component, inject } from '@angular/core';
import { Modals, ModalService } from '../../services/modal.service';
import { AuthService } from '../../services/auth.service';
import { AsyncPipe } from '@angular/common';
import { RouterLink, RouterLinkActive } from "@angular/router";
import { RouteNames } from '../../app.routes';
import { RoutesService } from '../../services/routes.service';

@Component({
  selector: 'app-nav',
  standalone: true,
  imports: [AsyncPipe, RouterLink, RouterLinkActive],
  templateUrl: './nav.component.html',
  styleUrl: './nav.component.scss'
})
export class NavComponent {
  modal = inject(ModalService);
  authService = inject(AuthService);
  routes = inject(RoutesService);
  RouteNames = RouteNames;

  openModal($event: Event) {
    $event.preventDefault();
    this.modal.toggle(Modals.Auth);
  }

  public navigate(routeName: RouteNames) {
    this.routes.navigateToRoute(routeName);
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
