export class AuthenticateResponseDTO {
    public HasError: boolean = false;
    public Error: string = '';
    public Authenticated: boolean = false;
    public SecurityToken: string = '';
    public MustChangePassword: boolean = false;
    public MustAcceptTermsOfService: boolean = false;
    public UserId: string = '';
    public Token: string = '';
}
