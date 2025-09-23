import { AlertType } from "./enum/alert.enum";

export interface IAlert {
    type: AlertType,
    message: string,
}

export class Alert implements IAlert {
    constructor(public type: AlertType, public message: string) {}
}