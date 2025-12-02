import {
  Component,
  input,
  computed,
  Signal,
  WritableSignal,
  signal,
  effect,
} from '@angular/core';
import { NgClass } from '@angular/common';
import { Alert } from '../../models/alerts/alert.model';
import { AlertType } from '../../models/enum/alert.enum';
import { CircularProgressComponent } from '../animations/circular-progress/circular-progress.component';
import { CircularProgress } from '../../models/animations/circular-progress/circular-progress.model';
import { ButtonComponent } from '../button/button.component';
import {
  ButtonConfig,
  IButtonConfig,
} from '../../models/alerts/button-config.model';

@Component({
  selector: 'app-alert',
  standalone: true,
  imports: [NgClass, CircularProgressComponent, ButtonComponent],
  templateUrl: './alert.component.html',
  styleUrl: './alert.component.scss',
})
export class AlertComponent {
  alertInput = input<Alert>(new Alert(false));

  alertPercentileInput = input<CircularProgress | null>(null);

  alertButtonsInput = input<IButtonConfig[] | null>(null);

  constructor() {
    effect(() => {
      if (this.alertInput()) {
        this.enabled.set(this.alertInput().enabled);
        let type = this.alertInput().type;
        if (type) {
          this.alertType.set(type);
        }
        let msg = this.alertInput().message;
        if (msg) {
          this.alertMessage.set(msg);
        }
      }
      if (this.alertInput().alertPercent) {
        this.alertPercentile.set(this.alertInput().alertPercent!);
      }
      if (this.alertInput().buttons) {
        this.alertButtons.set(this.alertInput().buttons!);
      }
    });
    effect(() => {
      if (this.alertPercentileInput()) {
        this.alertPercentile.set(this.alertPercentileInput()!);
      }
    });
    effect(() => {
      if (this.alertButtonsInput()) {
        this.alertButtons.set(this.alertButtonsInput()!);
      }
    });
  }

  enabled = signal<boolean>(false);
  alertType = signal<AlertType>(AlertType.Info);
  alertMessage = signal<string>('');

  showPercentile = computed(() => {
    return this.alertPercentile() ? true : false;
  });

  alertPercentile: WritableSignal<CircularProgress | null> = signal(null);

  showButtons = computed(() => {
    return (this.alertButtons().length ?? 0) > 0;
  });

  alertButtons: WritableSignal<ButtonConfig[]> = signal([]);

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
}
