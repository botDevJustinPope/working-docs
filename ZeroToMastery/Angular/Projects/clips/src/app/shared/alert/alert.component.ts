import { Component, input, signal, computed } from '@angular/core';
import { NgClass,  } from '@angular/common';
import { Alert } from '../../models/alert.model';
import { AlertType } from '../../models/enum/alert.enum';
import { CircularProgressComponent } from '../animations/circular-progress/circular-progress.component';
import { CircularProgress } from '../../models/animations/circular-progress.model';

@Component({
  selector: 'app-alert',
  standalone: true,
  imports: [NgClass, CircularProgressComponent],
  templateUrl: './alert.component.html',
  styleUrl: './alert.component.scss',
})
export class AlertComponent {
  alertInput = input<Alert>(new Alert(false));

  showAlert = computed(() =>
    this.alertInput() ? this.alertInput().enabled : false
  );

  color = computed(() => {
    switch (this.alertType()) {
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
  });

  alertMessage = computed(() => {
    return this.alertInput() ? this.alertInput()?.message : '';
  });

  alertType = computed(() => {
    return this.alertInput() ? this.alertInput()?.type : AlertType.Info;
  });

  alertPercentileInput = computed(() => {
    return this.alertInput()?.alertPercent ?? new CircularProgress();
  });

  showPercentile = computed(() => {
    return this.alertInput()?.alertPercent ? true : false;
  });

}
