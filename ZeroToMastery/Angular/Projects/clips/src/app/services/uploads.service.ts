import { Injectable, inject } from '@angular/core';
import { Storage, ref, uploadBytesResumable, getDownloadURL, UploadTask } from '@angular/fire/storage';
import { v4 as uuid } from 'uuid';
import { AppFile } from '../models/file.model';
import { UpdateData } from '@angular/fire/firestore';

@Injectable({
  providedIn: 'root'
})
export class UploadsService {
  #storage = inject(Storage);

  uploadfile(file: AppFile): UploadTask {
    file.setReference(ref(this.#storage, file.path));

    return uploadBytesResumable(file.fireBaseRef, file.file);

  }
  
}
