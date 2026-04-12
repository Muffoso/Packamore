# Close Session Workflow

## Syfte
Standardiserad process för att checka in kod mot GitHub vid slutet av varje kodsession.

## Steg

### 1. Kontrollera status
```bash
git status
```
- Verifierar vilka filer som är ändrade eller nya

### 2. Granska ändringar
```bash
git diff
```
- Bekräfta att alla ändringar är avsiktliga
- Om okända filer finns → undersök innan du committar

### 3. Stage relevanta filer
```bash
git add <files>
```
- Lägg INTE till temporära filer, logs, eller miljövariabler
- Lägg INTE till node_modules, .env, eller andra beroenden

### 4. Skapa commit
```bash
git commit -m "Beskrivande meddelande"
```
- Använd imperativ form: "Add", "Fix", "Update", inte "Added", "Fixed"
- Inkludera varför, inte bara vad: "Fix scroll positioning when activating items in non-filter mode"
- Slut med: `Co-Authored-By: Claude Haiku 4.5 <noreply@anthropic.com>`

### 5. Push till GitHub
```bash
git push
```
- Verifierar att pushen lyckades
- Kontrollera på GitHub att commits är synliga

### 6. Uppdatera plan.md (om relevant)
- Om plan eller krav har ändrats → uppdatera `plan.md`
- Commit denna uppdatering tillsammans med kodändringarna

## Checklist före "close session"
- [ ] Alla ändringar är testade lokalt
- [ ] plan.md är uppdaterad om relevant
- [ ] Ingen sensitiv information i koden (API-nycklar, lösenord)
- [ ] Git-meddelandet är beskrivande
- [ ] Push till GitHub är genomfört

## Om något går fel
- **Merge conflict**: Lösa konflikter manuellt innan push
- **Failed push**: Kontrollera att du är synkroniserad med remote (`git pull` först)
- **Felaktig commit**: Använd `git amend` för senaste commit eller skapa en ny commit för fix
