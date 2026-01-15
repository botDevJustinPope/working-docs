import { inject, Injectable, signal } from '@angular/core';
import { AareasService } from '../services/aareas.service';

@Injectable({
    providedIn: 'root'
})
export class VisualizerManager {
    aareasService = inject(AareasService);

    public provider = signal<VisualizerProvider>(VisualizerProvider.NONE);

    public setProvider(provider: VisualizerProvider) {
        this.provider.set(provider);
    }

    public async getRender(parms: any): Promise<string> {
        switch (this.provider()) {
            case VisualizerProvider.AAREAS:
                try {
                    const renderData = await this.aareasService.getSceneRender(
                        parms.sceneId,
                        parms.room,
                        parms.applications,
                        parms.packages
                    );
                    return renderData.frameURL;
                } catch (error) {
                    console.error('Error fetching Aareas render:', error);
                    return '';
                }
            default:
                console.warn('No valid visualizer provider selected.');
                return '';
        }
    }
}

export function VisualizerProviderENUMtoString(provider: VisualizerProvider): string {
    switch (provider) {
        case VisualizerProvider.AAREAS:
            return 'Aareas';
        default:
            return 'None';
    }
}

export function VisualizerProviderStringToENUM(provider: string): VisualizerProvider {
    switch (provider.toUpperCase()) {
        case 'AAREAS':
            return VisualizerProvider.AAREAS;
        default:
            return VisualizerProvider.NONE;
    }
}

export enum VisualizerProvider {
    AAREAS = 'AAREAS',
    NONE = 'NONE'
}