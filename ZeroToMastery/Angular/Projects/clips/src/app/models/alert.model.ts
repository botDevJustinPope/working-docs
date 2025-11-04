import { CircularProgress } from "./animations/circular-progress.model";
import { AlertType } from "./enum/alert.enum";

export interface IAlert {
    enabled: boolean,
    type: AlertType|null,
    message: string|null,
    alertPercent?: CircularProgress|null
}

export class Alert implements IAlert {
    public enabled: boolean;
    public type: AlertType|null;
    public message: string|null;
    public alertPercent?: CircularProgress|null;

    constructor(enabled: boolean, 
                type: AlertType|null = null, 
                message: string|null = null, 
                percentile?: number|null,
                radius?: number|null) {
        this.enabled = enabled;
        this.type = type;
        this.message = message;
        this.alertPercent = null;

        if (percentile !== null && percentile !== undefined) {
            const radiusValue = radius ?? 45;
            const typeValue = type ?? AlertType.Info;
            let percentileValue = percentile ?? 0;
            if (percentileValue > 1) {
                percentileValue = Math.min(percentileValue/100, 1);
            }
            this.alertPercent = new CircularProgress(typeValue, percentileValue, radiusValue);
        }
    }
}