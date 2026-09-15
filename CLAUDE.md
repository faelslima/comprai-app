# CLAUDE.md — comprai-app (Supabase)

Ver também `../CLAUDE.md` (raiz do monorepo) para arquitetura geral.

## Este repositório é a fonte de verdade versionada do schema

Projeto Supabase único: `jgxukiayybgkssdvmhfu` (região us-west-2, Postgres 17), compartilhado entre frontend e backend.

## Histórico de migrations (`supabase/migrations/`)

1. `20250001_initial_schema.sql` — schema inicial: `lists`, `list_members`, `items`, `item_price_observations`, `purchase_history`
2. `20250002_rls_policies.sql` — RLS de todas as tabelas
3. `20260915000000_migrate_items_to_list_items.sql` — reconciliação: o frontend (código gerado pelo Lovable Cloud contra um projeto Supabase antigo e já abandonado, `wrcqyxpvgokyjvcgbaim`) esperava uma tabela `list_items` com colunas `price`/`unit`/`updated_at` que não existiam aqui. Aplicada em 2026-09-15 diretamente no projeto real (todas as tabelas estavam com 0 linhas — sem risco de perda de dado). Renomeia `items` → `list_items`, adiciona as colunas faltantes + triggers de `updated_at` (`lists` e `list_items`), abre a policy de SELECT de `lists` para `USING (true)` (lookup por share_code), adiciona `list_id` denormalizado e policies de UPDATE/DELETE em `item_price_observations`, adiciona policy de DELETE em `purchase_history`, cria `is_list_creator()`, e publica `lists` no realtime.

**Execução:** copie o conteúdo de cada migration no SQL Editor do Supabase (em ordem) ou use `supabase db push` com CLI local.

## Schema atual (ver `../CLAUDE.md` para o SQL completo com comentários)

`lists`, `list_members`, `list_items`, `item_price_observations`, `purchase_history` — 5 tabelas, RLS em todas, realtime em `lists`/`list_members`/`list_items`/`item_price_observations`.

## Pendência de segurança conhecida (baixa prioridade)

`get_advisors` (Supabase) aponta `generate_share_code`, `auto_add_creator_as_member` e `is_list_member` sem `search_path` fixo, e `is_list_member(uuid)` ainda executável via RPC por `anon`/`authenticated` (diferente de `is_list_creator`, que já tem `EXECUTE` revogado). Vale uma migration futura para endurecer isso.

## Arquivos de doc já existentes neste repo

- `README.md` — visão geral do monorepo. Lista as 5 tabelas com o nome antigo (`items`) — atualizar para `list_items`.
- `ARCHITECTURE.md` — referencia caminho antigo `C:\Users\faels\projects\comprai\...` — o ambiente atual usa `D:\projects\comprai\...`. Schema documentado também precisa do ajuste `items` → `list_items`.
- `FRONTEND_ENV.md` — variáveis de ambiente do frontend; inconsistente internamente (usa `VITE_SUPABASE_PUBLISHABLE_KEY` num trecho e `VITE_SUPABASE_ANON_KEY` em outro) — corrigir para `VITE_SUPABASE_PUBLISHABLE_KEY` (nome real usado em `../comprai/src/integrations/supabase/client.ts`). Também vale registrar que o `SUPABASE_URL`/`VITE_SUPABASE_URL` corretos são os de `jgxukiayybgkssdvmhfu` — o `.env` **commitado** em `../comprai` ainda aponta para o projeto antigo `wrcqyxpvgokyjvcgbaim` (ver `../CLAUDE.md` #4).
