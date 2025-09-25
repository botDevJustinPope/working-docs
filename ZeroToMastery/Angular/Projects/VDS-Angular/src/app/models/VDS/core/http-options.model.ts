import { HttpOptionType } from "../../../enum/httpOptionType.enum";

export class HttpOptions {
    public type: HttpOptionType = HttpOptionType.VDS;
    public includeAuthTokenHeader: boolean = true;
}
