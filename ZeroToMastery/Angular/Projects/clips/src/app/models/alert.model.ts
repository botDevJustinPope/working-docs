import { AlertType } from "./enum/alert.enum";

export interface IAlert {
    enabled: boolean,
    type: AlertType|null,
    message: string|null,
}

export class Alert implements IAlert {
    constructor(public enabled: boolean, public type: AlertType|null = null, public message: string|null = null) {}
}