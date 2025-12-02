import { Injectable, inject } from '@angular/core';
import {
  Storage,
  ref,
  uploadBytesResumable,
  UploadTask,
  getDownloadURL,
  StorageReference,
} from '@angular/fire/storage';
import { DocumentData, DocumentReference, Firestore, addDoc, collection, getDocs, query, where, updateDoc, doc } from '@angular/fire/firestore';
import { AppFile } from '../models/appfile.model';
import { Observable } from 'rxjs';
import { IClip } from '../models/clip.interface';

@Injectable({
  providedIn: 'root',
})
export class UploadsService {
  #storage = inject(Storage);
  #firestore = inject(Firestore);
  #clipsCollection = collection(this.#firestore, 'clips');

  public uploadfile(file: AppFile): UploadTask {
    file.setReference(ref(this.#storage, file.path));

    return uploadBytesResumable(file.fireBaseRef, file.file);
  }

  public async getFileDownloadURL(ref: StorageReference): Promise<string> {
    return await getDownloadURL(ref);
  }

  public async createClip(appFile: AppFile) : Promise<DocumentReference<DocumentData, DocumentData> | null> {
    try {
      return await addDoc(this.#clipsCollection, appFile.clipsInterface());
    } catch (err) {
      console.error('caught error:', err);
    }
    return null;
  }

  public async getClipsByUser(userId: string): Promise<Array<IClip>> {
    let clips: Array<IClip> = [];
    try {
      const clipsQuery = query(this.#clipsCollection, where('uid', '==', userId));
      const querySnapshot = await getDocs(clipsQuery);
      querySnapshot.forEach(doc => {
        const data = doc.data() as IClip;
        clips.push(data);
      });
    } catch (err) {
      console.error('caught error:', err);
    }
    return clips;
  }

  public async getClipById(clipId: string): Promise<IClip | null> {
    let rtnData: IClip | null = null;
    try {
      const clipsQuery = query(this.#clipsCollection, where('fid', '==', clipId));
      const querySnapshot = await getDocs(clipsQuery);
      querySnapshot.forEach(doc => {
        const data = doc.data() as IClip;
        rtnData = data;
      });
    } catch (err) {
      console.error('caught error:', err);
    }
    return rtnData;
  }

  public async updateClip(id:string, fileTitle: string): Promise<void> {
    try {
      const clipRef = await doc(this.#firestore, 'clips/' + id);
      await updateDoc(clipRef, {
        fileTitle: fileTitle
      });
    } catch (err) {
      console.error('caught error:', err);
    }
  }
}
