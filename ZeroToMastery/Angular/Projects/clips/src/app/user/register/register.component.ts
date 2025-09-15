import { Component, inject, signal } from '@angular/core';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { InputComponent } from '../../shared/input/input.component';
import { AlertComponent } from '../../shared/alert/alert.component';
import { Auth, createUserWithEmailAndPassword } from '@angular/fire/auth';

@Component({
  standalone: true,
  selector: 'app-register',
  imports: [ReactiveFormsModule, CommonModule, InputComponent, AlertComponent],
  templateUrl: './register.component.html',
  styleUrl: './register.component.scss',
})
export class RegisterComponent {
  fb = inject(FormBuilder);
  #auth = inject(Auth);

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
  alertMsg = signal('Please wait! Your account is begin created.');
  alertColor = signal('blue');

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
    this.showAlert.set(true);
    this.alertMsg.set('Please wait! Your account is being created.');
    this.alertColor.set('blue');

    const { email, password } = this.form.getRawValue();
    try {
      const userCred = await createUserWithEmailAndPassword(
        this.#auth,
        email,
        password
      );

      console.log(userCred);
    } catch (error) {
      console.error(error);
      this.alertMsg.set('An error occurred! Please try again latter.');
      this.alertColor.set('red');
      return;
    }

    this.alertMsg.set('Success! Your account has been created.');
    this.alertColor.set('green');
  }
}
