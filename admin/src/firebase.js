import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';
import { getStorage } from 'firebase/storage';

const firebaseConfig = {
  apiKey: 'AIzaSyCAUA2qK41jnftXP_g2yx-P4yYyZwWgA_U',
  authDomain: 'tingungu-sa.firebaseapp.com',
  projectId: 'tingungu-sa',
  storageBucket: 'tingungu-sa.firebasestorage.app',
  messagingSenderId: '226294099341',
  appId: '1:226294099341:android:6cbb7d031dae132b1e61c4',
};

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);
export default app;
