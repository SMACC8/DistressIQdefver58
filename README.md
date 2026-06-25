# DistressIQ

PWA mobile (vanilla JS, **no build**, single-folder servibile) per **riconoscere, classificare e seguire nel tempo** gli ammaloramenti (*distress*) su pavimentazioni drenanti, con AI Gemini via Edge Function e backend Supabase. UI trilingue **IT / EN / ES**. Estetica "cantiere" (sfondo scuro, giallo sicurezza, monospazio per i dati).
Rete **A4 / A31** (gestori abertis / connectis). *SviluPPAta da Sergio Moro.*

Versione cache app-shell: **v58** (`sw.js`).

---

## Cos'è e come funziona

- **Foto + AI** → riconoscimento visivo del tipo di distress e severità, con disegno delle regioni (catalogo ASTM D6433 / LTPP).
- **Validazione operatore** → conferma/correzione e posizione esatta.
- **GPS ↔ progressiva** → ogni rilievo è localizzato lungo la strada dai punti ettometrici.
- **IQ (Indice di Qualità 0–100)** → indice ispirato al PCI, adattato al drenante.
- **Storico & Statistiche** → catene di evoluzione, tendenze, dashboard, export KMZ / PDF / CSV.
- **Calibrazione & Training Room** → libreria di esempi *few-shot* che guida l'AI, e palestra operatore-vs-AI.

---

## Installazione da zero

Il front-end è statico e gira così com'è. Il backend (Supabase + Edge) va predisposto una volta.

1. **Supabase — progetto e schema.** Crea il progetto, applica lo schema delle tabelle, poi esegui le migrazioni in `backend/db/` nell'ordine indicato lì.
2. **Supabase — Storage.** Crea il bucket foto (default atteso: `foto`, vedi `js/config.js`).
3. **Edge Functions.** Deploya le due funzioni in `backend/edge/` e imposta i *secret* (chiave Gemini, chiave segreta Supabase). Dettagli nel README di quella cartella.
4. **Configurazione client.** In `js/config.js` imposta `SUPABASE_URL`, `SUPABASE_KEY` (publishable, **pubblica per design**) e `BUCKET_FOTO`. Non mettere **mai** qui la chiave segreta Supabase né la chiave Gemini.
5. **Deploy front-end (GitHub Pages).** Pubblica il contenuto di questa cartella alla radice del sito (utente `smacc8`). `index.html`, `sw.js`, `manifest.webmanifest` e le icone **devono restare in radice**: lo scope del service worker dipende dalla posizione di `sw.js`.

Apri da telefono → "Aggiungi a schermata Home" per l'esperienza PWA (offline dell'app-shell incluso).

---

## Aggiornare l'app

Workflow di rilascio (come da convenzione):

1. Modifica i file.
2. Valida (no build necessario): `esbuild js/app.js --bundle --format=esm --outfile=/dev/null`.
3. **Bump della cache** in `sw.js` (`distressiq-vNN` → `vNN+1`) ad ogni cambio di file dello shell.
4. Ri-zippa con **tutti** i file e pubblica.

Il service worker è *network-first*: online prende sempre i file aggiornati, offline ricade sulla cache; le chiamate Supabase/Edge passano dirette in rete e non vengono cacheate.

---

## Stato noto

- **RLS disabilitato** sulle tabelle (advisor segnala CRITICAL): accettabile a utente singolo, da chiudere prima dell'uso multi-azienda (RLS + Auth + bucket listing off + indici FK).
- Le chiavi pubbliche in `js/config.js` sono pubbliche per design; la sicurezza la fanno le RLS.

Struttura delle cartelle: vedi `STRUTTURA.md`.
