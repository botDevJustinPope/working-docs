import { serverTimestamp, Timestamp } from "firebase/firestore";
import { IClip } from "./clip.interface";

export class Clip implements IClip {   
    public fid: string = '' 
    public uid: string = ''
    public displayName: string = '';
    public fileTitle: string = '';    
    public fileName: string = '';
    public clipURL: string = '';
    public createdAt: Timestamp;
    public docID?: string;

    constructor(fid:string, uid:string, displayName:string, title:string='', name:string='', url:string='', createdAt?: Timestamp, docID?:string){
        this.fid = fid;
        this.uid = uid;
        this.displayName = displayName;
        this.fileName = name;
        this.fileTitle = title;
        this.clipURL = url;
        this.createdAt = createdAt ?? (serverTimestamp() as unknown as Timestamp);
        if (docID){ this.docID = docID; }
    }

}