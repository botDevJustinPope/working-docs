import { inject, Injectable } from '@angular/core';
import { Auth, createUserWithEmailAndPassword, updateProfile, authState } from '@angular/fire/auth';
import { Firestore, collection, addDoc, doc, setDoc } from '@angular/fire/firestore';
import IUser from '../models/user.model';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  #auth = inject(Auth);
  // # is a private field
  #firestore = inject(Firestore);
  // $ is a convention to indicate an observable
  authState$ = authState(this.#auth);

  public async createUser(userData: IUser) {
    try {

      const userCred = await createUserWithEmailAndPassword(
        this.#auth,
        userData.email,
        userData.password
      );

      const docRef = await setDoc(doc(this.#firestore, 'users', userCred.user.uid), {
        name: userData.name,
        email: userData.email,
        age: userData.age,
        phoneNumber: userData.phoneNumber
      });

      await updateProfile(userCred.user, {
        displayName: userData.name
      });

    } catch (e) {
      console.error('Error adding document: ', e);
    }
  }

}
