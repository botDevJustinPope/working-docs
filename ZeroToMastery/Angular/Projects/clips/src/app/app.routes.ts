import { Routes } from '@angular/router';
import { HomeComponent } from './views/home/home.component';
import { AboutComponent } from './views/about/about.component';

export const routes: Routes = [
    {
        path: '',
        component: HomeComponent,        
    },
    {
        path: 'about',
        component: AboutComponent,
    }
];
