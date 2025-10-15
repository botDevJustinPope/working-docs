import { Injectable, inject } from '@angular/core';
import { Storage, ref, uploadBytesResumable, UploadTask } from '@angular/fire/storage';
import { AppFile } from '../models/file.model';

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
