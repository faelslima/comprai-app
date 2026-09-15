-- Rodar no SQL Editor do Supabase, projeto jgxukiayybgkssdvmhfu, de uma vez só.
-- Não contém DROP TABLE — só RENAME/ALTER/CREATE. Todas as tabelas envolvidas
-- estão com 0 linhas hoje, então não há risco de perda de dado mesmo assim.

-- 1. Funções novas / atualizadas (sem tocar nas existentes que já funcionam)
CREATE OR REPLACE FUNCTION public.is_list_creator(p_list_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.lists WHERE id = p_list_id AND created_by = auth.uid()
  );
$$;

REVOKE EXECUTE ON FUNCTION public.is_list_creator(uuid) FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- 2. lists: coluna updated_at + trigger + SELECT aberta p/ lookup por share_code
ALTER TABLE public.lists
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT now();

DROP TRIGGER IF EXISTS trg_lists_updated_at ON public.lists;
CREATE TRIGGER trg_lists_updated_at
BEFORE UPDATE ON public.lists
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP POLICY IF EXISTS "Members can view their lists" ON public.lists;
CREATE POLICY "Authenticated can view list by share_code lookup"
  ON public.lists FOR SELECT TO authenticated USING (true);

-- 3. list_members: permitir que o criador também remova membros
DROP POLICY IF EXISTS "Members can leave (delete own)" ON public.list_members;
CREATE POLICY "Users can leave list or creator can remove"
  ON public.list_members FOR DELETE TO authenticated
  USING (auth.uid() = user_id OR public.is_list_creator(list_id));

-- 4. items -> list_items (rename preserva FKs, policies e realtime existentes)
ALTER TABLE public.items RENAME TO list_items;

ALTER TABLE public.list_items
  ADD COLUMN IF NOT EXISTS unit TEXT,
  ADD COLUMN IF NOT EXISTS price NUMERIC(10,2),
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT now();

DROP TRIGGER IF EXISTS trg_list_items_updated_at ON public.list_items;
CREATE TRIGGER trg_list_items_updated_at
BEFORE UPDATE ON public.list_items
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- 5. item_price_observations: coluna list_id denormalizada + UPDATE/DELETE do próprio usuário
ALTER TABLE public.item_price_observations
  ADD COLUMN IF NOT EXISTS list_id UUID REFERENCES public.lists(id) ON DELETE CASCADE;

UPDATE public.item_price_observations ipo
SET list_id = li.list_id
FROM public.list_items li
WHERE ipo.item_id = li.id AND ipo.list_id IS NULL;

ALTER TABLE public.item_price_observations ALTER COLUMN list_id SET NOT NULL;
ALTER TABLE public.item_price_observations REPLICA IDENTITY FULL;

DROP POLICY IF EXISTS "Users update own price observations" ON public.item_price_observations;
CREATE POLICY "Users update own price observations"
  ON public.item_price_observations FOR UPDATE TO authenticated USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users delete own price observations" ON public.item_price_observations;
CREATE POLICY "Users delete own price observations"
  ON public.item_price_observations FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- 6. purchase_history: policy de delete que faltava
DROP POLICY IF EXISTS "Users delete own history" ON public.purchase_history;
CREATE POLICY "Users delete own history"
  ON public.purchase_history FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- 7. Realtime: só faltava "lists" (list_members, list_items e item_price_observations já publicados)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'lists'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.lists;
  END IF;
END $$;
