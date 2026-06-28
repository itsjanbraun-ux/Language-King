# Language King – Codex Briefing

## Projekt-Überblick

**Language King** ist eine browserbasierte Vokabel-Lern-App für Schüler (Gymnasium, Klasse 6+).
- Alles in **einer einzigen HTML-Datei** (`index.html`) — kein Build-Tool, kein Framework, kein Backend
- Hosting: **GitHub Pages** → `https://itsjanbraun-ux.github.io/Language-King/`
- Lokal öffnen: Doppelklick auf `index.html`

---

## Kritische Coding-Regeln (NICHT verhandelbar)

```
✅ var statt const/let
✅ function foo(){} statt const foo = () => {}
✅ "string " + variable statt `template ${literal}`
✅ Umlaute in JS-Strings als Unicode: ä=ä  ö=ö  ü=ü  ß=ß
✅ localStorage immer via sg(k) und ss(k,v) (try/catch-Wrapper, schon vorhanden)
✅ Kein position:fixed als Hintergrund
✅ Kein class, kein import, kein export
```

**Warum:** Safari/iOS-Kompatibilität. Umlaute direkt im JS haben einmal den Parser gebrochen.

---

## App-Struktur

### Screens (alle als `.screen` divs, aktiver Screen hat Klasse `active`)
```
loginScreen   → Profil wählen + PIN-Eingabe
homeScreen    → Konfiguration + Start
quizScreen    → Quiz-Modus (Multiple Choice mit Timer)
learnScreen   → Lernmodus (Karteikarten)
resultScreen  → Ergebnis nach einer Runde
histScreen    → Verlauf + Statistiken
manageScreen  → Vokabeln verwalten
adminScreen   → Eltern-Bereich (PIN-geschützt)
```

### Screen-Wechsel via `showS(id)` (Zeile 1023)
```javascript
function showS(id){
  var screens=document.querySelectorAll(".screen");
  for(var i=0;i<screens.length;i++){
    screens[i].classList.remove("active");
    screens[i].style.display="none";
  }
  var el=document.getElementById(id);
  el.classList.add("active");
  el.style.display="flex";
  window.scrollTo(0,0);
}
```

### Wichtige globale Variablen (Zeile 591)
```javascript
var profs=[];   // alle Profile
var cp=null;    // aktuell eingeloggtes Profil
var gs=null;    // Quiz-Spielstand (game state)
var ls=null;    // Lern-Spielstand
var tIv=null;   // Timer-Interval
var cLang="latin";     // aktuell gewählte Sprache
var cMode="quiz";      // aktuell gewählter Modus
var cDir="foreign-de"; // Übersetzungsrichtung
var mLang="latin";     // Sprache im Vokabeln-Manage-Screen
```

### Profil-Objekt
```javascript
{
  name: "Jan",
  cls: "6",
  xp: 0,
  pin: "1234",
  history: [],
  errors: { latin: {}, english: {} },
  weeklyMin: 0,
  weekStart: "2026-05-12"
}
```

### localStorage-Schlüssel
```
lk_p          → Array aller Profile (JSON)
lk_v_latin    → Latein-Vokabeln (JSON)
lk_v_english  → Englisch-Vokabeln (JSON)
lk_admin_pin  → Admin-PIN (String)
```

### Hilfsfunktionen
```javascript
sg(k)      // localStorage.getItem mit try/catch
ss(k,v)    // localStorage.setItem mit try/catch
showS(id)  // Screen wechseln
toast(msg) // Kurze Benachrichtigung (2,5s)
shuf(arr)  // Array zufällig mischen
esc(s)     // HTML-Sonderzeichen escapen
saveCP()   // cp ins profs-Array schreiben + saveP()
saveP()    // profs[] in localStorage speichern
loadP()    // profs[] aus localStorage laden
```

---

## Aktueller Bug: Quiz-Screen unsichtbar

### Symptom
- Nutzer klickt „Starten" im homeScreen
- Der Quiz läuft im Hintergrund (Timer tickt, nach 10s erscheint „Zu langsam" als `position:fixed`)
- Der Quiz-Screen-Inhalt ist jedoch **komplett unsichtbar**
- Gleiches Verhalten in Edge, Chrome, lokal und auf GitHub Pages

### Was bereits versucht wurde (ohne Erfolg)
1. `window.scrollTo(0,0)` in `showS()` eingefügt → kein Effekt
2. `showS()` von `forEach` auf `for`-Schleife umgestellt + explizite `style.display` Manipulation → noch nicht getestet

### Quiz-Screen HTML (Zeilen 415–437)
```html
<div id="quizScreen" class="screen">
  <div class="quiz-topbar">
    <div class="q-prog">Frage <span id="qNum">1</span> / <span id="qTot">20</span></div>
    <div class="q-chips">
      <span class="q-chip qc-lvl" id="qLvl">LV1</span>
      <span class="q-chip qc-str">&#x1F525; <span id="qStr">0</span></span>
      <span class="q-chip qc-pts">&#x2B50; <span id="qPts">0</span></span>
    </div>
    <button class="btn btn-ghost-dark btn-sm" onclick="doCancel()">&#x2715; Abbrechen</button>
  </div>
  <div class="q-timer-track"><div class="q-timer-fill" id="qTimer" style="width:100%"></div></div>
  <div class="q-xpbar"><div class="q-xpbar-fill" id="qXpBar" style="width:0%"></div></div>
  <div class="quiz-body">
    <span class="q-dir-pill" id="qDirPill">LATEIN &#x2192; DEUTSCH</span>
    <div style="width:100%;max-width:460px;">
      <div class="q-card">
        <div class="q-hint" id="qHint">...</div>
        <div class="q-word" id="qWord">-</div>
      </div>
      <div class="q-answers" id="qAnswers"></div>
    </div>
  </div>
</div>
```

### Relevante CSS
```css
.screen{display:none;min-height:100vh;flex-direction:column;}
.screen.active{display:flex;}
.quiz-topbar{background:#ffffff;...}
.quiz-body{flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;background:#0d3347;}
.q-card{background:#ffffff;border-radius:18px;padding:24px 28px;max-width:460px;width:100%;}
```

### startRound()-Funktion (Zeile 833)
```javascript
function startRound(){
  var v=getFilt();
  if(v.length<4){toast("Min. 4 Vokabeln nötig!");return;}
  var cnt=parseInt(document.getElementById("qCount").value);
  var sel=shuf(v).slice(0,Math.min(cnt,v.length));
  if(cMode==="learn"){startLearn(sel);return;}
  gs={qs:sel,all:v,idx:0,score:0,streak:0,maxS:0,ok:0,ng:0,mis:[],t0:Date.now()};
  showS("quizScreen");
  document.getElementById("qTot").textContent=sel.length;
  updQXP();
  nextQ();
}
```

### Diagnose-Tipp
In der Browser-Konsole nach Klick auf "Starten" eingeben:
```javascript
document.getElementById("quizScreen").className
// Erwartet: "screen active"
document.getElementById("homeScreen").style.display
// Erwartet: "none"
```

---

## Geplantes Feature: Modus-Redesign

### Gewünschte Unterschiede

| | Lernen | Quiz | Test |
|---|---|---|---|
| Format | Karteikarten | Multiple Choice | Multiple Choice |
| Timer | keiner | 10 Sek | **keiner** |
| Sofort-Feedback | Aufdecken per Tap | ✅/❌ | **keines** |
| Punkte/XP | nein | ja | nein |
| Ergebnis | – | Auswertung + Note | **Note am Ende** |

### Aktueller Stand im Code

```javascript
var TP={quiz:10,test:7};  // Zeile 756 — Test hat derzeit 7s Timer (falsch, soll 0 sein)
```

**Test-Modus hat aktuell kein eigenes Verhalten** — verhält sich genau wie Quiz, nur mit 7s statt 10s Timer.

### Benötigte Änderungen für Test-Modus

**1. Timer deaktivieren (Zeile 756):**
```javascript
var TP={quiz:10,test:0};
```

**2. Timer in `nextQ()` überspringen (~Zeile 871):**
```javascript
// Vor startTimer() einfügen:
if(cMode==="test"){
  document.getElementById("qTimer").style.width="0%";
} else {
  startTimer();
}
```

**3. Kein Feedback in `handleAns()` (~Zeile 882):**
```javascript
function handleAns(sel,correct,btn){
  clearInterval(tIv);
  var btns=document.querySelectorAll(".q-ans");
  if(sel===correct){
    if(cMode!=="test"){
      btn.classList.add("correct");
      showFB(pickR(["🌟 Richtig!","👏 Super!","Perfekt! ✨","🔥 Stark!"]),"good");
      spawnStars(btn);
    }
    gs.ok++;gs.streak++;
    if(gs.streak>gs.maxS)gs.maxS=gs.streak;
    rmErr(gs.qs[gs.idx].en);
  } else {
    if(cMode!=="test"){
      btn.classList.add("wrong");
      for(var i=0;i<btns.length;i++){
        if(btns[i].textContent===correct)btns[i].classList.add("correct");
      }
      showFB(pickR(["❌ Falsch!","😢 Nein!","Leider! 😟"]),"bad");
    }
    gs.ng++;gs.streak=0;
    var q=gs.qs[gs.idx];
    gs.mis.push({en:q.en,de:q.de});
    addErr(q.en);
  }
  for(var j=0;j<btns.length;j++)btns[j].classList.add("disabled");
  setTimeout(function(){gs.idx++;nextQ();},(cMode==="test")?600:1100);
}
```

**4. Modus-Label im Quiz-Topbar (HTML ~Zeile 417):**
HTML: `<span id="qModeLbl" ...></span>` einfügen
JS in `startRound()`: `document.getElementById("qModeLbl").textContent=(cMode==="test")?"TEST":"QUIZ";`

**5. XP in `endRound()` (~Zeile 940) nur bei Quiz vergeben:**
```javascript
if(cMode!=="test"){
  // XP berechnen und speichern
  cp.xp=(cp.xp||0)+xpg;
}
```

---

## Deployment

Nach Änderungen: `index.html` auf GitHub hochladen (Upload via Web-UI oder git push auf Branch `main`).
GitHub Pages baut automatisch — ca. 1–2 Minuten bis live.

```
Repo:     https://github.com/itsjanbraun-ux/Language-King
Live URL: https://itsjanbraun-ux.github.io/Language-King/
Branch:   main
```
