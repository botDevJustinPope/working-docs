import {
  Component,
  WritableSignal,
  signal,
  inject,
  OnDestroy,
  effect,
} from '@angular/core';
import { EventBlockerDirective } from '../../shared/directives/event-blocker.directive';
import { NgClass } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { InputComponent } from '../../shared/input/input.component';
import { UploadsService } from '../../services/uploads.service';
import { AppFile } from '../../models/appfile.model';
import { AlertComponent } from '../../shared/alert/alert.component';
import { Alert } from '../../models/alerts/alert.model';
import { AlertType } from '../../models/enum/alert.enum';
import {
  StorageError,
  StorageReference,
  UploadTaskSnapshot,
  UploadTask,
  fromTask,
} from '@angular/fire/storage';
import { AuthService } from '../../services/auth.service';
import { Subscription } from 'rxjs';
import { UtilService } from '../../services/utils/util.service';
import { AnimationsConfigHelper } from '../../services/utils/animations-config.helper';
import { ButtonsHelper } from '../../services/utils/buttons.helper';
import { CircularProgress } from '../../models/animations/circular-progress/circular-progress.model';
import { IButtonConfig } from '../../models/alerts/button-config.model';

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
  /* 
  Signals and Injected services
  */
  isDragover = signal(false);
  file = signal<AppFile | null>(null);
  nextStep = signal(false);
  uploadsService = inject(UploadsService);
  inSubmission = signal(false);
  #auth = inject(AuthService);

  /* 
  Firebase Upload Task
  */
  uploadTask: UploadTask | null = null;
  /* 
  page subscriptions 
  */
  uploadSub: Subscription | null = null;
  formTitleSub: Subscription | null = null;

  /* page form */
  fb = inject(FormBuilder);
  form = this.fb.nonNullable.group({
    title: ['', [Validators.required, Validators.minLength(3)]],
  });

  constructor() {
    // this effect will read off the inSubmission to disable/enable the form
    effect(() => {
      if (this.inSubmission()) {
        this.form.disable();
      } else {
        this.form.enable();
      }
    });
  }

  public ngOnDestroy() {
    if (this.uploadTask) {
      this.uploadTask?.cancel();
    }
    if (this.uploadSub) {
      this.uploadSub.unsubscribe();
    }
    this.uploadTask = null;
    this.uploadSub = null;

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
    this.uploadTask = this.uploadsService.uploadfile(this.file() as AppFile);
    const observableTask = fromTask(this.uploadTask);

    this.setUploadInProgress();

    this.uploadSub = observableTask.subscribe({
      next: (snapshot: UploadTaskSnapshot) => {
        // set progress
        this.setUploadTaskProgressWithSnapshotandTask(
          snapshot,
          this.uploadTask!
        );
      },
      error: (error: StorageError) => {
        // set error
        console.log('upload error:', error);
        this.setUploadError(error);
      },
      complete: async () => {
        this.file()!.clip.clipURL =
          await this.uploadsService.getFileDownloadURL(
            this.file()?.fireBaseRef as StorageReference
          );

        const dataMessage: string = 'Finalizing data upload...';
        this.setUploadTaskProgressWithRawPercentage(dataMessage, 95);

        await UtilService.sleep(500);

        await this.uploadsService.createClip(this.file()!);

        await UtilService.sleep(500);

        this.setUploadTaskProgressWithRawPercentage(dataMessage, 100);

        await UtilService.sleep(500);

        // completed
        this.setUploadComplete();

        // await a second then set next step
        setTimeout(() => {
          this.resetPage();
        }, 2000);
      },
    });
  }

  async cancelUpload() {
    if (this.uploadTask) {
      this.uploadTask.cancel();
    }
    this.uploadSub?.unsubscribe();
    this.setAlertError('Upload was cancelled by user. Cancelling upload.');
    await UtilService.sleep(2000);
    this.resetPage();
  }

  //* Page Status Methods *//
  resetPage() {
    this.file.set(null);
    this.nextStep.set(false);
    this.inSubmission.set(false);
    this.uploadTask = null;
    this.formTitleSub?.unsubscribe();
    this.uploadSub?.unsubscribe();
    this.form.reset();
    this.setAlertClear();
  }

  isPageValidToSubmit(): boolean {
    return this.form.valid && this.file() !== null && !this.inSubmission();
  }

  //* Alerts *//
  alertObj: WritableSignal<Alert> = signal(new Alert(false));
  alertPercentage: WritableSignal<CircularProgress | null> = signal(null);
  alertButtons: WritableSignal<IButtonConfig[] | null> = signal(null);

  setAlertClear() {
    this.baseSetUploadTaskProgress(false);
  }

  setUploadInProgress() {
    this.alertObj.set(new Alert(true, AlertType.Info, 'Upload in prgress...'));
    this.inSubmission.set(true);
  }

  setUploadTaskProgressWithSnapshotandTask(
    task: UploadTaskSnapshot,
    uploadTask: UploadTask
  ) {
    /*
    The file upload is only part of the upload. Subtracting 5% for the file so that the clip data upload to be apart of the percentage.
    */
    const progress: number = ((task.bytesTransferred / task.totalBytes / 95) *
      100) as number;
    let aType: AlertType = AlertType.Info;
    console.log('task state:', task.state);
    switch (task.state) {
      case 'paused':
        aType = AlertType.Warning;
        break;
      case 'running':
      default:
        aType = AlertType.Info;
        break;
      case 'canceled':
        aType = AlertType.Error;
        break;
    }
    const percentConfig = AnimationsConfigHelper.generateCircularProgress(
      progress,
      aType
    );
    const buttons = ButtonsHelper.generateButtonsForUploadTask(uploadTask);
    this.baseSetUploadTaskProgress(
      true,
      aType,
      'Video Upload in progress....',
      percentConfig,
      buttons
    );
  }

  setUploadTaskProgressWithRawPercentage(
    message: string = '',
    percentage: number
  ) {
    const percentConfig = AnimationsConfigHelper.generateCircularProgress(
      percentage,
      AlertType.Info
    );
    this.baseSetUploadTaskProgress(
      true,
      AlertType.Info,
      message,
      percentConfig
    );
  }

  baseSetUploadTaskProgress(
    enabled: boolean = true,
    alertType: AlertType = AlertType.Info,
    message: string = '',
    percentile: CircularProgress | null = null,
    buttons: IButtonConfig[] | null = null
  ) {
    // if the alert is not visible, set it to a new alert
    if (this.alertObj().enabled !== enabled || 
        this.alertObj().type !== alertType ||
        this.alertObj().message !== message) {
      this.alertObj.set(new Alert(enabled, alertType, message));
    }

    // otherwise just update the existing alert

    if (this.alertObj().type !== alertType) {
      this.alertObj().type = alertType;
    }

    if (this.alertObj().message !== message) {
      this.alertObj().message = message;
    }

    if (percentile) {
      if (
        percentile.animationPercent !== this.alertPercentage()?.animationPercent
      ) {
        this.alertPercentage.set(percentile);
      }
    } else {
      this.alertPercentage.set(null);
    }

    if (buttons) {
      console.log('Setting buttons');
      let updateButtons = false;
      if (
        this.alertButtons()?.length === buttons.length
      ) {
        console.log('Comparing buttons');
        this.alertButtons()?.forEach((btn) => {
          buttons.forEach((newBtn) => {
            console.log('Comparing button', btn, newBtn);
            if (ButtonsHelper.buttonsAreEqual(btn, newBtn)) {
              updateButtons = false;
              return;
            } else {
              updateButtons = true;
            }
          });
          if (updateButtons) {
            console.log('Buttons differ, updating buttons');
            return;
          }
        });
      } else {
        updateButtons = true;
      }
      if (updateButtons) {
        console.log('Updating buttons');
        this.alertButtons.set(buttons);
      }
    } else {
      console.log('Clearing buttons');
      this.alertButtons.set(null);
    }
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
