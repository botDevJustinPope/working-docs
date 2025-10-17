import { Component, input, signal, computed } from '@angular/core';
import { NgClass, PercentPipe } from '@angular/common';
import { Alert } from '../../models/alert.model';
import { AlertType } from '../../models/enum/alert.enum';

@Component({
  selector: 'app-alert',
  standalone: true,
  imports: [NgClass, PercentPipe],
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

  showPercentile = computed(() => {
    return this.alertInput()
      ? this.alertInput()?.percentile !== null &&
          this.alertInput()?.percentile !== undefined
      : false;
  });

  alertPercentile = computed(() => {
    return this.alertInput() && this.alertInput().percentile
      ? this.alertInput()?.percentile
      : null;
  });
  containerSize = computed(() => this.percentCircleRadius() * 2 + 32); // +32 for padding/margin
  strokeWidth = 10;

  percentCircleRadius = computed<number>(() => {
    // Use a default radius, or from input
    const radius = this.alertInput()?.radius;
    let rtn = radius != null ? radius : 45;
    console.log('percentCircleRadius', rtn);
    return rtn;
  });

  svgSize = computed(() => this.percentCircleRadius() * 2 + this.strokeWidth);

  circleCircumference = computed(() => {
    let radius = this.percentCircleRadius();
    return 2 * Math.PI * radius;
  });

  alertPercentileCircumference = computed(() => {
    let percent = this.alertPercentile() ?? 0;
    let circumference = this.circleCircumference();
    let rtn = circumference * (1 - percent / 100);
    console.log('alertPercentileCircumference', rtn);
    return rtn;
  });

  alertPercentileDisplay = computed(() => {
    let rtn = this.alertPercentile()?.toFixed(2);
    console.log('alertPercentileDisplay', rtn);
    return rtn;
  });
}
