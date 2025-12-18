import { Injectable, signal } from '@angular/core';
import { createFFmpeg, FFmpeg } from '@ffmpeg/ffmpeg';

@Injectable({
  providedIn: 'root',
})
export class FfmpegService {
  isReady = signal(false);
  isLoading = signal(false);
  ffmpeg = createFFmpeg({
    log: true,
  });

  constructor() {}

  async init(force: boolean = false) {
    if (this.isReady() && !force) return;
    if (this.isLoading()) return;

    this.isLoading.set(true);
    try {
      await this.ffmpeg.load();
      this.isReady.set(true);
    } catch (error) {
      console.error('FFmpeg load error:', error);
    } finally {
      this.isLoading.set(false);
    }
  }
}
