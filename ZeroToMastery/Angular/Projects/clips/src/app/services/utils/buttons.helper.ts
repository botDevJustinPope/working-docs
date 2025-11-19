import { Injectable } from '@angular/core';
import { ButtonConfig } from '../../models/alerts/button-config.model';
import { UploadTask } from '@angular/fire/storage';
import { AlertType } from '../../models/enum/alert.enum';
import { Alert } from '../../models/alerts/alert.model';

@Injectable({
  providedIn: 'root',
})
export class ButtonsHelper {
  public static generateButtonBasic(
    type: AlertType,
    label: string,
    primaryCallback: () => void,
    icon: string
  ): ButtonConfig {
    return new ButtonConfig(type, label, primaryCallback, icon);
  }

  public static generateButtonWithSecondary(
    type: AlertType,
    label: string,
    primaryCallback: () => void,
    icon: string,
    secondaryLabel: string,
    secondaryStyle: AlertType,
    secondaryCallback: () => void,
    secondaryIcon: string
  ): ButtonConfig {
    return new ButtonConfig(
      type,
      label,
      primaryCallback,
      icon,
      secondaryStyle,
      secondaryLabel,
      secondaryCallback,
      secondaryIcon
    );
  }

  public static generateButtonsForUploadTask(
    uploadTask: UploadTask
  ): ButtonConfig[] {
    const pauseResumeButton = ButtonsHelper.generateButtonWithSecondary(
      AlertType.Warning,
      'pause',
      () => uploadTask.pause(),
      'pause',
      'play',
      AlertType.Success,
      () => uploadTask.resume(),
      'play'
    );
    const cancelButton = ButtonsHelper.generateButtonBasic(
      AlertType.Error,
      'stop',
      () => uploadTask.cancel(),
      'stop'
    );
    console.log('pauseResumeButton', pauseResumeButton);
    console.log('cancelButton', cancelButton);
    return [pauseResumeButton, cancelButton];
  }

  public static buttonsAreEqual(btn1: ButtonConfig, btn2: ButtonConfig): boolean {
    return (btn1.Label === btn2.Label &&
           btn1.Style === btn2.Style &&
           btn1.Icon === btn2.Icon &&
           btn1.SecondaryLabel === btn2.SecondaryLabel &&
           btn1.SecondaryStyle === btn2.SecondaryStyle &&
           btn1.SecondaryIcon === btn2.SecondaryIcon );
  }
}
