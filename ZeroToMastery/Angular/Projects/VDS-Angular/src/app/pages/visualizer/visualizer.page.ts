import { Component, signal, Signal, inject } from '@angular/core';
import { Visualizer } from '../../components/visualizer/visualizer';
import { VisualizerManager, VisualizerProvider } from '../../managers/visualizer.manager';

@Component({
  standalone: true,
  selector: 'app-visualizer-page',
  imports: [Visualizer],
  templateUrl: './visualizer.page.html',
  styleUrl: './visualizer.page.scss',
})
export class VisualizerPage {
  visualizationProvider: Signal<VisualizerProvider> = signal(VisualizerProvider.NONE);    

  #visualizerManager = inject(VisualizerManager);

  constructor() {
  }

}
