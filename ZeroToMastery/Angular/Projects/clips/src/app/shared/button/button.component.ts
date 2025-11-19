import { Component, input, computed, signal } from '@angular/core';
import { NgClass } from '@angular/common';
import { ButtonConfig } from '../../models/alerts/button-config.model';
import { AlertType } from '../../models/enum/alert.enum';

@Component({
  standalone: true,
  selector: 'app-button',
  imports: [NgClass],
  templateUrl: './button.component.html',
  styleUrl: './button.component.scss'
})
export class ButtonComponent {
  buttonInput = input<null | ButtonConfig>(null);

  private isInputValid = computed(() => this.buttonInput() !== null);

  private buttonConfig = computed(() => {
    if (this.isInputValid()) {
      return this.buttonInput()!;
    } else {
      return new ButtonConfig(AlertType.Error, 'ERROR_INVALID_BUTTON', () => {});
    }
  });

  private isSecondaryConfigured = computed(() => {
    if (this.isInputValid()) {
      return this.buttonConfig().CallbackSecondary !== undefined;
     }
    return false;
  });

  
  private buttonClickState = signal<'primary' | 'secondary'>('primary');

  public displayLabel = computed<string>(() => {
    if (this.buttonClickState() === 'secondary' && this.isSecondaryConfigured()) {
      return this.buttonConfig().SecondaryLabel!;
    }
    return this.buttonConfig().Label;
  });

  public executeButtonClick(): void {
    console.log('Button clicked:', this.displayLabel());
    if (this.buttonClickState() === 'secondary' && this.isSecondaryConfigured()) {
      this.buttonConfig().CallbackSecondary!();
      this.buttonClickState.set('primary');
    } else {
      this.buttonConfig().CallbackPrimary();
      if (this.isSecondaryConfigured()) {
        this.buttonClickState.set('secondary');
      }
    }
  }

  public isIconConfigured = computed(() => this.buttonIcon() !== undefined);

  public buttonIcon = computed(() => {
    if (this.buttonClickState() === 'secondary' && this.isSecondaryConfigured()) {
      return this.buttonConfig().SecondaryIcon;
    }
    return this.buttonConfig().Icon;
  })
  
  public cssClasses = computed(() => {
    if (!this.isInputValid()) return '';

    let style = this.buttonConfig().Style;
    if (this.buttonClickState() === 'secondary' && this.isSecondaryConfigured()) {
      style = this.buttonConfig().SecondaryStyle!;
    }

    switch (style) {
      case AlertType.Success:
        return 'bg-green-600 hover:bg-green-700 text-white font-bold py-2 px-4 rounded';
      case AlertType.Error:
        return 'bg-red-600 hover:bg-red-700 text-white font-bold py-2 px-4 rounded';
      case AlertType.Warning:
        return 'bg-yellow-600 hover:bg-yellow-700 text-white font-bold py-2 px-4 rounded';
      case AlertType.Info:
      default:
        return 'bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded';
    }
  })

}
