import {
  Component,
  computed,
  effect,
  inject,
  input,
  OnDestroy,
  signal,
} from '@angular/core';
import { NgClass } from '@angular/common';
import { ModalComponent } from '../../shared/modal/modal.component';
import { Modals } from '../../services/modal.service';
import { Clip } from '../../models/clip.model';
import { ReactiveFormsModule, Validators, FormBuilder } from '@angular/forms';
import { InputComponent } from '../../shared/input/input.component';
import { Alert } from '../../models/alerts/alert.model';
import { AlertComponent } from '../../shared/alert/alert.component';
import { AlertType } from '../../models/enum/alert.enum';
import { UploadsService } from '../../services/uploads.service';
import { UtilService } from '../../services/utils/util.service';

@Component({
  selector: 'app-edit',
  standalone: true,
  imports: [
    ModalComponent,
    ReactiveFormsModule,
    InputComponent,
    AlertComponent,
    NgClass,
  ],
  templateUrl: './edit.component.html',
  styleUrl: './edit.component.scss',
})
export class EditComponent implements OnDestroy {
  modalId = Modals.VideoEdit;

  clip = input<Clip | null>(null);

  uploadsService = inject(UploadsService);
  fb = inject(FormBuilder);
  form = this.fb.nonNullable.group({
    id: [''],
    title: ['', [Validators.required, Validators.minLength(3)]],
  });

  alertObj = signal<Alert>(new Alert(false));
  inSubmission = signal<boolean>(false);
  formInvalid = signal<boolean>(false);

  disableSubmit = computed(() => {
    return this.inSubmission() || this.formInvalid();
  });

  constructor() {
    effect(() => {
      if (this.clip()) {
        if (this.clip()?.docID !== this.form.controls.id.value) {
          this.setAlertClear();
          this.form.controls.id.setValue(this.clip()?.docID ?? '');
          this.form.controls.title.setValue(this.clip()?.fileTitle ?? '');
        }
      }
    });
    this.form.statusChanges.subscribe(() => {
      this.formInvalid.set(this.form.invalid);
    });
  }

  ngOnDestroy(): void {
    this.setAlertClear();
    this.form.reset();
  }

  async submit() {
    this.setAlertUpdateBegin();
    await UtilService.sleep(500);
    try {
      this.uploadsService.updateClip(
        this.form.controls.id.value,
        this.form.controls.title.value
      );
      this.setAlertUpdateSuccess();
    } catch (error) {
      this.setAlertUpdateError((error as Error).message);
      return;
    }
  }

  setAlertClear() {
    this.inSubmission.set(false);
    this.baseAlertUpdate(false);
  }

  setAlertUpdateBegin() {
    this.inSubmission.set(true);
    this.baseAlertUpdate(true, AlertType.Info, 'Updating clip...');
  }

  setAlertUpdateSuccess() {
    this.inSubmission.set(false);
    this.baseAlertUpdate(true, AlertType.Success, 'Clip updated successfully!');
  }

  setAlertUpdateError(errorMessage: string) {
    this.inSubmission.set(false);
    this.baseAlertUpdate(
      true,
      AlertType.Error,
      `Error updating clip: ${errorMessage}`
    );
  }

  baseAlertUpdate(
    enabled: boolean,
    type: AlertType = AlertType.Info,
    message: string = ''
  ) {
    this.alertObj.set(new Alert(enabled, type, message));
  }
}
