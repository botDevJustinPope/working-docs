import { Injectable, inject } from '@angular/core';
import { Storage, ref, uploadBytesResumable, getDownloadURL } from '@angular/fire/storage';
import { v4 as uuid } from 'uuid';

@Injectable({
  providedIn: 'root'
})
export class UploadsService {
  #storage = inject(Storage);

  uploadfile(file: File) {
    const fileName = uuid();
    const path = `clips/${fileName}.mp4`;
    const clipRef = ref(this.#storage, path);

    uploadBytesResumable(clipRef, file);
  }
  
}
