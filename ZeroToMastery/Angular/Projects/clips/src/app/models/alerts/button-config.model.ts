import { AlertType } from '../enum/alert.enum';

export interface IButtonConfig {
  Style: AlertType;
  Label: string;
  CallbackPrimary: () => void;
  Icon?: string;
  SecondaryStyle?: AlertType;
  SecondaryLabel?: string;
  CallbackSecondary?: () => void;
  SecondaryIcon?: string;
}

export class ButtonConfig implements IButtonConfig {
  public Style: AlertType;
  public Label: string;
  public CallbackPrimary: () => void;
  public Icon?: string;
  public SecondaryStyle?: AlertType;
  public SecondaryLabel?: string;
  public CallbackSecondary?: () => void;
  public SecondaryIcon?: string;

  constructor(
    style: AlertType,
    label: string,
    callbackPrimary: () => void,
    icon?: string,
    secondaryStyle?: AlertType,
    secondaryLabel?: string,
    callbackSecondary?: () => void,
    secondaryIcon?: string
  ) {
    this.Style = style;
    this.Label = label;
    this.CallbackPrimary = callbackPrimary;
    this.Icon = icon;
    this.SecondaryStyle = secondaryStyle;
    this.SecondaryLabel = secondaryLabel;
    this.CallbackSecondary = callbackSecondary;
    this.SecondaryIcon = secondaryIcon;
  }
}
