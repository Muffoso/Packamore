# Packarizer - Plan

## Översikt
En personlig packlist-webbapp för en användare. Lagrar alla ägodelar organiserade efter hemmaplatser och gör det snabbt att välja vad som ska packas för en resa.

## Kärnfunktionalitet

### 1. Ägodelkatalog
- **Lagring**: Alla ägodelar användaren äger
- **Organisering**: Grupperade efter hemmaplatser (förråd, sovrum, kök, etc.)
- **Ingen inventering**: Endast namn på varan, inga antal

### 2. Packningsflöde
- **Aktivering**: Stora knappar för att snabbt välja vad som ska med på resan
- **Status**: Valda saker får "aktiv status"
- **Avaktivering**: Samma knapp toggles för att bocka av när packat
- **Visuell feedback**: Klar visuell skillnad mellan aktiva och inaktiva saker

### 3. Filter & Redigering
- **Floating toggle-knapp**: Visar alla saker eller endast aktiva
  - **Default**: Visa alla saker
- **Edit-knapp**: Toggles redigeringsläge
  - **I redigeringsläge**: 
    - Ändra ordning på hemmaplatser (drag & drop eller upp/ner knappar)
    - Ändra ordning på saker inom varje hemmaplats
    - Lägga till nya hemmaplatser
    - Ta bort hemmaplatser
    - Lägga till nya saker
    - Ta bort saker

### 4. Ordning & Anpassning
- **Hemmaplatser**: Användaranpassad sorteringsordning
- **Saker**: Användaranpassad sorteringsordning per hemmaplats
- **Persistent**: All ordning sparas i Firebase

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

## Hemmaplatser & Saker

### 1. Packa inför resor
Kudde, Earpods, Mobilladdare, Tandborste, Tandkräm, Öronproppar, Deo, Voltaren

### 2. Arbetsrum
Fjöngar, Verktyg, Längdskidglasögon, Headset, Sykit, Pass, Privat dator, Jobbdator, Powerbank, Datorpowerbank +sladd, Datormus

### 3. Tvättstuga
Flipbelt, Löparskor, Skotork, Terrexskor, Löparkeps, Kängor, Flipflop, Formgjutna sulor

### 4. Trappförråd
Löparryggsäck, Vätskebälte, Pannlampa, Regnjacka gallon, Packpåsar, Vattentäta packpåsar

### 5. Klädkammare uppe
Vindjacka, Vindstopper tröja, Underställ byxor, Underställströja ull, Underställströja brynja, Underställsbyxor trekvarts houdini, Underställströjor, Norröna byxor, Flipflop, Regnbyxor tunna, Regnjacka goretex, Inneskor, T-shirts funktion, Haglöfs ull T-shirt, Dunbyxor, Kalsonger träning, Strumpor träning, Badskor

### 6. Sovrum
Houdini tröja, Chinos, Tjock fintröja, Skjorta, Badbyxor, Soltröja, Shorts, Haglöfs tunna byxor grå, Tjock soltröja, Kalsonger, Strumpor, T-shirts

### 7. Badrum nere
Pappaplåster, Solskyddsmedel

### 8. Nere
Datorunderlägg, Laddsladd dator, Mössa, Vantar, Snorkel, Cyklop, Simglasögon, Dunjacka, Vattenflaska

### 9. Uppe
Lakan, Handduk, Handhanduk

### 10. Längdskidor
Skateskidor, Klassiska skidor, Klassiska stavar, Skatestavar, Klassiska pjäxor, Skatepjäxor, Valla, Extra plupp till skatepjäxor

### 11. Urförskidor
Alpina skidor, Alpina stavar, Lavinsändare, Lavinsond, Lavinspade, Liftsittunderlag, Ryggskydd, Stighudar, Skidhjälm, Liftkort, Skidglasögon

### 12. Orientering
Orienteringstights, Orienteringströja, Sportidentpinne och kompass, Orienteringsskor, Extra kompass, Laddare gps-klocka, GPS-klocka, Tensmaskin

### 13. Cykel
Cykelverktyg, Cykelbyxor, Cykeltröja, Cykelhjälm, Cykellås, Cykelskor

### 14. Tältning
Sovsäck, Liggunderlag, Presenning, Tält

### 15. Husvagn
Tvättlina, Campingbord, Vattendunkar, Campingstol, Grenkontakt

## Implementerad Funktionalitet

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

### Database Setup
- Regler: Se FIREBASE_SETUP.md
- Struktur: `users/{uid}/locations/`
- Säkerhet: Användare kan bara läsa/skriva sin egen data

## Nästa Steg
1. Sätt upp Firebase-regler enligt FIREBASE_SETUP.md
2. Aktivera Email/Password och Google Sign-In i Firebase Console
3. Testa inloggning och registrering
