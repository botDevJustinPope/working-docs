import { Component, inject, input, viewChild, AfterViewInit, ElementRef, OnDestroy, signal} from '@angular/core';
import { NgClass } from '@angular/common';
import { ModalService } from '../../services/modal.service';

@Component({
  selector: 'app-modal',
  standalone: true,
  imports: [NgClass],
  templateUrl: './modal.component.html',
  styleUrl: './modal.component.scss'
})

export class ModalComponent implements AfterViewInit, OnDestroy {
  modal = inject(ModalService);  

  id = input.required<string>();
  dialog = viewChild.required<ElementRef<HTMLDialogElement>>('baseDialog');
  fullscreen = signal(false);

  ngAfterViewInit() {
    this.modal.register(this.id(), this.dialog().nativeElement);
  }

  ngOnDestroy() {
    this.modal.unregister(this.id());
  }

  closeModal() {
    this.modal.toggle(this.id());
  }

  toggleFullscreen() {
    this.fullscreen.set(!this.fullscreen());
  }
}
