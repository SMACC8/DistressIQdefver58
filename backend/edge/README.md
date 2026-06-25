# backend/edge — Edge Functions (Supabase)

Due funzioni che fanno da ponte verso Gemini. I sorgenti `.ts` non sono inclusi nel pacchetto
front-end: rilasciali qui e (ri)deploya.

## Funzioni
- `riconosci-distress.ts` — riconoscimento del distress dalla foto (Survey).
- `suggerisci-distress.ts` — suggerimento per il nuovo distress personalizzato.

Entrambe sono **lingua-aware**: `db.js` invia la lingua corrente e la funzione risponde in IT/EN/ES.

## Secret (lato server, MAI nel client)
- chiave **Gemini** (pay-as-you-go) — come secret della Edge Function.
- chiave **segreta Supabase** (`sb_secret_...`) se usata server-side — come secret.
- Imposta un **tetto di spesa / quota** su Google Cloud per Gemini.

## Deploy / redeploy
1. Aggiorna i secret.
2. Deploya/ridepoya entrambe le funzioni.
3. Verifica con un rilievo reale in ciascuna lingua.

## Note
- Il *few-shot* (esempi di Calibration) **guida** il modello, non lo addestra: cambiare modello o credito non è la leva. Training Room non passa gli esempi → test onesto della capacità reale.
