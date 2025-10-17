import { Component, signal, inject } from '@angular/core';
import { EventBlockerDirective } from '../../shared/directives/event-blocker.directive';
import { NgClass } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { InputComponent } from '../../shared/input/input.component';
import { UploadsService } from '../../services/uploads.service';
import { AppFile } from '../../models/file.model';
import { AlertComponent } from '../../shared/alert/alert.component';
import { Alert } from '../../models/alert.model';
import { AlertType } from '../../models/enum/alert.enum';
import { StorageError, UploadTaskSnapshot } from '@angular/fire/storage';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-upload',
  standalone: true,
  imports: [
    EventBlockerDirective,
    NgClass,
    ReactiveFormsModule,
    InputComponent,
    AlertComponent,
  ],
  templateUrl: './upload.component.html',
  styleUrl: './upload.component.scss',
})
export class UploadComponent {
  isDragover = signal(false);
  file = signal<AppFile | null>(null);
  nextStep = signal(false);
  uploadsService = inject(UploadsService);
  alertObj = signal<Alert>(new Alert(false));
  inSubmission = signal(false);

  #auth = inject(AuthService);

  private maxFileSize = 25 * 1024 * 1024; // 25MB

  fb = inject(FormBuilder);
  form = this.fb.nonNullable.group({
    title: ['', [Validators.required, Validators.minLength(3)]],
  });

  storeFile(event: Event) {
    this.isDragover.set(false);

    const file = (event as DragEvent).dataTransfer?.files.item(0);
    if (file) {
      this.file.set(new AppFile(file));
    }

    if (!this.file()?.isValidType) {
      this.file.set(null);
      this.setAlertError('Please upload a valid mp4 file');
      return;
    } else if (!this.file() || !(this.file()!.file.size < this.maxFileSize)) {
      this.file.set(null);
      this.setAlertError(`File size must be less than ${this.maxFileSize / 1024 / 1024}MB`);
      return;
    } else {
      this.setAlertClear();
    }

    this.form.controls.title.setValue(
      this.file()?.file.name.replace(/\.[^/.]+$/, '') ?? ''
    );

    this.nextStep.set(true);
  }

  uploadFile() {
    const task = this.uploadsService.uploadfile(this.file() as AppFile);

    this.setUploadInProgress();

    task.subscribe(
      {
      next: (snapshot: UploadTaskSnapshot) => {
        // set progress
        this.setUploadTaskProgress(snapshot);
      },
      error: (error: StorageError) => {
        // set error
        this.setUploadError(error);
      },
      complete: () => {
        // completed
        this.setUploadComplete();
        // await a second then set next step
      }
    }
    );
  }

  //* Alerts *//
  setAlertClear() {
    this.alertObj.set(new Alert(false));
  }

  setUploadInProgress() {
    this.alertObj.set(new Alert(true, AlertType.Info, 'Upload in prgress...'));
    this.inSubmission.set(true);
  }

  setUploadTaskProgress(task: UploadTaskSnapshot) {
    const progress:number = ((task.bytesTransferred / task.totalBytes) * 100) as number;
    this.alertObj.set(new Alert(true, AlertType.Info, '', progress));
  }

  setUploadError(error: StorageError) {
    this.alertObj.set(new Alert(true, AlertType.Error, `Upload failed: ${error.message}`));
  }

  setUploadComplete() {
    this.alertObj.set(new Alert(true, AlertType.Success, 'Upload complete!'));
  }

  setAlertError(message: string) {
    this.alertObj.set(new Alert(true, AlertType.Error, message));
  }
}
