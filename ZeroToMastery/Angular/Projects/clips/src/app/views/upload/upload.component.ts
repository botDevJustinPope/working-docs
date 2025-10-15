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
  showAlert = signal(false);
  alertObj = signal<Alert | null>(null);

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
      alert('Please upload a valid mp4 file');
      return;
    }

    this.form.controls.title.setValue(
      this.file()?.file.name.replace(/\.[^/.]+$/, '') ?? ''
    );

    this.nextStep.set(true);
  }

  uploadFile() {
    const task = this.uploadsService.uploadfile(this.file() as AppFile);
    this.setUploadInProgress();

    task.on(
      'state_changed',
      (snapshot: UploadTaskSnapshot) => {
        // set progress
        this.setUploadTaskProgress(snapshot);
      },
      (error: StorageError) => {
        // set error
        this.setUploadError(error);
      },
      () => {
        // completed
        this.setUploadComplete();
        // await a second then set next step
        setTimeout(() => {
          this.nextStep.set(true);
        }, 1000);
      }
    );
  }

  //* Alerts *//
  closeAlert() {
    this.showAlert.set(false);
  }

  activateAlert() {
    this.showAlert.set(true);
  }

  setUploadInProgress() {
    this.activateAlert();
    this.alertObj.set(new Alert(AlertType.Info, 'Upload in prgress...'));
  }

  setUploadTaskProgress(task: UploadTaskSnapshot) {
    this.activateAlert();
    const progress = (task.bytesTransferred / task.totalBytes) * 100;
    this.alertObj.set(new Alert(AlertType.Info, `Upload is ${progress}% done`));
  }

  setUploadError(error: StorageError) {
    this.activateAlert();
    this.alertObj.set(new Alert(AlertType.Error, `Upload failed: ${error.message}`));
  }

  setUploadComplete() {
    this.activateAlert();
    this.alertObj.set(new Alert(AlertType.Success, 'Upload complete!'));
  }
}
