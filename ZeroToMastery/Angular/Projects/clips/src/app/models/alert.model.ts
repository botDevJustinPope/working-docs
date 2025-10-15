import { AlertType } from "./enum/alert.enum";

export interface IAlert {
    enabled: boolean,
    type: AlertType|null,
    message: string|null,
    percentile?: number|null,
    radius?: number|null
}

export class Alert implements IAlert {
    constructor(public enabled: boolean, 
                public type: AlertType|null = null, 
                public message: string|null = null, 
                public percentile?: number|null,
                public radius?: number|null) {}
}