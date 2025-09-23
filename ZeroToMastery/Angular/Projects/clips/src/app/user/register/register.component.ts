import { Component, inject, signal } from '@angular/core';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { InputComponent } from '../../shared/input/input.component';
import { AlertComponent } from '../../shared/alert/alert.component';
import { AuthService } from '../../services/auth.service';
import { Alert } from '../../models/alert.model';
import { AlertType } from '../../models/enum/alert.enum';

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

  form = this.fb.nonNullable.group(
    {
      name: ['', [Validators.required, Validators.minLength(3)]],
      email: ['', [Validators.required, Validators.email]],
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
    { validators: [this.passwordsMatchValidator] }
  );

  showAlert = signal(false);
  alert = signal<Alert|null>(null);

  passwordsMatchValidator(group: import('@angular/forms').AbstractControl) {
    const password = group.get('password')?.value;
    const confirmPassword = group.get('confirmPassword')?.value;
    if (password !== confirmPassword) {
      group.get('confirmPassword')?.setErrors({ passwordMismatch: true });
    } else {
      const errors = group.get('confirmPassword')?.errors;
      if (errors) {
        delete errors['passwordMismatch'];
        if (Object.keys(errors).length === 0) {
          group.get('confirmPassword')?.setErrors(null);
        } else {
          group.get('confirmPassword')?.setErrors(errors);
        }
      }
    }
    return null;
  }

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
    this.showAlert.set(true);
    this.alert.set(new Alert(AlertType.Info, 'Please wait! Your account is being created.'));
  }

  setAlertSuccess() {
    this.showAlert.set(true);
    this.alert.set(new Alert(AlertType.Success, 'Success! Your account has been created.'));
  }

  setAlertError() {
    this.showAlert.set(true);
    this.alert.set(new Alert(AlertType.Error, 'An error occurred! Please try again later.'));
  }

}
