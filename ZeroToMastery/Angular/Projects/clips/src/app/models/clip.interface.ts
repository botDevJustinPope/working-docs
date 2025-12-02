import { Timestamp } from "@angular/fire/firestore";

export interface IClip {
    docID?: string;    
    fid: string;
    uid: string;
    displayName: string;
    fileTitle: string;   
    fileName: string;
    clipURL: string;
    createdAt: Timestamp;
}