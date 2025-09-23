import { Component, input, signal } from '@angular/core';
import { NgClass } from '@angular/common';
import { Alert } from '../../models/alert.model';
import { AlertType } from '../../models/enum/alert.enum';

@Component({
  selector: 'app-alert',
  standalone: true,
  imports: [NgClass],
  templateUrl: './alert.component.html',
  styleUrl: './alert.component.scss'
})
export class AlertComponent {
  color = input('blue');
  alertInput = input<Alert|null>(null)

  get bgColor() {
    switch (this.alertType) {
      case AlertType.Success:
        return 'bg-green-500';
      case AlertType.Error:
        return 'bg-red-500';
      case AlertType.Info:
        return 'bg-blue-500';
      case AlertType.Warning:
        return 'bg-yellow-500';
      default:
        return 'bg-blue-500';
    }
  }

  get alertMessage() {
    return this.alertInput() ? this.alertInput()?.message : '';
  }

  get alertType() {
    return this.alertInput() ? this.alertInput()?.type : null;
  }
}
