import { Component, signal, effect, inject } from '@angular/core';
import { VisualizerManager } from '../../managers/visualizer.manager';

@Component({
  selector: 'app-visualizer',
  imports: [],
  templateUrl: './visualizer.html',
  styleUrl: './visualizer.scss',
})
export class Visualizer {
  renderableObject = signal<string | null>(null);
  isIframeActive = signal<boolean>(false);

  #visualizerManager = inject(VisualizerManager);

  constructor() {
    // Set up effects
    this.initIsIframeActive();
  }

  public initIsIframeActive() {
    // Update isIframeActive whenever renderableObject changes
    effect(() => {
      this.isIframeActive.set(
        !!this.renderableObject() && this.renderableObject() !== ''
      );
    });
  }

  public async setRender(parms: any) {
    try {
      parms = {
        sceneId: 2560
      }
      const renderUrl = await this.#visualizerManager.getRender(parms);
      this.renderableObject.set(renderUrl);
    } catch (error) {
      console.error('Error setting render:', error);
      this.renderableObject.set(null);
    }
  }
}