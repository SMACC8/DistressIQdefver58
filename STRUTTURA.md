# STRUTTURA — mappa delle directory

Pacchetto organizzato in sottocartelle. La parte **servita come PWA** sta in radice + `css/` + `js/`; il **backend** e i documenti stanno a parte e non vengono pubblicati come app.

```
DistressIQ/
├─ index.html              # entry della PWA — DEVE stare in radice
├─ sw.js                   # service worker — DEVE stare in radice (definisce lo scope ./)
├─ manifest.webmanifest    # manifest PWA (start_url e scope = ./)
├─ icon-192.png            # icona app / apple-touch / maskable
├─ icon-512.png            # icona app / maskable
│
├─ css/
│  └─ styles.css           # tema "cantiere": variabili --font-ui / --font-mono, colori, layout
│
├─ js/                     # tutti i moduli ES (import relativi ./ fra fratelli)
│  ├─ app.js               # bootstrap, navigazione, catalogo, form nuovo distress, registrazione SW
│  ├─ config.js            # SUPABASE_URL / SUPABASE_KEY (pubblica) / BUCKET_FOTO
│  ├─ db.js                # unico punto di contatto con Supabase (+ lingua verso l'AI)
│  ├─ storage.js           # astrazione storage foto (oggi Supabase, domani Drive dietro la stessa interfaccia)
│  ├─ rilievo.js           # Survey: foto multiple (max 3) → AI → validazione, GPS↔progressiva, corsie multiple, persistenza campi, data/ora manuale
│  ├─ storico.js           # Storico: tabella, dettaglio, evoluzione, export CSV / KMZ / PDF
│  ├─ statistiche.js       # dashboard: donut (fasce/gravità/origine) + barre, nessuna libreria
│  ├─ iq.js                # calcolo IQ (deduct, fasce)
│  ├─ gruppi.js            # raggruppamento del catalogo distress
│  ├─ i18n.js              # dizionario IT/EN/ES + helper t() / tx() + lingua corrente
│  ├─ guardrail.js         # controlli pre-chiamata AI
│  ├─ training.js          # Training Room: operatore vs AI (senza few-shot = test onesto)
│  ├─ calibrazione.js      # Calibration: libreria esempi few-shot, annotazione aree/linee
│  └─ vendor/
│     └─ supabase.js       # client Supabase (libreria di terze parti, importata da db.js)
│
├─ backend/                # NON servito come PWA — predisposizione lato server
│  ├─ db/                  # migrazioni SQL (vedi backend/db/README.md)
│  └─ edge/                # Edge Functions Supabase (vedi backend/edge/README.md)
│
├─ README.md               # cos'è + installazione da zero + workflow di rilascio
└─ STRUTTURA.md            # questo file
```

## Regole d'oro (per non rompere la PWA)

- `index.html`, `sw.js`, `manifest.webmanifest` e le icone **restano in radice**. Lo scope del service worker è la cartella di `sw.js`: spostarlo in una sottocartella ridurrebbe lo scope e l'offline smetterebbe di coprire l'app.
- Se aggiungi/sposti file dello shell, aggiorna l'elenco `SHELL` in `sw.js` **e** fai il bump di `CACHE`.
- I moduli in `js/` si importano tra loro con path relativi `./nome.js`: tienili nella stessa cartella. `js/vendor/` è referenziato da `db.js` come `./vendor/supabase.js`.
