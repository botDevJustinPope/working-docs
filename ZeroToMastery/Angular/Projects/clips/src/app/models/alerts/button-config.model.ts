import { AlertType } from "../enum/alert.enum";

export class ButtonConfig {
    public Style: AlertType;
    public Label: string;
    public CallbackPrimary: () => void;
    public CallbackSecondary?: () => void;
    public Icon?: string;
    public SecondaryIcon?: string;

    constructor(style: AlertType, label: string, callbackPrimary: () => void, callbackSecondary?: () => void, icon?: string, secondaryIcon?: string) {
        this.Style = style;
        this.Label = label;
        this.CallbackPrimary = callbackPrimary;
        this.CallbackSecondary = callbackSecondary;
        this.Icon = icon;
        this.SecondaryIcon = secondaryIcon;
    }

    private hasSecondaryCallback(): boolean {
        return this.CallbackSecondary !== undefined;
    }

    private buttonClickState: 'primary' | 'secondary' = 'primary';

    public executeButtonClick(): void {
        if (this.buttonClickState === 'primary') {
            this.CallbackPrimary();
            if (this.hasSecondaryCallback()) {
                this.buttonClickState = 'secondary';
            }
        } else if (this.hasSecondaryCallback()) {
            this.CallbackSecondary!();
            this.buttonClickState = 'primary';
        }
    }

    public getCurrentIcon(): string | undefined {
        switch (this.buttonClickState) {
            case 'primary':
            default:
                return this.Icon;
            case 'secondary':
                return this.SecondaryIcon;
        }
    }

    public get cssClasses(): string {
        switch (this.Style) {
            case AlertType.Success:
                return 'bg-green-600 hover:bg-green-700 text-white font-bold py-2 px-4 rounded';
            case AlertType.Error:
                return 'bg-red-600 hover:bg-red-700 text-white font-bold py-2 px-4 rounded';
            case AlertType.Warning:
                return 'bg-yellow-600 hover:bg-yellow-700 text-white font-bold py-2 px-4 rounded';
            case AlertType.Info:
            default:
                return 'bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded';
        }
    }
}
