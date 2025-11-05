import { Component, input } from '@angular/core';
import { ModalComponent } from '../modal/modal.component';
import { AlertComponent } from '../alert/alert.component';
import { Alert } from '../../models/alerts/alert.model';

@Component({
  selector: 'app-alert-modal',
  standalone: true,
  imports: [ModalComponent, AlertComponent],
  templateUrl: './alert-modal.component.html',
  styleUrl: './alert-modal.component.scss'
})
export class AlertModalComponent {
  alertInput = input<Alert|null>(null)

}
