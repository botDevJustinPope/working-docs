import { Component, computed, input, signal, effect } from '@angular/core';
import { PercentPipe, NgStyle } from '@angular/common';
import { AlertType } from '../../../models/enum/alert.enum';
import { CircularProgress } from '../../../models/animations/circular-progress.model';

@Component({
  selector: 'app-circular-progress',
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
        {{ alertPercentileDisplay() | percent }}
      </span>
    </div>
  `,
  styles: ``,
})
export class CircularProgressComponent {
  input = input<CircularProgress>(new CircularProgress(AlertType.Info, 0, 45));
  styling = computed(() => this.input().styling);
  targetPercent = computed(() => this.input().animationPercent);
  radius = computed(() => this.input().radius);

  private animatedValue = signal(0);
  animatedPercentage = computed(() => this.animatedValue());

  constructor() {
    effect(() => {
      const target = this.targetPercent();
      this.animateToValue(target);
    });
  }

  private animateToValue(targetValue: number) {
    const startValue = this.animatedValue();
    const duration = 500; // 500ms animation
    const startTime = performance.now();

    const animate = (currentTime: number) => {
      const elapsed = currentTime - startTime;
      const progress = Math.min(elapsed / duration, 1);

      // Ease out cubic function for smooth animation
      const easeOut = 1 - Math.pow(1 - progress, 3);
      const currentValue = startValue + (targetValue - startValue) * easeOut;

      this.animatedValue.set(currentValue);

      if (progress < 1) {
        requestAnimationFrame(animate);
      }
    };

    requestAnimationFrame(animate);
  }

  primaryColor = computed(() => {
    // based on the percentage input, 0=> orange-red, 25%=> orange, 50%=> yellow, 75%=> yellow-green, 100%=> green
    // this should be smoothly animated
    const percent = this.animatedPercentage() * 100;
    return `hsl(${(percent * 120) / 100}, 100%, 50%)`;
  });

  secondaryColor = computed(() => { 
    // similar to primary color but darker
    const percent = this.animatedPercentage() * 100;
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

  computedPercentage = computed(() => {
    // Ensure percentage is between 0 and 100%
    let percent = this.animatedPercentage();
    let rtn = Math.max(0, Math.min(percent * 100, 100));
    return rtn;
  });

  containerSize = computed(() => this.percentCircleRadius() * 2 + 32); // +32 for padding/margin
  strokeWidth = 10;

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
    let percent = this.computedPercentage();
    let circumference = this.circleCircumference();
    let rtn = circumference * (1 - percent / 100);
    return rtn;
  alertPercentileDisplay = computed(() => {
    // Display as a value between 0 and 1 for percent pipe
    let rtn = Math.max(0, Math.min(this.animatedPercentage(), 1));
    return rtn;
  });
    return rtn;
  });
}
