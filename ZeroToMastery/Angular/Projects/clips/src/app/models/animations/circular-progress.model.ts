import { AlertType } from "../enum/alert.enum";

export class CircularProgress {
    public styling: AlertType;
    public animationPercent: number;
    public radius: number;

    constructor(styling: AlertType = AlertType.Info, animationPercent: number = 0, radius: number = 45) {
        this.styling = styling;
        this.animationPercent = animationPercent;
        this.radius = radius;
    }
}
