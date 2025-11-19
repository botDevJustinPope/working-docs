import { Injectable, inject } from '@angular/core';
import {
  Storage,
  ref,
  uploadBytesResumable,
  UploadTask,
  getDownloadURL,
  StorageReference,
} from '@angular/fire/storage';
import { DocumentData, DocumentReference, Firestore, addDoc, collection } from '@angular/fire/firestore';
import { AppFile } from '../models/appfile.model';
import { Observable } from 'rxjs';

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
}
