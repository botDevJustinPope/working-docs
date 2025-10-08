import { Component, inject, signal, OnInit } from '@angular/core';
import { RoutesService } from '../../services/routes.service';
import { RouteNames } from '../../app.routes';
import { RouterLink } from "@angular/router";

@Component({
  selector: 'app-clip',
  imports: [RouterLink],
  templateUrl: './clip.component.html',
  styleUrl: './clip.component.scss'
})
export class ClipComponent implements OnInit {
  routeNames = RouteNames;
  routes = inject(RoutesService);
  id = signal('');

  get idValue() {
    return this.id();
  }

  ngOnInit(): void {
    this.routes.routeParams$.subscribe(params => {
      this.id.set(params ? params['id'] : '');
    });
  }

  navigateToClip(id: string) {
    this.routes.navigateToRoute(RouteNames.Clip, [{ 'id': id }]);
  }

  getClipUrl(id: string): string {
    return this.routes.getRouteUrl(RouteNames.Clip, [id]);
  }

}
