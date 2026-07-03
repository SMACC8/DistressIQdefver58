-- ============================================================
-- DistressIQ — Migrazione: multi-foto per rilievo + descrizione AI
-- Data: 2026-07
-- Modello RLS coerente col resto: lettura pubblica / scrittura a tutti
-- ============================================================
--
-- ORDINE OPERATIVO:
--   1) (consigliato) backup/dump come per la migrazione RLS
--   2) esegui questo SQL nel SQL Editor di Supabase
--   3) SOLO DOPO carica il nuovo codice dell'app (v63)
--
-- Nota sui tipi: si assume che public.rilievo.id sia di tipo uuid
-- (default Supabase). Se cosí non fosse, la creazione della FK darà
-- errore: in quel caso segnalamelo e adeguo il tipo della colonna.
-- Diagnostica rapida (facoltativa, eseguibile da sola):
--   SELECT data_type FROM information_schema.columns
--   WHERE table_schema='public' AND table_name='rilievo' AND column_name='id';
-- ============================================================

-- ------------------------------------------------------------
-- 1. Colonna descrizione AI sul rilievo (testo libero, opzionale)
-- ------------------------------------------------------------
ALTER TABLE public.rilievo ADD COLUMN IF NOT EXISTS ai_descrizione text;

-- ------------------------------------------------------------
-- 2. Tabella foto multiple del rilievo (fino a 3, limite gestito dall'app)
--    foto_id / thumb_path replicano lo stesso schema di storage già in uso.
--    ordine: 0 = foto principale, 1, 2 = aggiuntive.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.rilievo_foto (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  rilievo_id  uuid NOT NULL REFERENCES public.rilievo(id) ON DELETE CASCADE,
  foto_id     text NOT NULL,
  thumb_path  text,
  ordine      int  NOT NULL DEFAULT 0,
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_rilievo_foto_rilievo_id ON public.rilievo_foto(rilievo_id);

-- ------------------------------------------------------------
-- 3. RLS sulla nuova tabella (stesso modello delle altre)
-- ------------------------------------------------------------
ALTER TABLE public.rilievo_foto ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  -- SELECT pubblico
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='rilievo_foto' AND policyname='rilievo_foto_select_pubblico') THEN
    CREATE POLICY rilievo_foto_select_pubblico ON public.rilievo_foto FOR SELECT TO anon, authenticated USING (true);
  END IF;
  -- INSERT tutti
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='rilievo_foto' AND policyname='rilievo_foto_insert_tutti') THEN
    CREATE POLICY rilievo_foto_insert_tutti ON public.rilievo_foto FOR INSERT TO anon, authenticated WITH CHECK (true);
  END IF;
  -- UPDATE tutti
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='rilievo_foto' AND policyname='rilievo_foto_update_tutti') THEN
    CREATE POLICY rilievo_foto_update_tutti ON public.rilievo_foto FOR UPDATE TO anon, authenticated USING (true) WITH CHECK (true);
  END IF;
  -- DELETE tutti
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='rilievo_foto' AND policyname='rilievo_foto_delete_tutti') THEN
    CREATE POLICY rilievo_foto_delete_tutti ON public.rilievo_foto FOR DELETE TO anon, authenticated USING (true);
  END IF;
END $$;

-- ------------------------------------------------------------
-- 4. Backfill: porta la foto esistente di ogni rilievo nella nuova
--    tabella come foto principale (ordine 0), senza duplicare se già presente.
-- ------------------------------------------------------------
INSERT INTO public.rilievo_foto (rilievo_id, foto_id, thumb_path, ordine)
SELECT r.id, r.foto_id, r.thumb_path, 0
FROM public.rilievo r
WHERE r.foto_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM public.rilievo_foto rf WHERE rf.rilievo_id = r.id
  );

-- ============================================================
-- FINE MIGRAZIONE
-- Verifica: SELECT count(*) FROM public.rilievo_foto;
-- ============================================================
