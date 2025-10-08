import { Injectable, inject } from '@angular/core';
import { Router, ActivatedRoute, NavigationEnd, Params, } from '@angular/router';
import { switchMap, map, filter } from 'rxjs/operators';
import { RouteNames } from '../app.routes';
import { BehaviorSubject, Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class RoutesService {
  router = inject(Router);
  route = inject(ActivatedRoute);

  private currentRouteSubject = new BehaviorSubject<ActivatedRoute | null>(null);
  private currentRoute$ = this.currentRouteSubject.asObservable();

  private routeParamsSubject = new BehaviorSubject<Params | null>(null);
  public routeParams$: Observable<Params | null> = this.routeParamsSubject.asObservable();

  private routeDataSubject = new BehaviorSubject<any>(null);
  public routeData$: Observable<any> = this.routeDataSubject.asObservable();

  constructor() {
    this.init();
  }

  private init() {
    this.readCurrentRoute();
    this.readRouteData();
    this.readRouteParams();
  }

  private readCurrentRoute() {
    this.router.events
      .pipe(
        filter((event) => event instanceof NavigationEnd),
        map(() => {
          let currentRoute = this.route;
          while (currentRoute.firstChild) {
            currentRoute = currentRoute.firstChild;
          }
          return currentRoute;
        })
      )
      .subscribe((activatedRoute) => {
        this.currentRouteSubject.next(activatedRoute);
      });
  }

  private readRouteData() {
    this.currentRoute$
      .pipe(switchMap((route) => (route ? route.data : [])))
      .subscribe((data) => {
        this.routeDataSubject.next(data);
      });
  }

  private readRouteParams() {
    this.currentRoute$
      .pipe(switchMap((route) => (route ? route.params : [])))
      .subscribe((params) => {
        this.routeParamsSubject.next(params);
      });
  }

  public navigateToRoute(name: RouteNames, params: [{ [key: string]: any }] | null = null, queryParams: [{ [key: string]: any }] | null = null) {
    this.router.navigate([this.resolveRoute(name, params)], { queryParams: this.resolveQueryParams(queryParams) });
  }

  // from RouteName inject route parameters with the matching key value pair
  private resolveRoute(name: RouteNames, params: [{ [key: string]: any }] | null = null): string {
    // Replace and :param in the route with matching key from params, if not found use empty string
    let route = `/${name}`;
    route = route.replace(/:([a-zA-Z]+)/g, (_, key) => {
      const param = params ? params.find(p => p.hasOwnProperty(key)) : null;
      return param ? param[key] : '';
    });

    return route;
  }

  // Combine all query params into a single object
  private resolveQueryParams(queryParams: [{ [key: string]: any }] | null = null) : Params | null {
    let resolvedQueryParams: any = {};
    if (queryParams) {
      queryParams.forEach(param => {
        resolvedQueryParams = { ...resolvedQueryParams, ...param };
      });
    }
    return resolvedQueryParams;
  }

  public getRouteUrl(name: RouteNames, params?: (string | number)[]): string {
    // Remove any :param from the route name
    const base = name.split('/:')[0];
    return '/' + [base, ...(params ?? [])].join('/');
  }


}
