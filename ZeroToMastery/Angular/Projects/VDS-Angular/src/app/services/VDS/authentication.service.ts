import { Injectable } from '@angular/core';
import { BaseService } from '../base.service';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';
import { AuthenticateResponseDTO } from '../../models/VDS/authentication/authenticate-response.dto';

@Injectable({
  providedIn: 'root'
})
export class AuthenticationService extends BaseService {

  constructor(client: HttpClient) {
    super(client);
  }

/**
 * This method is used to authenticate a user with the VDS API. * 
 * @param email 
 * @param password 
 * @returns 
 */
  async authenticate(email: string, password: string) {
    
    let payload = {
      Email: email,
      Password: password,
      RequestOrigin: `${environment.appName}v${environment.version}` 
    }
    let url = 'authenticate';
    let response = await this.post<AuthenticateResponseDTO>(url, payload);
    return response;
  }
}
