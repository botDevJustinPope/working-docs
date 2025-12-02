import { Injectable, signal } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';

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

  private modalSubject = new BehaviorSubject<IModal[]>([]);
  public modals$: Observable<IModal[]> = this.modalSubject.asObservable();

  private setModalsObservable() {
    
  }

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
  Alert = 'alert',
  VideoEdit = 'video-edit'
}
  