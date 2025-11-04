import { Component, signal, inject, OnDestroy } from '@angular/core';
import { EventBlockerDirective } from '../../shared/directives/event-blocker.directive';
import { NgClass } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { InputComponent } from '../../shared/input/input.component';
import { UploadsService } from '../../services/uploads.service';
import { AppFile } from '../../models/appfile.model';
import { AlertComponent } from '../../shared/alert/alert.component';
import { Alert } from '../../models/alert.model';
import { AlertType } from '../../models/enum/alert.enum';
import {
  StorageError,
  StorageReference,
  UploadTaskSnapshot,
} from '@angular/fire/storage';
import { AuthService } from '../../services/auth.service';
import { Subscription } from 'rxjs';

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
export class UploadComponent implements OnDestroy {
  isDragover = signal(false);
  file = signal<AppFile | null>(null);
  nextStep = signal(false);
  uploadsService = inject(UploadsService);
  alertObj = signal<Alert>(new Alert(false));
  inSubmission = signal(false);

  #auth = inject(AuthService);

  fb = inject(FormBuilder);
  form = this.fb.nonNullable.group({
    title: ['', [Validators.required, Validators.minLength(3)]],
  });

  private formTitleSub: Subscription | null = null;

  public ngOnDestroy() {
    // clean up page
    this.resetPage();
  }

  storeFile(event: Event) {
    this.isDragover.set(false);

    const file = (event as DragEvent).dataTransfer?.files.item(0);

    if (file) {
      this.file.set(new AppFile(file, this.#auth.currentUser()!));
    }

    if (!this.file()?.isValidType) {
      this.file.set(null);
      this.setAlertError('Please upload a valid mp4 file');
      return;
    } else if (
      !this.file() ||
      !(this.file()?.file && this.file()?.isValidFileSize)
    ) {
      this.setAlertError(
        `File size must be less than ${
          AppFile.maxFileSizeInMB
        }MB. The file that was upload is ${
          this.file()?.data.file.size! / 1024 / 1024
        }MB.`
      );
      this.file.set(null);
      return;
    } else {
      this.setAlertClear();
    }

    this.formTitleSub = this.form.controls.title.valueChanges.subscribe(
      (val) => {
        if (this.file()) {
          this.file()!.clip.fileTitle = val ?? '';
        }
      }
    );

    this.form.controls.title.setValue(
      this.file()?.file.name.replace(/\.[^/.]+$/, '') ?? ''
    );

    this.nextStep.set(true);
  }

  uploadFile() {
    const task = this.uploadsService.uploadfile(this.file() as AppFile);

    this.setUploadInProgress();

    task.subscribe({
      next: (snapshot: UploadTaskSnapshot) => {
        // set progress
        this.setUploadTaskProgress(snapshot);
      },
      error: (error: StorageError) => {
        // set error
        this.setUploadError(error);
      },
      complete: async () => {
        this.file()!.clip.clipURL =
          await this.uploadsService.getFileDownloadURL(
            this.file()?.fireBaseRef as StorageReference
          );

        console.log('file before upload: ', this.file());

        await this.uploadsService.createClip(this.file()!);

        // completed
        this.setUploadComplete();

        // await a second then set next step
        setTimeout(() => {
          this.resetPage();
        }, 2000);
      },
    });
  }

  //* Page Status Methods *//
  resetPage() {
    this.file.set(null);
    this.nextStep.set(false);
    this.inSubmission.set(false);
    this.formTitleSub?.unsubscribe();
    this.setAlertClear();
  }

  isPageValidToSubmit(): boolean {
    return this.form.valid && this.file() !== null && !this.inSubmission();
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
    const progress: number = (task.bytesTransferred /
      task.totalBytes) as number;
    this.alertObj.set(new Alert(true, AlertType.Info, '', progress));
  }

  setUploadError(error: StorageError) {
    this.alertObj.set(
      new Alert(true, AlertType.Error, `Upload failed: ${error.message}`)
    );
  }

  setUploadComplete() {
    this.alertObj.set(new Alert(true, AlertType.Success, 'Upload complete!'));
  }

  setAlertError(message: string) {
    this.alertObj.set(new Alert(true, AlertType.Error, message));
  }
}
