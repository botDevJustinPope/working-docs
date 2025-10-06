import { ValidationErrors, AbstractControl, ValidatorFn } from '@angular/forms';
import { AuthService } from '../../services/auth.service';
import { inject, Injectable } from '@angular/core';
import { AsyncValidator } from '@angular/forms';

export function Match(
  controlName: string,
  matchingControlName: string
): ValidatorFn {
  return (group: AbstractControl): ValidationErrors | null => {
    const control = group.get(controlName);
    const matchingControl = group.get(matchingControlName);

    if (!control || !matchingControl) {
      console.error(
        `Form controls (${controlName}, ${matchingControlName}) cannot be found in the form group.`
      );
      return { controlNotFound: false };
    }

    const error =
      control.value === matchingControl.value ? null : { noMatch: true };

    if (error) {
      matchingControl.setErrors(error);
    } else {
      matchingControl.setErrors(null);
    }

    return error;
  };
}

@Injectable({ providedIn: 'root' })
export class EmailTaken implements AsyncValidator {
    authService = inject(AuthService);

    validate = (control:AbstractControl):Promise<ValidationErrors|null> => {
        try {
            return this.authService.doesEmailExist(control.value).then((result) => result.length ? { emailTaken: true } : null);
        } catch (e) {
            console.error(e);
            return Promise.resolve({ emailTaken: true });
        }
    }
}