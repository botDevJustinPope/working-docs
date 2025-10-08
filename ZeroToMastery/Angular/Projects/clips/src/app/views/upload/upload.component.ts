import { Component, signal, inject } from '@angular/core';
import { EventBlockerDirective } from '../../shared/directives/event-blocker.directive';
import { NgClass} from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { InputComponent } from '../../shared/input/input.component';
import { UploadsService } from '../../services/uploads.service';

@Component({
  selector: 'app-upload',
  standalone: true,
  imports: [EventBlockerDirective, NgClass, ReactiveFormsModule, InputComponent],
  templateUrl: './upload.component.html',
  styleUrl: './upload.component.scss'
})
export class UploadComponent {
  isDragover = signal(false);
  file = signal<File | null>(null);
  nextStep = signal(false);
  uploadsService = inject(UploadsService);

  fb = inject(FormBuilder);
  form = this.fb.nonNullable.group({
    title: ['', [Validators.required, Validators.minLength(3)]],
  })

  storeFile(event: Event) {
    this.isDragover.set(false);

    this.file.set((event as DragEvent).dataTransfer?.files.item(0) ?? null);

    if (this.file()?.type !== 'video/mp4') {
      this.file.set(null);
      alert('Please upload a valid mp4 file');
      return;
    }

    this.form.controls.title.setValue(this.file()?.name.replace(/\.[^/.]+$/, '') ?? '');

    this.nextStep.set(true);

  }

  uploadFile() {
    this.uploadsService.uploadfile(this.file() as File);
  }
}
