import { Injectable, signal } from '@angular/core';

interface IModal {
  id: string;
  element: HTMLDialogElement;

}

@Injectable({
  providedIn: 'root'
})
export class ModalService {
  private modals = signal<IModal[]>([]);
  
  constructor() { }

  register(modalENUM: Modals, element: HTMLDialogElement) {
    this.modals.set([...this.modals(),{ id: modalENUM, element }]);
  }

  unregister(modalENUM: Modals) {
    this.modals.set(this.modals().filter((item) => item.id !== modalENUM));
  }

  toggle(modalENUM: Modals) {
    const modal = this.modals().find((item) => item.id === modalENUM);
    if (modal) {
      modal.element.open ? modal.element.close() : modal.element.showModal();
    }
  }
}

export enum Modals {
  Auth = 'auth',
  Alert = 'alert'
}
  