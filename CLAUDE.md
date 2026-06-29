# Language King — Projektdokumentation für Claude Code

## Projektübersicht

**Language King** ist eine browserbasierte Vokabel-Lern-App für Schüler (Gymnasium, Klasse 6+).
Gebaut als **einzelne HTML-Datei** ohne Framework, kein Build-Step, kein Backend.
Hosting: **GitHub Pages** unter `https://itsjanbraun-ux.github.io/Language-King/`

### Dateien im Repo
```
index.html       ← die komplette App (umbenannt von language-king.html)
Banner.png       ← KI-generiertes Banner-Bild (Big Ben + Kolosseum + Kronen-Kinder)
CLAUDE.md        ← diese Datei
```

---

## Tech Stack & Constraints

### Must-haves (nicht verhandelbar)
- **Kein Build-Tool**, kein npm, kein Framework — eine einzige `.html` Datei
- **ES5-kompatibel**: `var` statt `const/let`, keine Arrow Functions, keine Template Literals — Safari/iOS-Kompatibilität
- **Kein CSS variables** in kritischen Styles die Safari brechen könnten — lieber direkte Hex-Werte
- **localStorage immer in try/catch** wrappen
- **Keine externen Abhängigkeiten** außer Google Fonts (Nunito via CDN)
- **Kein `position:fixed` background** (bricht Safari)
- **Umlaute im JavaScript** immer als Unicode escapen: `\u00e4` (ä), `\u00f6` (ö), `\u00fc` (ü), `\u00df` (ß) etc. — **das war der letzte kritische Bug!**

### Farbschema
```
--bg:     #124559  (Haupthintergrund, dunkles Blaugrün)
--bg2:    #0d3347  (dunklere Variante)
--orange: #f97316  (primärer CTA)
--teal:   #0d9488  (sekundärer Button)
--green:  #16a34a
--red:    #dc2626
--card:   #ffffff
--text:   #1e293b
```

### Fonts
- **Nunito** (600/700/800/900) — Fließtext, Buttons
- Geladen via: `https://fonts.googleapis.com/css2?family=Nunito:wght@600;700;800;900&display=swap`

---

## Architektur

### Screen-System
Die App hat **6 Screens** die per `showS(id)` gewechselt werden:
```
loginScreen    → Profil wählen + PIN-Eingabe
homeScreen     → Konfiguration + Start
quizScreen     → Quiz/Test-Modus (4 Antworten)
learnScreen    → Lernmodus (Karteikarten)
resultScreen   → Ergebnis nach einer Runde
histScreen     → Verlauf + Statistiken
manageScreen   → Vokabeln verwalten (Import/Export)
```

Jeder Screen ist ein `<div class="screen">`, aktiver Screen hat Klasse `active`.

### Datenstruktur localStorage
```javascript
lk_p          // Array aller Profile (JSON)
lk_v_db_<profile-id>_<language>      // profilbezogener lokaler Fallback
lk_v_local_<name>_<class>_<language> // profilbezogener lokaler Fallback ohne DB-ID
lk_v_latin    // Latein-Vokabeln (JSON-Array), überschreibt Standarddaten
lk_v_english  // Englisch-Vokabeln (JSON-Array), überschreibt Standarddaten
```

### Profil-Objekt
```javascript
{
  name: "Jan",
  cls: "6",           // Klasse
  xp: 0,
  pin: "1234",        // 4-stellige PIN, beim Erstlogin gesetzt
  vocabSets: {
    latin: "",        // Supabase vocab_sets.id fuer Latein
    english: ""       // Supabase vocab_sets.id fuer Englisch
  },
  history: [],        // max. 100 Einträge
  errors: {
    latin: {},        // { "dea": 2, "mox": 1 } — Fehlerzähler
    english: {}
  },
  weeklyMin: 0,       // Minuten diese Woche
  weekStart: "2026-05-12"  // ISO-Datum Wochenanfang
}
```

### Vokabel-Format (JSON)
```json
[
  { "en": "dea", "de": "die Göttin", "unit": 5 },
  { "en": "mox", "de": "bald", "unit": 5 }
]
```
**Hinweis:** Für Latein ist das `en`-Feld das lateinische Wort (historisch gewachsen, nicht umbenennen — bricht Import-Kompatibilität).

### Profilbezogene Vokabelsets

- Vokabeln werden bevorzugt pro aktivem Profil und Sprache geladen.
- Reihenfolge: Supabase-Set aus `profile.vocabSets[language]` -> lokaler Profil-Fallback -> Klassen-Set aus Supabase -> alte globale Vokabeln -> eingebaute Standardliste.
- Kinder duerfen im bestehenden Vokabeln-Screen importieren:
  - **Ersetzen**: Profil-Set fuer diese Sprache neu setzen
  - **Ergaenzen**: neue Vokabeln anhaengen, Duplikate nach Wort+Unit vermeiden
- Upload akzeptiert JSON (`[{ "en": "...", "de": "...", "unit": 1 }]`) und CSV mit Spalten wie `unit,foreign_word,german_word`.
- Geraeteuebergreifender Sync braucht Supabase-Erweiterung aus `supabase_vocab_sets.sql`.
- Ohne aktiven Elternlogin oder ohne DB-Schema bleibt der Upload lokal pro Profil gespeichert.

---

## Eingebaute Vokabeln

### Latein — Roma A (Lektionen 5–10)
- **~283 Wörter** aus Schulbuch-Fotos extrahiert
- Lektionen 5, 6, 7, 8, 9, 10

### Englisch — (Units 3–5)
- **~110 Wörter**
- Units 3, 4, 5

---

## Level-System
```javascript
var LVL = [
  {xp:0,    t:"Wortstarter"},
  {xp:100,  t:"Entdecker"},
  {xp:250,  t:"Lerner"},
  {xp:500,  t:"Kenner"},
  {xp:800,  t:"Fortgeschritten"},
  {xp:1200, t:"Experte"},
  {xp:1800, t:"Meister"},
  {xp:2500, t:"Gelehrter"},
  {xp:3500, t:"Virtuose"},
  {xp:5000, t:"Lernarchitekt"}
];
```

**XP-Vergabe pro Runde:**
- 8 XP pro richtige Antwort
- 5 XP pro Streak-Punkt (maxStreak)
- 50 XP Bonus bei ≥90%

---

## Notenberechnung
```javascript
function gradeCalc(pct) {
  if(pct>=96) return 1;
  if(pct>=80) return 2;
  if(pct>=60) return 3;
  if(pct>=40) return 4;
  if(pct>=20) return 5;
  return 6;
}
```

---

## PIN-System

- Beim ersten Klick auf ein Profil → PIN-Screen erscheint
- Hat Profil noch keine PIN → Modus "set" → PIN wird gesetzt und gespeichert
- Hat Profil eine PIN → Modus "enter" → Eingabe wird geprüft
- Falsche PIN → Shake-Animation, Buffer wird geleert
- PIN wird im Profil-Objekt als `pin: "1234"` gespeichert

---

## Bekannte Bugs / Offene Punkte

### KRITISCHER BUG (zuletzt aufgetreten)
**Vokabeln werden nicht mehr abgefragt nach dem letzten Update.**
Wahrscheinliche Ursache: JavaScript-Fehler durch den Versuch den Konjugationsmodus einzubauen.
Konkret: **Umlaute (ä, ö, ü, ß) in JavaScript-Strings** brechen den Parser.
**Fix:** Alle Umlaute in JS als Unicode escapen.
Zu prüfen: Browser-Konsole öffnen (F12) → Console-Tab → Fehler anzeigen.

### Offene Features (noch nicht gebaut)
1. **Konjugationsmodus** (Latein, freie Texteingabe)
   - Beim letzten Versuch einzubauen ist die App kaputt gegangen
   - Sauber in separater Datei entwickeln und testen bevor einbauen
   - Verben-Datenstruktur: `{inf:"amare", de:"lieben", kl:"a"}` (Klassen: a/e/i/k/irr)
   - 6 Zeitformen: Präsens, Imperfekt, Perfekt, Plusquamperfekt, Futur I, Futur II
   - 6 Personen: ego, tu, is/ea, nos, vos, ei/eae
   - Tippfehler-Toleranz via Levenshtein-Distanz (≤1 = richtig)

2. **Admin-Bereich** für Eltern
   - Profile verwalten (löschen, PIN zurücksetzen)
   - Wochenziele konfigurieren
   - Verlauf der Kinder einsehen

3. **jsonbin.io Sync** für geräteübergreifende Profile
   - Bereits in Meal-Planning-App des Nutzers implementiert
   - API-Key wird zur Laufzeit eingetragen

4. **Weitere Vokabeln**
   - Latein: Lektionen 11–13 noch nicht eingebaut
   - Neue Lektionen werden als Fotos hochgeladen und extrahiert

5. **Fokus-Filter** ("Nur Fehlervokabeln" als Dropdown statt separatem Button)

---

## Deployment

```
GitHub Repo:  https://github.com/itsjanbraun-ux/Language-King
Live URL:     https://itsjanbraun-ux.github.io/Language-King/
Branch:       main
```

**Deploy-Prozess:**
1. `index.html` bearbeiten
2. Auf GitHub hochladen (Upload via Web-UI oder git push)
3. GitHub Pages baut automatisch — ca. 1-2 Minuten bis live

**Wichtig:** `Banner.png` (Großbuchstabe B!) liegt im gleichen Ordner wie `index.html`.
GitHub Pages auf Linux ist **case-sensitive** — `banner.png` ≠ `Banner.png`.

---

## Entwicklungshinweise für Claude Code

### Vor jeder Änderung
1. Backup anlegen: `cp index.html index.html.bak`
2. Änderung in separater Datei testen wenn möglich
3. Nach Änderung: Browser-Konsole prüfen (F12 → Console)

### JavaScript-Regeln (WICHTIG)
```javascript
// FALSCH - bricht Safari und alte Browser
const x = 5;
const fn = () => {};
`template ${literal}`;
class Foo {}

// RICHTIG
var x = 5;
function fn() {}
"string " + variable;
// kein class, kein const/let
```

### Umlaute in JavaScript (KRITISCH)
```javascript
// FALSCH - bricht JS-Parser in manchen Browsern
{de: "führen"}
{de: "kämpfen"}

// RICHTIG - immer Unicode escapen
{de: "f\u00fchren"}
{de: "k\u00e4mpfen"}
```

Escape-Tabelle:
```
ä = \u00e4    Ä = \u00c4
ö = \u00f6    Ö = \u00d6
ü = \u00fc    Ü = \u00dc
ß = \u00df
```

### localStorage immer absichern
```javascript
// FALSCH
localStorage.setItem('key', value);

// RICHTIG
function ss(k,v){ try{ localStorage.setItem(k,v); }catch(e){} }
function sg(k){ try{ return localStorage.getItem(k); }catch(e){ return null; } }
```

---

## Nutzer-Kontext

- **Jan**, Deutschland, Rheinland-Pfalz
- Baut Lern-Apps für seine Kinder (Gymnasium)
- GitHub-Account: `itsjanbraun-ux`
- Bereits deployed: T-Rex Vokabel-Jagd, Legion Latein-Drill, Wer-bin-ich?, Meal-Planning-PWA
- Bevorzugt: Single-HTML-File, GitHub Pages, keine Wartung, keine Kosten
- Ziel: App soll auf Desktop und Mobilgeräten (inkl. iOS/Safari) laufen
