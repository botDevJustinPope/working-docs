import { Component, inject, OnInit, signal } from '@angular/core';
import { RouteNames } from '../../app.routes';
import { RoutesService } from '../../services/routes.service';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-manage',
  imports: [FormsModule],
  templateUrl: './manage.component.html',
  styleUrls: ['./manage.component.scss']
})
export class ManageComponent implements OnInit {
  RouteNames = RouteNames;

  routes = inject(RoutesService);

  videoOrder = signal('1');

  get videoOrderValue() {
    return this.videoOrder();
  }
  set videoOrderValue(value: string) {
    this.videoOrder.set(value);
  }

  ngOnInit(): void {
    this.routes.routeParams$.subscribe(params => {
      if (params && params['sort']){
        this.videoOrder.set(params['sort']);
      } else {
        this.videoOrder.set('1');
      }
    });    
  }

  public navigate(routeName: RouteNames) {
    this.routes.navigateToRoute(routeName);
  }

  public sort(event: Event) {
    const { value } = event.target as HTMLSelectElement;   
    this.routes.navigateToRoute(RouteNames.Manage, null, [{ 'sort':value}]);
  }

}
