# comprai-app

Supabase project para o ComprAI — schema, RLS e migrations.

## Migrations

Arquivos em `supabase/migrations/`:
- `20250001_initial_schema.sql` — 5 tabelas, indexes, trigger, realtime
- `20250002_rls_policies.sql` — RLS policies completas

## Executar

Copie o conteúdo de cada migration no Supabase SQL Editor (em ordem) ou use `supabase db push` com CLI local.

## Tabelas

lists, list_members, items, item_price_observations, purchase_history
