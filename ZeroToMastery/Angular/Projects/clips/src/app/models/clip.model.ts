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

    constructor(fid:string, uid:string, displayName:string, title:string='', name:string='', url:string=''){
        this.fid = fid;
        this.uid = uid;
        this.displayName = displayName;
        this.fileName = name;
        this.fileTitle = title;
        this.clipURL = url;
        this.createdAt = serverTimestamp() as Timestamp;
    }

}