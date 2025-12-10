export class VDS_button {
    name: string = '';
    url: string = '';
}

export class VDS_Dashboard {
    public buttons: VDS_button[] = [];

    public init():void {
        console.log('VDS_Dashboard initialized');
        this.buttons.push({name: 'DEV VDS', url: 'https://dev.veodesignstudcio.com/?iss='})

    }
}