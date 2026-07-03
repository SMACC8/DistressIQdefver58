# backend/edge — Edge Functions (Supabase)

Due funzioni che fanno da ponte verso Gemini. I sorgenti `.ts` non sono inclusi nel pacchetto
front-end: rilasciali qui e (ri)deploya.

## Funzioni
- `riconosci-distress.ts` — riconoscimento del distress dalla foto (Survey).
- `suggerisci-distress.ts` — suggerimento per il nuovo distress personalizzato.

Entrambe sono **lingua-aware**: `db.js` invia la lingua corrente e la funzione risponde in IT/EN/ES.

## Multi-foto (da v63) — aggiornare `riconosci-distress.ts`
Il client ora invia **fino a 3 immagini** dello stesso rilievo:
- nuovo campo `images`: array di stringhe base64 (senza prefisso data-URI), da 1 a 3 elementi;
- campo `image`: mantiene la **prima** immagine, per retro-compatibilità.

Finché la funzione legge solo `image`, l'AI continua a funzionare usando la sola foto
principale (nessun errore). Per sfruttare tutte le foto, nella funzione passa a Gemini
un `inlineData` per ciascun elemento di `images` (fallback a `[image]` se `images` è assente):

```ts
const imgs = Array.isArray(body.images) && body.images.length ? body.images : [body.image];
const parts = [
  { text: prompt },
  ...imgs.map((b64: string) => ({ inlineData: { mimeType: body.mimeType || "image/jpeg", data: b64 } })),
];
```
Il prompt può indicare al modello che le immagini ritraggono **lo stesso ammaloramento**
da angolazioni/dettagli diversi, da valutare insieme. Il `box_2d` eventualmente restituito
resta riferito alla **prima** foto (quella con i marker nell'app).


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
