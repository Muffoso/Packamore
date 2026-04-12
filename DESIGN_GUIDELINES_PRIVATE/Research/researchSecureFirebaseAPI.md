# Secure Firebase API Key Handling – Research & Best Practices

## Grundinsikt: Firebase API-Nycklar Är Avsiktligt Publika

Firebase client-side API-nycklar är **inte hemligheter**. Enligt officiell Firebase-dokumentation:

> "API keys for Firebase services only *identify* your Firebase project and app to those services. *Authorization* is handled through Google Cloud IAM permissions, Firebase Security Rules, and Firebase App Check."

Nycklarna fungerar endast som **projektidentifikatorer för kvoter och faktureringscirkulation** — de ger ingen åtkomst till data. Att dessa är synliga i sidkällan är därför inte i sig en säkerhetsbrist.

**Det kritiska är att du har rätt skyddslager på plats.** Utan säkerhet på serversidan (Security Rules och App Check) blir även en "publik" nyckel farlig.

---

## Vad Som Är Säkert att Exponera vs. Vad Som Inte Är Det

### ✅ Säkert att ha publik (klient-side Firebase-config):
- `apiKey`
- `authDomain`
- `databaseURL`
- `projectId`
- `storageBucket`
- `messagingSenderId`
- `appId`

### ❌ Får ALDRIG exponeras:
- **FCM server-nycklar** (Firebase Cloud Messaging backend)
- **Service account private keys** (`.json`-filer från Firebase Console för Admin SDK)
- **Google Cloud Secret Manager-autentiseringsuppgifter**
- **Tredjepartsnycklar** (Maps, Gemini/Vertex AI, Stripe, osv.) — måste lagras server-sida

---

## Lager 1: Firebase Security Rules (Kritiska)

Security Rules är **det enda verkliga försvaret** mot obehörig dataaccesss. De tillämpas server-sida före någon dataoperation och kan inte kringgås från klienten.

### Riskabla mönster att undvika:
```javascript
// 🚨 FARLIGT — Alla kan läsa/skriva allt
allow read, write: if true;

// 🚨 FARLIGT — Läsa allt för autentiserade, ej ägarkontroll
"feedback": {
  ".read": "auth != null",
  ".write": "auth != null"
}
```

### Bra mönster — minst-privilegium per ägare:
```javascript
match /users/{userId}/{document=**} {
  allow read, write: if request.auth != null && 
                         request.auth.uid == userId;
}

match /feedback/{feedbackId} {
  allow read: if request.auth.uid == resource.data.ownerUid;
  allow write: if request.auth.uid == resource.data.ownerUid;
}
```

### Best practices:
- Skriv regler **iterativt samtidigt som du utvecklar features**, inte som en post-launch-aktivitet
- Använd **Firebase Local Emulator** för lokal testning av regler
- **Unit-testa regler** och inkludera tests i CI/CD-pipelinen
- Förlita dig inte påUI-dolning av data; säkerhet måste vara i reglerna

---

## Lager 2: Firebase App Check

App Check svarar på frågan: **Kommer denna request från min app, eller från någon som stöldkopiera min API-nyckel?**

App Check validerar att requests kommer från en legitim app-instans, inte från scripts, bots eller scrape-konfigurationer.

### Hur det fungerar per platform:
- **Web**: reCAPTCHA v3 eller reCAPTCHA Enterprise
- **Android**: Play Integrity eller SafetyNet
- **iOS/macOS**: DeviceCheck eller App Attest

### Aktivering:
- Aktivera App Check för alla Firebase-tjänster som stöder det (Firestore, Realtime Database, Cloud Storage, Cloud Functions)
- Utan App Check kan **vem som helst med din config-nyckel** skriva egna requests till Firebase

### Trade-offs:
- Lägger till komplexitet i lokal utveckling (debug-tokens behövs för emulator)
- reCAPTCHA kan ha falska positiver
- **För produktionsappar med riktiga användardata är skyddet värt det**

---

## Lager 3: API-Nyckelrestriktioner i Google Cloud Console

Även om Firebase API-nyckeln är publik kan du begränsa var den kan användas.

### HTTP Referrer-restriktioner (för web):
I Google Cloud Console > API & Services > Credentials:
```
https://yourdomain.com/*
https://www.yourdomain.com/*
```

Nyckeln avvisas om den skickas från någon annan origin — detta begränsar exploatering av någon som kopierat nyckeln till sitt eget skript.

### API-omfattningsbegränsningar:
- Firebase-nycklar är redan automatiskt begränsade till Firebase-relaterade APIs
- Expandera **inte** detta scope manuellt
- För andra Google APIs (Maps, Gemini), skapa **separata begränsade nycklar** för varje tjänst

### Begränsning:
HTTP Referrer-headers kan spoofas i server-till-server-requests (men inte från webbläsare på grund av CORS), så detta är ett användbart lager men inte fullständigt på egen hand.

---

## Lager 4: Autentiserings-Härdning

Om din app använder Firebase Authentication med email/lösenord, täta quotas på `identitytoolkit.googleapis.com` för att förhindra brute-force-attacker — detta är ett reellt sätt någon med din publik nyckel kunde skada appen.

### Ytterligare best practices:
- Aktivera **email enumeration protection** för att förhindra maliciös upptäckt av giltiga konton
- Använd **OAuth 2.0-leverantörer** (Google, GitHub) där möjligt — svårare att brute-forsa än email/lösenord
- Använd **anonym autentisering** endast för pre-sign-in-onboarding, inte som permanent identitet
- För maximal säkerhet: uppgradera till **Google Cloud Identity Platform** för multi-factor authentication

---

## Lager 5: Miljövariabler och Build-Time-Injektion

Firebase client-config behöver **inte vara hemlig för säkerhetsskäl**, men det finns **legitima icke-säkerhetsmässiga skäl** att flytta config:

1. **Miljöseparation** — olika värden för dev/staging/prod
2. **Underhållsbarhet** — ändra project ID utan att redigera HTML-filer
3. **Konvention** — följer standard-praxis, undviker förvirring

### Implementering med Vite/webpack/Parcel:

**.env.local** (gitignored):
```
VITE_FIREBASE_API_KEY=AIza...
VITE_FIREBASE_AUTH_DOMAIN=myapp.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=myapp
```

**JavaScript** (injecerat vid build-tid):
```javascript
const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
};
```

### Med Firebase App Hosting:
Firebase App Hosting kan automatiskt injicera konfiguration via `FIREBASE_CONFIG`-miljövariabeln — ingen manuell injektion behövs.

### Viktigt:
Environment-variabel-injektion **döljer inte värden från webbläsaren**. Det byggda outputet innehåller fortfarande värdena. Fördelen är:
- Source-code-hygien
- Miljöseparation
- Repository-säkerhet (ingen hardkoding i git)
- **Inte** runtime-sekretess

---

## Lager 6: Server-Side Proxy för Verkligt Hemliga Nycklar

För **icke-Firebase API-nycklar** (tredjepartstjänster, Gemini, Maps, Stripe) som ALDRIG får exponeras klient-sidan, använd en **server-side proxy via Cloud Functions**.

### Pattern:
1. Lagra hemlig nyckel i **Google Cloud Secret Manager**
2. Få åtkomst i en Cloud Function (2nd-gen):

```javascript
const { defineSecret } = require("firebase-functions/params");
const geminiKey = defineSecret("GEMINI_API_KEY");

exports.callGemini = onRequest({ secrets: [geminiKey] }, async (req, res) => {
  const key = geminiKey.value(); // Endast tillgänglig server-sida
  // Gör anropet till Gemini, returnera resultat till klient
  res.json(result);
});
```

3. Klienten anropar din Cloud Function, rör aldrig den hemliga nyckeln direkt

### Varför inte 1st-gen miljövariabler:
- Ingen typsäkerhet eller validering
- Hemliga värden kan läcka i loggar och config-filer
- 2nd-gen Secrets API hämtar autentiseringsuppgifter vid exekveringstid med korrekt isolering

### Trade-offs:
- Lägger till backend-infrastruktur och latens
- Cold starts kan påverka prestanda
- Ökad kostnad (funktionsanrop)
- **Drar ner angreppsytan för verkligt hemliga autentiseringsuppgifter**

---

## Lager 7: Operational Security

Från Firebase Security Checklist:

### Miljöisole ring:
- Håll **separata Firebase-projekt** för dev/staging/production
- Förhindrar dev-aktivitet från att påverka produktionsdata
- Begränsar sprängradien för misconfiguration

### Åtkomstöversyn:
- Begränsa vem på teamet som har produktionsåtkomst via **IAM-roller**
- Använd förinställda eller anpassade roller för least-privilege

### Övervakning:
- Ställ in **faktureringsvarningar** för att upptäcka otväntad användning
- Kontrollera beroenden innan installation — använd verktyg som **Snyk**
- Sätt **concurrency-gränser** på Cloud Functions för att begränsa runaway-kostnader från DDoS

### Hemliga Nycklar:
- **Aldrig** lagra service account-nycklar eller FCM server-nycklar i miljövariabler
- Använd alltid **Secret Manager** för dessa

---

## Sammanfattning: Lager och Trade-offs

| Lager | Skyddar Mot | Komplexitet | Döljer från Browser |
|---|---|---|---|
| **Security Rules** | Obehörig data-åtkomst | Låg–Medel | N/A |
| **App Check** | Icke-app-clients | Medel | N/A |
| **HTTP Referrer-restriktioner** | API-nyckelbruk från andra origins | Låg | Nej |
| **Miljövariabler (build-time)** | Source-repo-hygien | Låg | Nej |
| **App Hosting auto-inject** | Multi-env-hantering | Låg | Nej |
| **Cloud Functions proxy** | Tredjepartshemligheter | Hög | Ja |
| **Secret Manager** | Funktions-interna hemligheter | Medel | Ja |
| **Auth-quotas** | Brute-force | Låg | N/A |
| **Separata projekt per env** | Cross-env-datakontaminering | Låg | N/A |

---

## Prioriterad Åtgärdslista för Packamore

### 🔴 Omedelbar (Säkerhetskritisk):
1. **Granska Firebase Security Rules** — Se till att ingen samling eller databassökvärg är öppen för `allow read, write: if true`
2. **Verifiera lock-status** — Realtime Database och Cloud Storage får inte vara i test-/öpen-läge
3. **Aktivera Firebase App Check** för Firestore, Realtime Database, Storage och Cloud Functions

### 🟡 Snart (Härdning):
4. **HTTP Referrer-restriktioner** — Lägg till din produktionsdomän(er) i Google Cloud Console för Firebase API-nyckeln
5. **Auth-quotas** — Täta identitytoolkit om du använder email/lösenord-autentisering
6. **Tredjepartsnycklar** — Om du använder Maps, Gemini osv. klient-sidan, flytta till Cloud Functions proxy + Secret Manager

### 🟢 Löpande (Hygien):
7. **Miljövariabler** — Flytta Firebase config till `.env`-filer och injicera vid build
8. **Separata projekt** — Dev-, staging- och production-projekt i Firebase
9. **Fakturavarningar** — Ställ in budget-alerts för att detektera missbruk

---

## Slutsats

**Den hårdkodade Firebase-konfigurationen i din HTML är inte själv den kritiska sårbarheten.** Det är det förväntade tillståndet för Firebase client-config.

**De faktiska kritiska sårbarheterna är:**
- Misconfigurerade Security Rules (LAGER 1)
- Saknade App Check (LAGER 2)

**Fokusera först på dessa två.** Därefter kan du förbättra med referrer-restriktioner, miljövariabler och projektisoleringen.

---

## Källor

- [Learn about using and managing API keys for Firebase | Firebase Documentation](https://firebase.google.com/docs/projects/api-keys)
- [Firebase Security Rules Basics | Firebase Documentation](https://firebase.google.com/docs/rules/basics)
- [Firebase App Check | Firebase Documentation](https://firebase.google.com/docs/app-check)
- [Firebase security checklist](https://firebase.google.com/support/guides/security-checklist)
- [Firebase App Hosting: Configure your backend](https://firebase.google.com/docs/app-hosting/configure)
- [Use secrets in Cloud Functions | Firebase Documentation](https://firebase.google.com/docs/functions/config/secret-parameters)
- [Secure API Keys with 2nd-Gen Cloud Functions](https://codewithandrea.com/articles/api-keys-2ndgen-cloud-functions-firebase/)
- [Firebase API Key Exposed: Understanding Risks and Best Practices](https://sqlpey.com/firebase/secure-firebase-api-keys/)
- [Remediating Firebase Cloud Messaging API Key leaks | GitGuardian](https://www.gitguardian.com/remediation/firebase-cloud-messaging-api-key)
