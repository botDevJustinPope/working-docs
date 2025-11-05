import { Injectable } from '@angular/core';
import { ButtonConfig } from '../../models/alerts/button-config.model';
import { UploadTask } from '@angular/fire/storage';
import { AlertType } from '../../models/enum/alert.enum';

@Injectable({
  providedIn: 'root'
})
export class ButtonsHelper {
  
  public static generateButtonBasic(type: AlertType,label:string, primaryCallback: () => void, icon:string): ButtonConfig {
    return new ButtonConfig(type, label, primaryCallback, undefined, icon);
  }

  public static generateButtonWithSecondary(type: AlertType,label:string, primaryCallback: () => void, secondaryCallback: () => void, icon:string, secondaryIcon:string): ButtonConfig {
    return new ButtonConfig(type, label, primaryCallback, secondaryCallback, icon, secondaryIcon);
  }

  public static generateButtonsForUploadTask(uploadTask: UploadTask): ButtonConfig[] {
    const pauseResumeButton = ButtonsHelper.generateButtonWithSecondary(AlertType.Warning,'', () => uploadTask.pause(), () => uploadTask.resume(), 'pause', 'play');
    const cancelButton = ButtonsHelper.generateButtonBasic(AlertType.Error, '', () => uploadTask.cancel(), 'stop');
    return [pauseResumeButton, cancelButton];
  }
  
}
