import { StorageReference } from '@angular/fire/storage';
import { v4 as uuid } from 'uuid';

export class AppFile {

    public id: string = uuid();
    
    public path: string = `clips/${this.id}.mp4`;

    public file: File;

    private _fireBaseRef: StorageReference = null as unknown as StorageReference;
    
    public get fireBaseRef(): StorageReference {
        return this._fireBaseRef;
    } 

    constructor(file: File) {
        this.file = file;
    }

    public setReference(ref: StorageReference) {
        this._fireBaseRef = ref;
    }

    get isValidType(): boolean {
        switch(this.file.type) {
            case ValidMimeTypes.Mp4:
                return true;
            default:
                return false;
        }
    }
}

export enum ValidMimeTypes {
    Mp4 = 'video/mp4'
}