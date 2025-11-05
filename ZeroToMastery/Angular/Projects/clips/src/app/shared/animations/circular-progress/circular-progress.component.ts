import { Component, computed, Input, signal, effect } from '@angular/core';
import { PercentPipe, NgStyle } from '@angular/common';
import { AlertType } from '../../../models/enum/alert.enum';
import { CircularProgress } from '../../../models/animations/circular-progress/circular-progress.model';

@Component({
  selector: 'app-circular-progress',
  standalone: true,
  imports: [PercentPipe, NgStyle],
  template: `
    <div
      class="relative flex items-center justify-center rounded-full shadow-lg bg-gray-800 mx-auto my-8"
      [ngStyle]="{
        'background-color': backGroundColor()
      }"
      [style.width.px]="containerSize()"
      [style.height.px]="containerSize()"
    >
      <svg
        [attr.width]="svgSize()"
        [attr.height]="svgSize()"
        [attr.viewBox]="'0 0 ' + svgSize() + ' ' + svgSize()"
        class="block"
      >
        <circle
          [attr.r]="percentCircleRadius()"
          [attr.cx]="svgSize() / 2"
          [attr.cy]="svgSize() / 2"
          fill="transparent"
          [attr.stroke]="secondaryColor()"
          [attr.stroke-width]="strokeWidth"
          [attr.stroke-dasharray]="circleCircumference()"
          class="transition-all duration-1000"
        ></circle>
        <circle
          [attr.r]="percentCircleRadius()"
          [attr.cx]="svgSize() / 2"
          [attr.cy]="svgSize() / 2"
          fill="transparent"
          [attr.stroke]="primaryColor()"
          stroke-linecap="round"
          [attr.stroke-width]="strokeWidth"
          [attr.stroke-dasharray]="circleCircumference()"
          [attr.stroke-dashoffset]="alertPercentileCircumference()"
          [attr.transform]="
            'rotate(-90 ' + svgSize() / 2 + ' ' + svgSize() / 2 + ')'
          "
        ></circle>
      </svg>
      <span
        class="absolute inset-0 flex items-center justify-center text-lg font-bold text-white"
      >
        {{ computedPercentage() | percent }}
      </span>
    </div>
  `,
  styles: ``,
})
export class CircularProgressComponent {
  @Input('input') set  inputSetter(value: CircularProgress | undefined) {
    this._progress.set(value ?? new CircularProgress(AlertType.Info, 0, 45));
  }

 private _progress = signal<CircularProgress>( new CircularProgress(AlertType.Info, 0, 45));

  styling = computed(() => this._progress().styling);

  primaryColor = computed(() => {
    // based on the percentage input, 0=> orange-red, 25%=> orange, 50%=> yellow, 75%=> yellow-green, 100%=> green
    // this should be smoothly animated
    const percent = this._progress().animationPercent;
    return `hsl(${(percent * 120)}, 100%, 50%)`;
  });

  secondaryColor = computed(() => {
    // similar to primary color but darker
    const percent = this._progress().animationPercent;
    return `hsl(${(percent * 120) / 100}, 100%, 30%)`;
  });

  backGroundColor = computed(() => {
    switch (this.styling()) {
      case AlertType.Success:
        return 'var(--color-green-900)';
      case AlertType.Error:
        return 'var(--color-red-900)';
      case AlertType.Warning:
        return 'var(--color-yellow-900)';
      default:
      case AlertType.Info:
        return 'var(--color-indigo-900)';
    }
  });

  radius = computed(() => this._progress().radius);
  containerSize = computed(() => this.percentCircleRadius() * 2 + 32); // +32 for padding/margin
  strokeWidth = 10;
  computedPercentage = computed(() => this._progress().animationPercent);

  svgSize = computed(() => this.percentCircleRadius() * 2 + this.strokeWidth);

  percentCircleRadius = computed<number>(() => {
    // Use a default radius, or from input
    const radius = this.radius();
    let rtn = radius != null ? radius : 45;
    return rtn;
  });

  circleCircumference = computed(() => {
    let radius = this.percentCircleRadius();
    return 2 * Math.PI * radius;
  });

  alertPercentileCircumference = computed(() => {
    let percent = this._progress().animationPercent;
    let circumference = this.circleCircumference();
    let rtn = circumference * (1 - percent);
    return rtn;
  });
}
