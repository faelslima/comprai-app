# ComprAI - Arquitetura Completa

## 🏗️ Visão Geral

O ComprAI é composto por 3 componentes principais:

1. **Frontend** (Lovable) - `C:\Users\faels\projects\comprai\comprai`
2. **Backend** (Spring Boot) - `C:\Users\faels\projects\comprai\ws-comprai`
3. **Database** (Supabase) - `C:\Users\faels\projects\comprai\comprai-app`

## 📦 Estrutura de Diretórios

```
comprai/
├── comprai/              # Frontend Lovable (React + TanStack)
│   ├── src/
│   │   ├── hooks/       # use-lists, use-items, use-auth
│   │   ├── lib/         # api.ts, supabase client
│   │   └── types/       # TypeScript types
│   └── .env             # Variáveis de ambiente
│
├── ws-comprai/          # Backend Spring Boot
│   ├── src/main/java/com/comprai/
│   │   ├── config/      # SecurityConfig, WebClientConfig
│   │   ├── controller/  # AiController (5 endpoints)
│   │   ├── service/     # ClaudeService, SupabaseService, AiService
│   │   └── dto/         # Request/Response records
│   └── .env             # ANTHROPIC_API_KEY, SUPABASE_*
│
└── comprai-app/         # Database Migrations
    ├── supabase/migrations/
    │   ├── 20250001_initial_schema.sql
    │   └── 20250002_rls_policies.sql
    ├── CLAUDE.md
    └── FRONTEND_ENV.md
```

## 🔄 Fluxo de Dados

```
[Frontend] ---(Supabase Auth)---> [Supabase DB]
     |
     |---(JWT Bearer Token)---> [Backend Spring Boot]
                                      |
                                      |---> [Claude API]
                                      |
                                      |---> [Supabase REST API]
```

## 🗄️ Database Schema (Supabase)

### Tabelas

1. **lists** - Listas de compras
   - `id`, `name`, `emoji`, `share_code`, `budget`, `is_recurring`
   - `archived_at`, `created_by`, `created_at`

2. **list_members** - Membros de cada lista
   - `list_id`, `user_id`, `store_name`, `joined_at`

3. **items** - Itens das listas
   - `id`, `list_id`, `name`, `quantity`, `category`
   - `checked`, `checked_by`, `added_by`, `created_at`

4. **item_price_observations** - Observações de preços
   - `id`, `item_id`, `user_id`, `store_name`, `price`, `observed_at`

5. **purchase_history** - Histórico de compras
   - `id`, `user_id`, `list_id`, `list_name`, `list_emoji`
   - `item_name`, `category`, `quantity`, `price`, `store_name`, `purchased_at`

### RLS (Row Level Security)

- ✅ Todos os usuários só veem suas próprias listas (via `list_members`)
- ✅ Apenas criador pode deletar/atualizar lista
- ✅ Membros podem adicionar/editar itens
- ✅ Histórico de compras privado por usuário

### Realtime

- ✅ `items` - mudanças em tempo real
- ✅ `item_price_observations` - preços atualizados
- ✅ `list_members` - membros entram/saem

## 🔐 Autenticação

### Frontend → Supabase
```typescript
// Login Social (Google/Apple)
const { data } = await supabase.auth.signInWithOAuth({
  provider: 'google',
  options: { redirectTo: 'comprai://login-callback' }
})

// Token JWT automático
const token = session?.access_token
```

### Frontend → Backend
```typescript
// Toda chamada inclui JWT
const response = await fetch(`${API_URL}/api/ai/parse-list`, {
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(request)
})
```

### Backend (Spring Security)
```java
// JwtAuthFilter valida JWT do Supabase
Claims claims = Jwts.parser()
  .verifyWith(new SecretKeySpec(jwtSecret.getBytes(), "HmacSHA256"))
  .build()
  .parseSignedClaims(token)
  .getPayload();

String userId = claims.getSubject();
```

## 🤖 Endpoints AI (Backend)

Base URL: `http://localhost:8080/api/ai/` (dev) | `https://comprai.logos.api.br/api/ai/` (prod)

### 1. Parse List (Vision)
**POST** `/parse-list`
```json
{
  "listId": "uuid",
  "imageBase64": "data:image/jpeg;base64,...",
  "mediaType": "image/jpeg"
}
```

### 2. Suggest Items
**POST** `/suggest`
```json
{
  "context": "churrasco para 10 pessoas",
  "listId": "uuid"
}
```

### 3. Check Cart
**POST** `/check-cart`
```json
{
  "listId": "uuid",
  "budget": 150.00
}
```

### 4. Scan Home
**POST** `/scan-home`
```json
{
  "imageBase64": "data:image/jpeg;base64,...",
  "mediaType": "image/jpeg"
}
```

### 5. Optimize Budget
**POST** `/optimize-budget`
```json
{
  "listId": "uuid",
  "budget": 100.00
}
```

## 🌐 Variáveis de Ambiente

### Frontend (.env)
```bash
VITE_SUPABASE_URL=https://jgxukiayybgkssdvmhfu.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=eyJhbGci...
VITE_API_URL=http://localhost:8080
VITE_REDIRECT_URL=comprai://login-callback
```

### Backend (.env)
```bash
ANTHROPIC_API_KEY=sk-ant-api03-...
SUPABASE_URL=https://jgxukiayybgkssdvmhfu.supabase.co
SUPABASE_SERVICE_KEY=eyJhbGci... (service_role)
SUPABASE_JWT_SECRET=TyTegXYU2UgAt8kUX8zcd...
```

## 🚀 Como Executar

### 1. Database (Já aplicado)
```bash
# Migrations já estão no Supabase:
# - 20250001_initial_schema.sql ✅
# - 20250002_rls_policies.sql ✅
```

### 2. Backend
```bash
cd C:\Users\faels\projects\comprai\ws-comprai

# Configurar .env com as credenciais

# Executar
./mvnw spring-boot:run

# Ou build
./mvnw package -DskipTests
java -jar target/ws-comprai-0.1.0.jar
```

### 3. Frontend
```bash
cd C:\Users\faels\projects\comprai\comprai

# Instalar dependências
bun install

# Configurar .env

# Dev
bun run dev

# Build
bun run build
```

## 📱 Deep Links (Mobile)

**Esquema**: `comprai://`

### OAuth Callback
```
comprai://login-callback?access_token=...&refresh_token=...
```

Frontend captura via `useDeepLinkAuth()` hook.

## 🔧 Tecnologias

### Frontend
- React 18
- TanStack Router + Query
- Supabase JS Client
- TypeScript
- Vite
- Capacitor (mobile)

### Backend
- Spring Boot 3.4
- Java 21
- Spring Security + JWT
- WebClient (reactive)
- Anthropic API (via HTTP)

### Database
- PostgreSQL (Supabase)
- Row Level Security
- Realtime subscriptions
- Auth integrado

## ✅ Status Atual

- ✅ Database schema aplicado
- ✅ RLS policies configuradas
- ✅ Backend completo (5 endpoints AI)
- ✅ Frontend completo (Lovable)
- ✅ Autenticação JWT funcionando
- ✅ Variáveis de ambiente sincronizadas
- ✅ Documentação completa

## 🎯 Próximos Passos

1. Configurar OAuth providers (Google/Apple) no Supabase Dashboard
2. Testar endpoints AI com imagens reais
3. Deploy do backend (comprai.logos.api.br)
4. Build mobile com Capacitor
5. Testes E2E completos
