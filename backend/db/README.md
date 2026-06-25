# backend/db — migrazioni SQL

Da eseguire nel SQL editor di Supabase, **in ordine**, dopo lo schema base delle tabelle.
I file `.sql` non sono inclusi nel pacchetto front-end: rilasciali qui e poi esegui.

## 1. `migrazione_traduzioni.sql`
Aggiunge le descrizioni distress in **EN/ES** e rinomina **C2 → "Risalita acqua e fini"** (trilingue).
Necessaria perché il catalogo serva i testi tradotti al posto del solo italiano.

## 2. `migrazione_corsie.sql`
Converte la colonna `corsia` da `smallint` a `text`.
Necessaria per la **multi-corsia** (più corsie selezionate, salvate come elenco — es. `"0,1,2"`).

## Note
- Esegui **prima** `migrazione_traduzioni.sql`, **poi** `migrazione_corsie.sql`.
- Fai un backup/snapshot prima di lanciarle in produzione.
- RLS: oggi disabilitato (utente singolo). Per multi-azienda, abilitare RLS + policy prima di aprire l'accesso.
