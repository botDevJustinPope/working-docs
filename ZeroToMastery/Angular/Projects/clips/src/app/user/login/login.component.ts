import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { AlertComponent } from '../../shared/alert/alert.component';
import { AuthService } from '../../services/auth.service';
import { Alert } from '../../models/alert.model';
import { AlertType } from '../../models/enum/alert.enum';
import { ILogin } from '../../models/login.model';

@Component({
  standalone: true,
  selector: 'app-login',
  imports: [FormsModule, AlertComponent],
  templateUrl: './login.component.html',
  styleUrl: './login.component.scss'
})
export class LoginComponent {
  authService = inject(AuthService);

  inSubmission = signal(false);
  showAlert = signal(false);
  alert = signal<Alert|null>(null);
  
  credentials : ILogin = {
    email: '',
    password: ''
  }

  async login() {
      this.inSubmission.set(true);
      this.setAlertInfo();
    try {
      await this.authService.logIn(this.credentials);
    } catch (error) {
      console.log(error);
      this.setAlertError();
      this.inSubmission.set(false);
      return;
    }
    this.setAlertSuccess();
  }

  setAlertInfo() {
    this.showAlert.set(true);
    this.alert.set(new Alert(AlertType.Info, 'Please wait! Logging you in.'));
  }

  setAlertSuccess() {
    this.showAlert.set(true);
    this.alert.set(new Alert(AlertType.Success, 'Success! You have been logged in.'));
  }

  setAlertError() {
    this.showAlert.set(true);
    this.alert.set(new Alert(AlertType.Error, 'An error occurred! Please try again later.'));
  }
}
