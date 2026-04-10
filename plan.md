                                                                                                                                                                                                                                                                                                                                                                                                                                                                                # Packarizer - Plan

## Översikt
En personlig packlist-webbapp för en användare. Lagrar alla ägodelar organiserade efter grupper/lagringsplatser och gör det snabbt att välja vad som ska packas för en resa.

## Kärnfunktionalitet

### 1. Ägodelkatalog
- **Lagring**: Alla ägodelar användaren äger
- **Organisering**: Grupperade efter lagringsplatser (förråd, sovrum, kök, etc.)
- **Ingen inventering**: Endast namn på varan, inga antal

### 2. Packningsflöde
- **Aktivering**: Stora knappar för att snabbt välja vad som ska med på resan
- **Status**: Valda saker får "aktiv status"
- **Avaktivering**: Samma knapp toggles för att bocka av när man packat saken
- **Visuell feedback**: Klar visuell skillnad mellan aktiva och inaktiva saker

### 5. Editering av plats eller sak och annan funktionalitet
- **Long-press/Context-meny** : Möjlighet att:
  - Byta namn på lagringsplatser och saker
  - Ordna (flytta upp/ner)
  - Flytta saker mellan lagringsplatser
  - Ta bort lagringsplatser och saker
- **Quantity-kontroller**: Då en sak är markerad som aktiv, kan man öka/minska antal
  - Antal återställs till 1 när saken avaktiveras
- **Sparade packlistor**: 
  - Spara current packstatus som en namngiven lista
  - Ladda tidigare sparade packlistor
  - Ta bort sparade packlistor
  - Dela packlistor med andra användare via email
  - Acceptera/Neka delade packlistor från andra
- **Feedback-formulär**:
  - 6-stjärnig rating-skala med labels
  - Textfält för detaljerad feedback
  - Utlöses automatiskt var tredje gång man avmarkerar alla saker
  - Feedback sparas i Firebase

## Teknisk Stack
- **Frontend**: HTML/CSS/JavaScript
- **Databas**: Firebase Realtime Database (REST API)
- **Firebase Config**: Integrerad direkt i HTML
  ```
  apiKey: AIzaSyB0H8p6i8-ygCsTdMnY6Aj5yMCLPNVG-84
  authDomain: packarizer.firebaseapp.com
  databaseURL: https://packarizer-default-rtdb.europe-west1.firebasedatabase.app
  projectId: packarizer
  storageBucket: packarizer.firebasestorage.app
  messagingSenderId: 81001000065
  appId: 1:81001000065:web:59987941208afe5aff3180
  ```


### Autentisering
- ✅ Email/Password registrering och inloggning
- ✅ Google Sign-In
- ✅ Logout-knapp i gränssnittet
- ✅ Auth-skärm före appens huvudgränssnitt

### Multi-User Support
- ✅ Varje användare har sitt eget datasystem
- ✅ stallberg.anders@gmail.com får alla standardplatser och saker
- ✅ Nya användare startar med tomt system
- ✅ Realtids synkronisering via Firebase

### Packningsflöde
- ✅ Aktivering/deaktivering av saker med stor knapp
- ✅ Visuell feedback för aktiva vs inaktiva saker
- ✅ Quantity-kontroller för aktiva saker (+/- knappar)
- ✅ Antal återställs när saker avaktiveras

### Filter & Redigering
- ✅ Två filter-knappar: "Visa allt" och "Endast aktiva"
- ✅ Edit-läge för att modifiera struktur
- ✅ Upp/ner-knappar för att ändra ordning på lagringsplatser
- ✅ Upp/ner-knappar för att ändra ordning på saker
- ✅ Möjlighet att lägga till nya lagringsplatser
- ✅ Möjlighet att lägga till nya saker
- ✅ Möjlighet att ta bort lagringsplatser (med bekräftelse)
- ✅ Möjlighet att ta bort saker (med bekräftelse)

### Avancerad Redigering
- ✅ Long-press/Context-meny för att:
  - Byta namn på lagringsplatser och saker
  - Ordna med upp/ner-knappar
  - Flytta saker mellan lagringsplatser
  - Ta bort lagringsplatser och saker
- ✅ Ordning sparas persistent i Firebase

### Sparade Packlistor
- ✅ Spara current packstatus som namngiven lista
- ✅ Ladda tidigare sparade packlistor
- ✅ Ta bort sparade packlistor
- ✅ Dela packlistor med andra via email
- ✅ Acceptera/Neka delade packlistor

### Feedback
- ✅ Feedback-formulär med 6-stjärnig rating
- ✅ Textfält för detaljerad feedback
- ✅ Auto-trigger var tredje gång man avmarkerar alla saker
- ✅ Feedback sparas i Firebase

### Database
- ✅ Firebase Realtime Database
- ✅ Struktur: `users/{uid}/locations/`
- ✅ Säkerhet: Användare kan bara läsa/skriva sin egen data
- ✅ Email-index för delning av packlistor
- ✅ Admin feedback-nod för feedback-samling
