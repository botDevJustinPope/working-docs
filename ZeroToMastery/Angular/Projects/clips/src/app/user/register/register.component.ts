import { Component, inject, signal } from '@angular/core';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { InputComponent } from '../../shared/input/input.component';
import { AlertComponent } from '../../shared/alert/alert.component';
import { AuthService } from '../../services/auth.service';
import { Alert } from '../../models/alert.model';
import { AlertType } from '../../models/enum/alert.enum';
import { Match, EmailTaken } from './validators';

@Component({
  standalone: true,
  selector: 'app-register',
  imports: [ReactiveFormsModule, CommonModule, InputComponent, AlertComponent],
  templateUrl: './register.component.html',
  styleUrl: './register.component.scss',
})
export class RegisterComponent {
  fb = inject(FormBuilder);
  inSubmission = signal(false);
  authService = inject(AuthService);
  emailTaken = inject(EmailTaken);
  alert = signal<Alert>(new Alert(false));

  form = this.fb.nonNullable.group(
    {
      name: ['', [Validators.required, Validators.minLength(3)]],
      email: ['', [Validators.required, Validators.email], [this.emailTaken.validate.bind(this.emailTaken)]],
      age: [18, [Validators.required, Validators.min(18), Validators.max(120)]],
      password: [
        '',
        [
          Validators.required,
          Validators.pattern(
            /^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z]).{8,}$/
          ),
        ],
      ],
      confirmPassword: ['', [Validators.required]],
      phoneNumber: [
        '',
        [
          Validators.required,
          Validators.minLength(13),
          Validators.maxLength(13),
        ],
      ],
    },
    { validators: [Match('password', 'confirmPassword')] }
  );

  async register() {
    this.inSubmission.set(true);
    this.setAlertInfo();

    try {

      await this.authService.createUser(this.form.getRawValue());

    } catch (error) {
      console.error(error);
      this.setAlertError();
      this.inSubmission.set(false);
      return;
    }

    this.setAlertSuccess();
  }

  setAlertInfo() {
    this.alert.set(new Alert(true,AlertType.Info, 'Please wait! Your account is being created.'));
  }

  setAlertSuccess() {
    this.alert.set(new Alert(true,AlertType.Success, 'Success! Your account has been created.'));
  }

  setAlertError() {
    this.alert.set(new Alert(true,AlertType.Error, 'An error occurred! Please try again later.'));
  }

}
