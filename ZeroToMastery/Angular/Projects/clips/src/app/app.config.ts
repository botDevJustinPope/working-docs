import { ApplicationConfig, inject, provideAppInitializer, provideZoneChangeDetection } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideFirebaseApp, initializeApp } from '@angular/fire/app';
import { provideAuth, getAuth } from '@angular/fire/auth';
import { provideFirestore, getFirestore } from '@angular/fire/firestore';
import { provideStorage, getStorage } from '@angular/fire/storage';
import { routes } from './app.routes';

export const appConfig: ApplicationConfig = {
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes),
    provideFirebaseApp(() =>
      initializeApp(
        // clips's Firebase configuration
        {
          apiKey: 'AIzaSyDfpeTLLxQ3S44-d5TIho31fDmkcoJIU1A',
          authDomain: 'clips-bfb31.firebaseapp.com',
          projectId: 'clips-bfb31',
          storageBucket: 'clips-bfb31.firebasestorage.app',
          messagingSenderId: '48076583695',
          appId: '1:48076583695:web:f0f0d43398369f5674447a',
        }
      )
    ),
    provideAuth(() => getAuth()),
    provideFirestore(() => getFirestore()),
    provideStorage(() => getStorage()),
  ],
};
