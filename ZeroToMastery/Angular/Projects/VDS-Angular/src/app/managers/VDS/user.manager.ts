import { inject, Injectable } from '@angular/core';
import { AuthenticationService } from '../../services/VDS/authentication.service';

@Injectable({
  providedIn: 'root'
})
export class UserManager {
    private authService = inject(AuthenticationService);

    private currentUserToken: string | null = null;
    private currentAuthUser: any = null;

    get userToken(): string | null {
      return this.currentUserToken;
    }
}
