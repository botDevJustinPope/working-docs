import { Injectable, inject } from '@angular/core';
import {
  Storage,
  ref,
  uploadBytesResumable,
  UploadTask,
  fromTask,
  UploadTaskSnapshot,
} from '@angular/fire/storage';
import { AppFile } from '../models/file.model';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class UploadsService {
  #storage = inject(Storage);
  uploadfile(file: AppFile): Observable<UploadTaskSnapshot> {
    file.setReference(ref(this.#storage, file.path));

    return fromTask(uploadBytesResumable(file.fireBaseRef, file.file));
  }
}
