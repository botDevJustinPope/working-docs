import { StorageReference } from '@angular/fire/storage';
import { FileData } from './fileData.model';
import { Clip } from './clip.model';
import { IClip } from './clip.interface';
import { User } from '@angular/fire/auth';

export class AppFile {

    public static maxFileSizeInMB: number = 25;
    public static maxFileSizeInB: number =  this.maxFileSizeInMB * 1024 * 1024; // 25MB

    public clip: Clip;

    public data : FileData;

    private _fireBaseRef: StorageReference = null as unknown as StorageReference;

    constructor(file: File, user:User) {
        this.data = new FileData(file);
        this.clip = new Clip(this.data.id, user.uid, user.displayName as string, '', this.data.path(), '');
        console.log('construction ',this.clip)
    }
    
    public get fireBaseRef(): StorageReference {
        return this._fireBaseRef;
    } 

    public setReference(ref: StorageReference) {
        this._fireBaseRef = ref;
    }

    public get path(): string {
        return this.data.path();
    }

    public get file(): File {
        return this.data.file;
    }

    public clipsInterface(): IClip {
        return {
            fid: this.clip.fid,
            uid: this.clip.uid,
            displayName: this.clip.displayName,
            fileTitle: this.clip.fileTitle,
            fileName: this.clip.fileName,
            clipURL: this.clip.clipURL,
            createdAt: this.clip.createdAt
        };
    }

    get isValidType(): boolean {
        switch(this.data.file.type) {
            case ValidMimeTypes.Mp4:
                return true;
            default:
                return false;
        }
    }

    get isValidFileSize(): boolean {
        return (AppFile.maxFileSizeInB >= this.data.file.size);
    }
}

export enum ValidMimeTypes {
    Mp4 = 'video/mp4'
}