import { Routes } from '@angular/router';
import { HomeComponent } from './views/home/home.component';
import { AboutComponent } from './views/about/about.component';
import { ManageComponent } from './views/manage/manage.component';
import { UploadComponent } from './views/upload/upload.component';
import { ClipComponent } from './views/clip/clip.component';
import { NotFoundComponent } from './views/not-found/not-found.component';
import { AuthGuard, redirectUnauthorizedTo } from '@angular/fire/auth-guard';

const redirectUnauthorizedToHome = () => redirectUnauthorizedTo(['/']);

export enum RouteNames {
    Home = '',
    About = 'about',
    Manage = 'manage',
    ManageClips = 'manage-clips',
    Upload = 'upload',
    Clip = 'clip/:id',
    NotFound = 'not-found',
    WildCard = '**',
}

export const routes: Routes = [
    {
        path: RouteNames.Home,
        component: HomeComponent,        
    },
    {
        path: RouteNames.About,
        component: AboutComponent,
    },
    {
        path: RouteNames.Manage,
        component: ManageComponent,
        data: {
            authOnly: true,
            authGuardPipe: redirectUnauthorizedToHome,
        },
        canActivate: [AuthGuard],
    },
    {
        path: RouteNames.ManageClips,
        redirectTo: RouteNames.Manage,
    },
    {
        path: RouteNames.Upload,
        component: UploadComponent,
        data: {
            authOnly: true,
            authGuardPipe: redirectUnauthorizedToHome,
        },
        canActivate: [AuthGuard],
    },
    {
        path: RouteNames.Clip,
        component: ClipComponent,
    },
    {
        path: RouteNames.NotFound,
        component: NotFoundComponent,
    },
    {
        path: RouteNames.WildCard,
        component: NotFoundComponent,
    }

];