import { computed, inject, Injectable, signal } from '@angular/core';
import {
  Auth,
  createUserWithEmailAndPassword,
  updateProfile,
  authState,
  signInWithEmailAndPassword,
  signOut,
  fetchSignInMethodsForEmail,
} from '@angular/fire/auth';
import {
  Firestore,
  doc,
  setDoc,
} from '@angular/fire/firestore';
import IUser from '../models/user.model';
import { ILogin } from '../models/login.model';
import { delay, combineLatestWith } from 'rxjs/operators';
import { RouteNames } from '../app.routes';
import { RoutesService } from './routes.service';

@Injectable({
  providedIn: 'root', 
})
export class AuthService {
  #auth = inject(Auth);
  // # is a private field
  #firestore = inject(Firestore);
  // $ is a convention to indicate an observable
  authState$ = authState(this.#auth);
  authStateWithDelay$ = this.authState$.pipe(delay(1000));

  routesService = inject(RoutesService);

  currentUser = computed(() => this.#auth.currentUser);

  constructor() {
    this.init();
   }

  private init() {
    this.initAuthRedirect();
  }

  private initAuthRedirect() {
    this.routesService.routeData$.pipe(
      combineLatestWith(this.authState$)
    ).subscribe(([routeData, user]) => {
      if (routeData?.authOnly && !user) {
        this.routesService.navigateToRoute(RouteNames.Home);
      }
    })
  }

  public async createUser(userData: IUser) {
    try {
      const userCred = await createUserWithEmailAndPassword(
        this.#auth,
        userData.email,
        userData.password
      );

      const docRef = await setDoc(
        doc(this.#firestore, 'users', userCred.user.uid),
        {
          name: userData.name,
          email: userData.email,
          age: userData.age,
          phoneNumber: userData.phoneNumber,
        }
      );

      await updateProfile(userCred.user, {
        displayName: userData.name,
      });
    } catch (e) {
      console.error('Error adding document: ', e);
      throw e;
    }
  }

  public async logIn(userCredentials: ILogin) {
    try {
      const userCred = await signInWithEmailAndPassword(
        this.#auth,
        userCredentials.email,
        userCredentials.password
      );
    } catch (e) {
      console.error('Error logging in: ', e);
      throw e;
    }
  }

  public async logOut() {
    try {
      await signOut(this.#auth);
    } catch (e) {
      console.error('Error logging out: ', e);
      throw e;
    }
  }

  public async doesEmailExist(email: string): Promise<string[]> {
    let rtn: string[] = [];
    try {
      rtn = await fetchSignInMethodsForEmail(this.#auth, email);
    } catch (e) {
      console.error('Error checking email: ', e);
      throw e;
    }
    return rtn;
  }

}
