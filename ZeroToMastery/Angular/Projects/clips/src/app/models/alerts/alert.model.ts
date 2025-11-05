import { UploadTask } from "@angular/fire/storage";
import { CircularProgress } from "../animations/circular-progress/circular-progress.model";
import { AlertType } from "../enum/alert.enum";
import { ButtonConfig } from "./button-config.model";

export interface IAlert {
    enabled: boolean,
    type: AlertType|null,
    message: string|null,
    alertPercent?: CircularProgress|null
    buttons?: ButtonConfig[]|null
}

export class Alert implements IAlert {
    public enabled: boolean;
    public type: AlertType|null;
    public message: string|null;
    public alertPercent?: CircularProgress|null;
    public buttons?: ButtonConfig[]|null;

    constructor(enabled: boolean, 
                type: AlertType|null = null, 
                message: string|null = null, 
                percentProgress?: CircularProgress|null,
                buttons?: ButtonConfig[]|null) {
        this.enabled = enabled;
        this.type = type;
        this.message = message;
        this.alertPercent = percentProgress ?? null;
        this.buttons = buttons ?? null;
    }
}