# Packamore Security Guidelines (Private)

Baserad på `Research/researchSecureFirebaseAPI.md`. Dessa riktlinjer definierar de sju lagerna av Firebase-säkerhet och hur de tillämpas på Packamore.

---

## Grundprincip: Säkerhet är Flerlager

Firebase client-side API-nycklar är **avsiktligt designade att vara publika** — de är projektidentifikatorer, inte autentiseringsuppgifter. Säkerheten kommer från dessa sju lager, **inte från att nycklarna är hemliga:**

1. Firebase Security Rules (server-side)
2. Firebase App Check (app-validering)
3. API-nyckelrestriktioner (HTTP Referrer)
4. Autentiserings-härdning (quotas, enumeration-skydd)
5. Miljövariabler & build-time injection (repo-hygien)
6. Cloud Functions proxy + Secret Manager (tredjepartsnycklar)
7. Operational Security (projekt-isolering, IAM, övervakning)

---

## Lager 1: Firebase Security Rules (KRITISKA)

Security Rules är **det enda verkliga försvaret** mot obehörig data-åtkomst. De tillämpas server-sida innan någon dataoperation slutförs och kan INTE kringgås från klienten.

### Rule: Skriv minst-privilegium Security Rules
- **Why:** Utan server-side regler skyddar inget en användare vars config-nyckel blir stöld. UI-dolning eller client-side checks kan alltid kringgås.
- **How to apply:**
  - Enbart ägaren kan läsa/skriva sin egen data: `auth.uid === userId`
  - Enbart feedback-ägaren kan läsa/skriva sin feedback: `auth.uid === resource.data.ownerUid`
  - Aldrig globala read-permissions för autentiserade användare
  - Aldrig `allow read, write: if true;`

### Farliga mönster att undvika:
```javascript
// 🚨 FARLIGT — Alla kan läsa allt
allow read, write: if true;

// 🚨 FARLIGT — Alla autentiserade kan läsa all feedback
"feedback": {
  ".read": "auth != null",
  ".write": "auth != null"
}
```

### Rekommenderat mönster:
```javascript
"users": {
  "$uid": {
    "feedback": {
      ".read": "auth.uid === $uid",   // Enbart eget feedback
      ".write": "auth.uid === $uid"   // Enbart eget feedback
    }
  }
}
```

### Best practices:
- Skriv regler **iterativt samtidigt som du utvecklar**, inte post-launch
- Testa med **Firebase Local Emulator** innan deployment
- **Unit-testa regler** och inkludera i CI/CD
- Förlita dig INTE på UI-dolning — säkerhet måste vara i reglerna

### Aktuell status för Packamore:
⚠️ **KRITISK:** Alla autentiserade kan läsa ALLA feedback-poster. Detta måste fixas omedelbar.

---

## Lager 2: Firebase App Check (KRITISKA)

App Check svarar på frågan: **Kommer denna request från min legitima app, eller från någon som stöldkopiert min config?**

App Check validerar att requests kommer från en faktisk app-instans, inte från scripts, bots eller scrape-konfigurationer.

### Rule: Aktivera App Check för alla Firebase-tjänster
- **Why:** Utan App Check kan vem som helst med din config (från sidkällan) göra requests till Firebase från sitt eget skript eller bot
- **How to apply:**
  - Aktivera App Check för: Realtime Database, Cloud Storage, Cloud Functions
  - Använd **reCAPTCHA v3** eller reCAPTCHA Enterprise för web
  - Ställ in debug-tokens för lokal utveckling/testing
  - Testa att App Check fungerar innan production-deployment

### Trade-offs:
- Lägger till komplexitet i lokal utveckling
- reCAPTCHA kan ha falska positiver
- **För en app med riktiga användardata är detta värt det**

### Aktuell status för Packamore:
❌ **INTE IMPLEMENTERAT** — Vem som helst kan anropa Firebase med den exponerade konfigurationen

---

## Lager 3: API-Nyckelrestriktioner (Google Cloud Console)

Även om Firebase-nyckeln är publik kan du begränsa VAR den kan användas.

### Rule: Ställ in HTTP Referrer-restriktioner
- **Why:** Begränsar exploatering av någon som kopierat nyckeln till sitt eget skript
- **How to apply:**
  - Gå till Google Cloud Console > API & Services > Credentials
  - Välj din Firebase API-nyckel
  - Lägg till **HTTP Referrer-restriktioner**:
    ```
    https://yourdomain.com/*
    https://www.yourdomain.com/*
    ```
  - Nyckeln avvisas om den skickas från någon annan origin

### Begränsning:
- HTTP Referrer-headers kan spoofas i server-till-server-requests (men inte från webbläsare på grund av CORS)
- Detta är ett användbart lager men inte fullständigt på egen hand

### Rule: Utöka aldrig API-scope manuellt
- **Why:** Firebase-nycklar är redan automatiskt begränsade till Firebase-relaterade APIs
- **How to apply:**
  - Gör inte ändringar i API-scopen
  - För andra Google APIs (Maps, Gemini), skapa **separata begränsade nycklar** för varje tjänst

### Aktuell status för Packamore:
⚠️ **INTE KONFIGURERAT** — Nyckeln kan användas från vilken origin som helst

---

## Lager 4: Autentiserings-Härdning

Firebase Authentication är en angrepsvektor eftersom vem som helst med din publik config kan försöka logga in.

### Rule: Täta quotas på `identitytoolkit.googleapis.com`
- **Why:** Förhindrar brute-force-attacker på inloggning
- **How to apply:**
  - Ställ in rate-limiting i Google Cloud Console
  - Begränsa misslyckade försök per IP/användare

### Rule: Aktivera email enumeration protection
- **Why:** Förhindrar angripare från att upptäcka vilka email-adresser som är registrerade
- **How to apply:**
  - Aktivera i Firebase Authentication Console
  - Returnerar inte olika felmeddelanden för "user not found" vs "wrong password"

### Rule: Använd OAuth 2.0-leverantörer före email/lösenord
- **Why:** Svårare att brute-forsa än lösenord
- **How to apply:**
  - Aktivera Google Sign-In, GitHub Sign-In, osv.
  - Om du måste ha email/lösenord, tvinga starkt lösenord via custom auth

### Rule: Använd aldrig anonym autentisering för permanent identitet
- **Why:** Anonym auth är för pre-sign-in onboarding, inte för faktiska användare
- **How to apply:**
  - Anonym auth enbart för att ge nya användare en provperiod
  - Tvinga upgrade till riktigt auth innan persistent data skapas

### Rule: Överväg Google Cloud Identity Platform för maximum säkerhet
- **Why:** Stöd för multi-factor authentication (MFA)
- **How to apply:**
  - Uppgradera från standard Firebase Auth om MFA är ett krav
  - Implementera MFA för admin-användare

### Aktuell status för Packamore:
⚠️ **OKÄND** — Behöver verifiering av email-enumeration-skydd och quotas

---

## Lager 5: Miljövariabler & Build-Time Injection

Firebase client-config behöver **inte vara hemlig för säkerhetsskäl** (det är publikt för design), men det finns **goda icke-säkerhetsmässiga skäl** att flytta det:

### Rule: Använd miljövariabler för Firebase-config
- **Why:** Miljöseparation (dev/staging/prod), repo-hygien, underhållsbarhet
- **How to apply:**
  - Skapa `.env.local` (gitignored) med Firebase-värden
  - Injicera vid build-tid via din bundler (Vite, webpack, Parcel)
  - Olika config per miljö utan kodändringar

### Exempel — `.env.local`:
```
VITE_FIREBASE_API_KEY=AIza...
VITE_FIREBASE_AUTH_DOMAIN=myapp.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=myapp
VITE_FIREBASE_DATABASE_URL=https://myapp-rtdb.firebaseio.com
```

### Exempel — JavaScript:
```javascript
const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
  databaseURL: import.meta.env.VITE_FIREBASE_DATABASE_URL,
};
```

### Viktigt: Doljer INTE från webbläsare
- Det byggda JavaScript innehåller fortfarande värdena — detta är **väntat och OK**
- Fördelen är source-code-hygien, miljöseparation och repo-säkerhet (ingen hardkoding i git)
- **Inte** runtime-hemlighet

### Firebase App Hosting alt.:
- Firebase App Hosting kan automatiskt injicera config via `FIREBASE_CONFIG`-miljövariabeln
- Ingen manuell injection behövs

### Aktuell status för Packamore:
❌ **INTE IMPLEMENTERAT** — Config är hårdkodad i HTML

---

## Lager 6: Cloud Functions Proxy + Secret Manager

För **icke-Firebase API-nycklar** (Maps, Gemini, Stripe, osv.) som ALDRIG får exponeras klient-sidan, använd en server-side proxy.

### Rule: Aldrig exponera tredjepartsnycklar klient-sidan
- **Why:** Till skillnad från Firebase-nycklar (som skyddas av Security Rules) är tredjepartsnycklar faktiska autentiseringsuppgifter
- **How to apply:**
  - Lagra hemliga nycklar i **Google Cloud Secret Manager**
  - Skapa en Cloud Function för varje tredjepartstjänst
  - Klienten anropar din function, som gör det faktiska anropet med den hemliga nyckeln
  - Din function returnerar resultat (utan att exponera nyckeln)

### Exempel — Cloud Function (2nd-gen):
```javascript
const { defineSecret } = require("firebase-functions/params");
const geminiKey = defineSecret("GEMINI_API_KEY");

exports.callGemini = onRequest({ secrets: [geminiKey] }, async (req, res) => {
  const key = geminiKey.value(); // Endast tillgänglig server-sida
  // Gör anropet till Gemini med den hemliga nyckeln
  const result = await callGeminiAPI(key, req.body);
  res.json(result); // Returnera resultat, inte nyckeln
});
```

### Varför inte 1st-gen miljövariabler:
- Ingen typsäkerhet eller validering
- Hemliga värden kan läcka i loggar
- 2nd-gen Secrets API hämtar autentiseringsuppgifter vid exekveringstid med korrekt isolering

### Trade-offs:
- Lägger till backend-infrastruktur och latens
- Cold starts kan påverka prestanda
- Ökad kostnad (Cloud Function-anrop)
- **Värt det för att drastiskt minska angreppsytan**

### Aktuell status för Packamore:
⚠️ **BEHÖVER VERIFIERING** — Om tredjepartsnycklar används, måste de flytta hit

---

## Lager 7: Operational Security

Operativ säkerhet på Firebase-projektnivå.

### Rule: Använd separata Firebase-projekt per miljö
- **Why:** Förhindrar dev/staging-aktivitet från att påverka produktionsdata; begränsar sprängradien vid misconfiguration
- **How to apply:**
  - Skapa Firebase-projekt för: Development, Staging, Production
  - Olika config per projekt (lagrat i miljövariabler)
  - Ingen risk för att en utvecklare av misstag skriver prod-data

### Rule: Implementera IAM-åtkomstkontroll
- **Why:** Förhindra obehörig åtkomst till Firebase Console och inställningar
- **How to apply:**
  - Använd Google Cloud IAM-roller för att begränsa vem som kan ändra Security Rules, se data, osv.
  - Förinställda roller: `roles/firebase.admin`, `roles/firebase.developer`, etc.
  - Anpassade roller för least-privilege-åtkomst
  - Endast utvalda personer har produktionsåtkomst

### Rule: Ställ in fakturavarningar
- **Why:** Detektera otväntad användning som kan indikera missbruk/DDoS
- **How to apply:**
  - Ställ in budget-alerts i Google Cloud Console
  - Varning när kostnad överstiger tröskelvärde
  - Monitorera regelbundet

### Rule: Sätt concurrency-gränser på Cloud Functions
- **Why:** Förhindra runaway-kostnader från DDoS eller fejkade load
- **How to apply:**
  - Ställ in `maxInstances` per Function
  - Begränsa samtidiga exekveringar

### Rule: Använd aldrig miljövariabler för service account-nycklar
- **Why:** Nycklarna kan läcka i loggar eller config-filer
- **How to apply:**
  - Service account-nycklar och FCM server-nycklar MÅSTE lagras i Secret Manager
  - Aldrig i miljövariabler, aldrig i git

### Rule: Audita och verifiera npm-beroenden
- **Why:** En compromised package kan exfiltrera Firebase-config eller användardata
- **How to apply:**
  - Kör `npm audit` regelbundet
  - Använd Snyk eller liknande för continuous monitoring
  - Granska package-downloads och maintainer-rykte före installation
  - Undvik obscura packages med få downloads

### Aktuell status för Packamore:
❌ **INTE IMPLEMENTERAT** — Behöver separat proj-setup, IAM, budget-alerts

---

## Kod-Spesifika Säkerhetsmönster

### Rule: Aldrig använd `innerHTML` med unescaped användardata

Stored XSS — en användare kan injicera `<script>` eller event handlers via location.name, item.name, shared.listName, osv.

**Farligt:**
```javascript
header.innerHTML = `<span>${location.name}</span>`;  // ❌ XSS
```

**Säkert:**
```javascript
const span = document.createElement('span');
span.textContent = location.name;  // ✅ textContent parsar inte HTML
header.appendChild(span);
```

**Eller med escapeHtml():**
```javascript
function escapeHtml(text) {
  const map = {
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
  };
  return text.replace(/[&<>"']/g, m => map[m]);
}
header.innerHTML = `<span>${escapeHtml(location.name)}</span>`;  // ✅
```

---

### Rule: Aldrig konstruera onclick-attribut via strängkonkatenering

Även enkla apostrof-escaping är otillräckligt — ett namn som `</button><script>alert(1)</script>` bryter ut ur HTML-elementet helt.

**Farligt:**
```javascript
onclick="appOpenShareDialog('${key}', '${list.name.replace(/'/g, "\\'")}')"
// ❌ HTML tag breakout möjligt
```

**Säkert:**
```javascript
const btn = document.createElement('button');
btn.classList.add('share-list-btn');
btn.dataset.key = key;
btn.dataset.listName = list.name;  // data-* attribut parsar inte HTML
btn.textContent = 'Dela';
btn.addEventListener('click', () => appOpenShareDialog(key, list.name));
parent.appendChild(btn);
```

---

### Rule: Aldrig förlita dig på client-side email-checks för åtkomst

**Farligt:**
```javascript
if (user && user.email === 'admin@example.com') {
  showAdminPanel();  // ❌ Kan kringgås från DevTools
}
```

**Säkert:**
- Använd Cloud Functions + Firebase Custom Claims
- Sätt `admin: true`-claim via Admin SDK
- Kontrollera claim i Security Rules: `request.auth.customClaims.admin === true`

---

### Rule: Validera input på system-gränser

**Client-side validering** (för användarfeedback):
```javascript
if (itemName.length === 0 || itemName.length > 100) {
  alert("Objektnamn måste vara 1–100 tecken");
  return;
}
```

**Server-side validering** (i Security Rules):
```javascript
".validate": "newData.val().length > 0 && newData.val().length <= 100"
```

---

## Sammanfattning: Prioriterad Åtgärdslista för Packamore

### 🔴 Omedelbar (Säkerhetskritiska)
1. **Granska Firebase Security Rules**
   - Se till att NO collection/path är öppen för `allow read, write: if true;`
   - Implementera owner-only read/write för all user-data
   - Test lokalt med Firebase Emulator innan deployment

2. **Verifiera Realtime Database och Cloud Storage lock-status**
   - Får INTE vara i test-/open-mode
   - Måste ha restriktiva default-rules

3. **Aktivera Firebase App Check**
   - För Realtime Database, Cloud Storage, Cloud Functions
   - Använd reCAPTCHA v3 för web
   - Ställ in debug-tokens för lokal utveckling

### 🟡 Snart (Härdning)
4. **Ställ in HTTP Referrer-restriktioner**
   - I Google Cloud Console för Firebase API-nyckeln
   - Begränsa till din produktionsdomän(er)

5. **Täta Authentication-quotas**
   - Rate-limit på `identitytoolkit.googleapis.com`
   - Aktivera email enumeration protection

6. **Flytta tredjepartsnycklar**
   - Om Maps, Gemini, osv. används: Cloud Functions proxy + Secret Manager
   - Aldrig exponera direkt klient-sidan

### 🟢 Löpande (Repo-Hygien & Operativ)
7. **Miljövariabler för Firebase-config**
   - `.env`-filer för dev/staging/prod
   - Injicera vid build-tid
   - Gitignore `.env.local`

8. **Separata Firebase-projekt**
   - Development, Staging, Production
   - Olika config per projekt

9. **Sätt upp IAM-åtkomst och budget-alerts**
   - Begränsa production-åtkomst
   - Ställ in fakturavarningar för atypisk användning

10. **Fix XSS i kod**
    - Byt `innerHTML` mot `textContent` eller `createElement()`
    - Fixa inline `onclick`-konstruktion med `data-*` + `addEventListener()`

11. **Audita beroenden**
    - Kör `npm audit` regelbundet
    - Använd Snyk för continuous monitoring

---

## Källor & Referens

Se `Research/researchSecureFirebaseAPI.md` för detaljerade förklaringar, källhänvisningar och trade-off-analys för varje lager.
