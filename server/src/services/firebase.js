require('dotenv').config({ path: require('path').join(__dirname, '..', '..', '.env') });

let admin = null;
let firebaseApp = null;

function initFirebase() {
  if (firebaseApp) return firebaseApp;

  try {
    admin = require('firebase-admin');
  } catch {
    console.warn('firebase-admin non installé. Exécutez: npm install firebase-admin');
    return null;
  }

  const keyPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT;
  const projectId = process.env.FIREBASE_PROJECT_ID || 'muslim-ia';

  try {
    if (serviceAccountJson) {
      // Préféré pour les plateformes d'hébergement (Render, Vercel…) :
      // le contenu complet du fichier de compte de service dans une variable d'environnement.
      const serviceAccount = JSON.parse(serviceAccountJson);
      console.log(`[firebase] init via FIREBASE_SERVICE_ACCOUNT sa.project_id=${serviceAccount.project_id} → projectId effectif=${projectId}`);
      firebaseApp = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        projectId,
      });
    } else if (keyPath) {
      const path = require('path');
      const resolvedKeyPath = path.isAbsolute(keyPath)
        ? keyPath
        : path.join(__dirname, '..', '..', keyPath);
      const serviceAccount = require(resolvedKeyPath);
      console.log(`[firebase] init via GOOGLE_APPLICATION_CREDENTIALS sa.project_id=${serviceAccount.project_id} → projectId effectif=${projectId}`);
      firebaseApp = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        projectId,
      });
    } else if (projectId) {
      console.log(`[firebase] init via Application Default Credentials projectId=${projectId}`);
      firebaseApp = admin.initializeApp({
        credential: admin.credential.applicationDefault(),
        projectId,
      });
    } else {
      // Firebase non configuré — mode hors-ligne (stockage local uniquement)
      console.log('[firebase] aucune configuration Firebase trouvée — mode hors-ligne');
      return null;
    }
  } catch (e) {
    console.warn('Firebase init échoué:', e.message, '. Mode hors-ligne.');
    return null;
  }

  return firebaseApp;
}

function isFirebaseAvailable() {
  return !!initFirebase();
}

function getDb() {
  const app = initFirebase();
  if (!app) throw new Error('Firebase non disponible');
  return admin.firestore();
}

function getAuth() {
  const app = initFirebase();
  if (!app) throw new Error('Firebase non disponible');
  return admin.auth();
}

async function saveConversation(userId, { question, answer, sources, mode }) {
  if (!isFirebaseAvailable()) return null;
  const db = getDb();
  return db.collection('conversations').add({
    user_id: userId,
    question,
    answer,
    sources: sources || [],
    mode: mode || 'general',
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });
}

async function getConversations(userId, limit = 50) {
  if (!isFirebaseAvailable()) return [];
  const db = getDb();
  const snapshot = await db
    .collection('conversations')
    .where('user_id', '==', userId)
    .orderBy('created_at', 'desc')
    .limit(limit)
    .get();
  return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
}

async function addFavorite(userId, { sourate, verset, texte_arabe, traduction, notes }) {
  if (!isFirebaseAvailable()) return { alreadyExists: false, id: 'local_' + Date.now() };
  const db = getDb();
  const existing = await db
    .collection('favorites')
    .where('user_id', '==', userId)
    .where('sourate', '==', sourate)
    .where('verset', '==', verset)
    .get();
  if (!existing.empty) return { alreadyExists: true, id: existing.docs[0].id };
  const doc = await db.collection('favorites').add({
    user_id: userId,
    sourate,
    verset,
    texte_arabe: texte_arabe || '',
    traduction: traduction || '',
    notes: notes || '',
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });
  return { id: doc.id, alreadyExists: false };
}

async function getFavorites(userId) {
  if (!isFirebaseAvailable()) return [];
  const db = getDb();
  const snapshot = await db
    .collection('favorites')
    .where('user_id', '==', userId)
    .orderBy('created_at', 'desc')
    .get();
  return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
}

async function removeFavorite(userId, favoriteId) {
  if (!isFirebaseAvailable()) return { success: true };
  const db = getDb();
  await db.collection('favorites').doc(favoriteId).delete();
  return { success: true };
}

async function updateProgress(userId, progress) {
  if (!isFirebaseAvailable()) return { success: true };
  const db = getDb();
  await db.collection('users').doc(userId).set(
    { ...progress, updated_at: admin.firestore.FieldValue.serverTimestamp() },
    { merge: true }
  );
  return { success: true };
}

async function getProgress(userId) {
  if (!isFirebaseAvailable()) return null;
  const db = getDb();
  const doc = await db.collection('users').doc(userId).get();
  return doc.exists ? doc.data() : null;
}

async function upsertUser(uid, { email, displayName, photoURL }) {
  if (!isFirebaseAvailable()) return { success: true };
  const db = getDb();
  await db.collection('users').doc(uid).set(
    {
      email: email || '',
      display_name: displayName || '',
      photo_url: photoURL || '',
      level: 'beginner',
      words_learned: 0,
      verses_understood: 0,
      study_time_minutes: 0,
      daily_streak: 0,
      quiz_score: 0,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );
  return { success: true };
}

async function sendPushNotification(userId, { title, body, data = {} }) {
  if (!isFirebaseAvailable()) return { sent: false, reason: 'firebase_unavailable' };
  try {
    const db = getDb();
    const userDoc = await db.collection('users').doc(userId).get();
    const fcmToken = userDoc.data()?.fcm_token;
    if (!fcmToken) return { sent: false, reason: 'no_token' };
    await admin.messaging().send({ token: fcmToken, notification: { title, body }, data });
    return { sent: true };
  } catch (error) {
    return { sent: false, reason: error.message };
  }
}

async function saveFcmToken(userId, fcmToken) {
  if (!isFirebaseAvailable()) return { success: true };
  const db = getDb();
  await db.collection('users').doc(userId).update({ fcm_token: fcmToken });
  return { success: true };
}

module.exports = {
  isFirebaseAvailable,
  getAuth,
  getDb,
  saveConversation,
  getConversations,
  addFavorite,
  getFavorites,
  removeFavorite,
  updateProgress,
  getProgress,
  upsertUser,
  sendPushNotification,
  saveFcmToken,
};
