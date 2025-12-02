import { Injectable, inject } from '@angular/core';
import {
  Storage,
  ref,
  uploadBytesResumable,
  UploadTask,
  getDownloadURL,
  StorageReference,
  deleteObject
} from '@angular/fire/storage';
import {
  DocumentData,
  DocumentReference,
  Firestore,
  addDoc,
  collection,
  getDocs,
  query,
  where,
  updateDoc,
  doc,
  QueryDocumentSnapshot,
  deleteDoc
} from '@angular/fire/firestore';
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

  public async createClip(
    appFile: AppFile
  ): Promise<DocumentReference<DocumentData, DocumentData> | null> {
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
      const clipsQuery = query(
        this.#clipsCollection,
        where('uid', '==', userId)
      );
      const querySnapshot = await getDocs(clipsQuery);
      querySnapshot.forEach((doc) => {
        clips.push(this.getClipFromDoc(doc));
      });
    } catch (err) {
      console.error('caught error:', err);
    }
    return clips;
  }

  public async getClipById(clipId: string): Promise<IClip | null> {
    let rtnData: IClip | null = null;
    try {
      const clipsQuery = query(
        this.#clipsCollection,
        where('fid', '==', clipId)
      );
      const querySnapshot = await getDocs(clipsQuery);
      querySnapshot.forEach((doc) => {
        rtnData = this.getClipFromDoc(doc);
      });
    } catch (err) {
      console.error('caught error:', err);
    }
    return rtnData;
  }

  private getClipFromDoc(
    doc: QueryDocumentSnapshot<DocumentData, DocumentData>
  ): IClip {
    return {
      docID: doc.id,
      ...doc.data(),
    } as IClip;
  }

  public async updateClip(id: string, fileTitle: string): Promise<void> {
    try {
      const clipRef = await doc(this.#firestore, 'clips/' + id);
      await updateDoc(clipRef, {
        fileTitle: fileTitle,
      });
    } catch (err) {
      console.error('caught error:', err);
    }
  }

  public async deleteClip(clip: IClip): Promise<void> {
    try {
      // Delete the file from storage
      const fileRef = ref(this.#storage, clip.fid);
      if (fileRef) {
        await deleteObject(fileRef);
      }    
    } catch (err) {
      console.error('caught error deleting file from storage:', err);
    }

    try {
      // Delete the document from firestore
      if (clip.docID) {
        const clipDocRef = doc(this.#firestore, 'clips/' + clip.docID);
        await deleteDoc(clipDocRef);
      }      
    } catch (err) {
      console.error('caught error deleting document from firestore:', err);
    }
    
  } 
}
