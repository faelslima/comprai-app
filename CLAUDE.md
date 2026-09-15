# CLAUDE.md — comprai-app (Supabase)

Ver também `../CLAUDE.md` (raiz do monorepo) para arquitetura geral.

## ⚠️ Este repositório está desatualizado em relação ao banco real

**As migrations aqui (`supabase/migrations/20250001_initial_schema.sql`, `20250002_rls_policies.sql`) nunca foram aplicadas ao projeto Supabase real.** Evidência: o projeto `jgxukiayybgkssdvmhfu` foi criado em **2026-05-28**, e a numeração destas migrations (`20250001...`) sugere 2025 — anterior à criação do projeto. É fisicamente impossível que tenham rodado contra este banco.

O schema **real e vigente** foi criado pelo Lovable Cloud diretamente dentro do repo do frontend, em `../comprai/supabase/migrations/` (4 arquivos, timestamps `20260529*`), e está refletido no `types.ts` gerado automaticamente em `../comprai/src/integrations/supabase/types.ts`. Principais diferenças:

| Aqui (histórico, não aplicado) | Real (`../comprai/supabase/migrations/`) |
|---|---|
| Tabela `items` | Tabela **`list_items`** |
| Sem coluna `price` em items | `list_items.price`, `.unit`, `.checked_by`, `.updated_at` existem |
| Sem função `is_list_creator()` | `is_list_creator(list_id, user_id)` existe |
| Sem trigger de `updated_at` | Triggers `trg_lists_updated_at` e `trg_list_items_updated_at` |
| `lists` SELECT só para membros | `lists` SELECT `USING (true)` — qualquer autenticado (para lookup por share_code) |
| `item_price_observations` sem UPDATE/DELETE | UPDATE/DELETE liberados para o próprio usuário; `REPLICA IDENTITY FULL` |

**Antes de escrever ou aplicar qualquer nova migration a partir deste repo, confirme com o usuário qual é a intenção:**
1. **Ressincronizar** — copiar as 4 migrations reais de `../comprai/supabase/migrations/` para cá, e daqui em diante tratar este repo como a cópia versionada/auditável do schema (aplicando via `supabase db push` ou SQL Editor manualmente, mantendo o Lovable Cloud em sincronia).
2. **Descontinuar como fonte de schema** — manter só como documentação de arquitetura (README, ARCHITECTURE.md) e deixar o Lovable Cloud (dentro do repo `comprai`) como único dono das migrations.

Nenhuma das duas opções foi executada — isto é só o diagnóstico.

---

## O que é (quando a decisão acima for tomada)

Repositório destinado a schema, RLS e migrations do Supabase do ComprAI — projeto único `jgxukiayybgkssdvmhfu` (região us-west-2, Postgres 17), compartilhado entre frontend e backend. Status atual do projeto: **INACTIVE** (pausado por inatividade — plano free pausa projetos sem uso; restaurar no dashboard antes de testar).

## Schema real (ver `../CLAUDE.md` para o SQL completo)

`lists`, `list_members`, `list_items`, `item_price_observations`, `purchase_history` — 5 tabelas, RLS em todas, realtime em `lists`/`list_members`/`list_items`/`item_price_observations`.

## Arquivos de doc já existentes neste repo

- `README.md` — visão geral do monorepo (aponta para `../comprai` e `../ws-comprai`). Lista as 5 tabelas com o nome correto (`items`) mas isso reflete o schema **antigo/não aplicado** — atualizar junto com a decisão acima.
- `ARCHITECTURE.md` — schema documentado bate com as migrations locais (não com o real). Referencia caminho antigo `C:\Users\faels\projects\comprai\...` — o ambiente atual usa `D:\projects\comprai\...`.
- `FRONTEND_ENV.md` — variáveis de ambiente do frontend; inconsistente internamente (usa `VITE_SUPABASE_PUBLISHABLE_KEY` num trecho e `VITE_SUPABASE_ANON_KEY` em outro no mesmo arquivo) — corrigir para `VITE_SUPABASE_PUBLISHABLE_KEY` (é o nome real usado em `../comprai/src/integrations/supabase/client.ts`).

## Executar migrations (enquanto a decisão de ressincronização não é tomada)

Copie o conteúdo de cada migration no Supabase SQL Editor (em ordem) ou use `supabase db push` com CLI local — mas **valide antes contra o schema real** (`../comprai/src/integrations/supabase/types.ts`) para não recriar tabelas com nomes/colunas divergentes do que a aplicação já usa em produção.
