# Muslim IA

**Apprendre le Coran et l'Islam avec l'IA.**

Application Flutter (Android/iOS) avec backend Node.js (Express). Apprentissage du Coran, récitation, mémorisation, vocabulaire arabe, tafsir, questions-réponses assistées par intelligence artificielle, suivi de progression et bien plus.

## Structure

```
├── lib/                  # Application Flutter (UI, providers, services)
│   ├── screens/          # Écrans (chat, paywall, auth, apprentissage…)
│   ├── providers/        # États (auth, chat, abonnement, langue…)
│   ├── widgets/          # Composants réutilisables
│   └── services/         # ApiService, storage, deep links…
├── server/               # Backend Node.js (Express + Firebase Admin)
│   ├── src/
│   │   ├── routes/       # ask, auth, audio, vision, progress, user
│   │   ├── services/     # mistral, mcp_quran, firebase, email…
│   │   └── middleware/   # rate limiting, auth
│   ├── render.yaml       # Déploiement Render (Blueprint)
│   └── .env.example      # Variables d'environnement (copier vers .env)
├── assets/               # Logo, Conditions d'utilisation, Politique de confidentialité
└── firestore.indexes.json
```

## Prérequis

- Flutter 3.41+ (Dart SDK 3.11+)
- Node.js 20+
- Un projet Firebase (Auth, Firestore, Messaging) avec fichier `google-services.json` dans `android/app/`
- Compte Render pour le backend

## Application Flutter

### Installation

```bash
flutter pub get
```

### Lancer en développement (backend local)

```bash
cd server && npm install && cp .env.example .env
# renseigner .env puis :
npm run dev
```

Depuis un autre terminal :

```bash
flutter run --dart-define=API_BASE_URL=http://<IP_LAN>:4000
```

### Construire la version de production

```bash
# Signé avec le keystore upload-keystore.jks (configuré via android/key.properties)
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://muslim-ia-api.onrender.com \
  --dart-define=GENIUSPAY_API_KEY=pk_live_xxx \
  --dart-define=GENIUSPAY_API_SECRET=sk_live_xxx
```

### Signer l'application

1. Générer le keystore (une seule fois, conservez-le précieusement) :

   ```bash
   cd android
   keytool -genkeypair -v -keystore upload-keystore.jks -alias upload \
     -keyalg RSA -keysize 4096 -validity 10950
   ```

2. Créer `android/key.properties` :

   ```properties
   storePassword=<mot de passe>
   keyPassword=<mot de passe>
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```

   > `key.properties` et `upload-keystore.jks` sont ignorés par git (fichiers privés).

## Backend (Node.js)

### Déploiement sur Render

1. Poussez le dépôt sur GitHub.
2. Dans Render : **New + Blueprint** et sélectionnez le dépôt. Le fichier `server/render.yaml` configure le service.
3. Renseignez les variables d'environnement secrètes dans le dashboard Render :
   - `MISTRAL_API_KEY`, `GROQ_API_KEY`, `TRYIA_API_URL`
   - `FIREBASE_PROJECT_ID` et `FIREBASE_SERVICE_ACCOUNT` (contenu JSON complet du compte de service Firebase)
   - `BREVO_API_KEY`, `BREVO_SENDER_NAME`, `BREVO_SENDER_EMAIL`
   - `PUBLIC_LOGO_URL`, `AUTH_CONTINUE_URL`, `MISTRAL_VOICE_ID`

   > `FIREBASE_SERVICE_ACCOUNT` remplace le fichier JSON local (pris en charge par `server/src/services/firebase.js`).

4. Le endpoint de santé est `/health` ; une fois déployé, utilisez l'URL Render (ex. `https://muslim-ia-api.onrender.com`) comme `API_BASE_URL` dans le build Flutter.

### Test en local

```bash
cd server && npm start
curl http://localhost:4000/health
```

## Firebase

- Firestore : appliquez les index composites :
  ```bash
  firebase deploy --only firestore:indexes
  ```
- Les règles de sécurité Firestore doivent restreindre l'accès par utilisateur (`user_id`).

## Publication sur les stores

- **Google Play** : téléversez `build/app/outputs/bundle/release/app-release.aab` sur la Play Console (à l'aide de Play App Signing). Renseignez la fiche (description, captures d'écran, politique de confidentialité → `assets/privacy_policy.txt`, conditions d'utilisation → `assets/terms_of_use.txt`).

## Sécurité

- Les secrets ne sont jamais commités : `server/.env`, `android/key.properties`, `*.jks`, le JSON du compte de service Firebase sont dans `.gitignore`.
- Le rate limiting est activé sur toutes les routes (`server/src/middleware/rate_limit.js`).
