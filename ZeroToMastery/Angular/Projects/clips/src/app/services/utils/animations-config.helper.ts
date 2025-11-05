import { Injectable } from '@angular/core';
import { CircularProgress } from '../../models/animations/circular-progress/circular-progress.model';
import { AlertType } from '../../models/enum/alert.enum';

@Injectable({
  providedIn: 'root'
})
export class AnimationsConfigHelper {

  public static generateCircularProgress(percent: number, styling?: AlertType, radius?: number): CircularProgress {
    return new CircularProgress(styling ?? AlertType.Info, percent, radius ?? 45);
  }
  
}
