import { Injectable, signal } from '@angular/core';
import { BehaviorSubject, Observable, Subject } from 'rxjs';

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

  private modalStateSubject = new Subject<IModalState>();
  public modalState$: Observable<IModalState> = this.modalStateSubject.asObservable();

  register(modalENUM: Modals, element: HTMLDialogElement) {
    this.modals.set([...this.modals(),{ id: modalENUM, element }]);
    this.notifyStateChange(modalENUM, ModalState.Registered);
  }

  unregister(modalENUM: Modals) {
    this.modals.set(this.modals().filter((item) => item.id !== modalENUM));
    this.notifyStateChange(modalENUM, ModalState.Unregistered);
  }

  toggle(modalENUM: Modals) {
    const modal = this.modals().find((item) => item.id === modalENUM);
    if (modal) {
      if (modal.element.open) {
        this.notifyStateChange(modalENUM, ModalState.Closed);
      } else {
        this.notifyStateChange(modalENUM, ModalState.Opened);
      }
      modal.element.open ? modal.element.close() : modal.element.showModal();
    }
  }

  private notifyStateChange(modal:Modals, state: ModalState) {
    this.modalStateSubject.next({ modal, state });
  }
}

export enum Modals {
  Auth = 'auth',
  Alert = 'alert',
  VideoEdit = 'video-edit'
}

export enum ModalState {
  Registered = 'registered',
  Unregistered = 'unregistered',
  Opened = 'opened',
  Closed = 'closed'
}
  
export interface IModalState {
  modal: Modals;
  state: ModalState;
}