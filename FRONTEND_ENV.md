# Variáveis de Ambiente para o Frontend (Lovable)

Configure estas variáveis no projeto frontend (comprai):

## Supabase (Públicas - seguro expor no frontend)

```bash
VITE_SUPABASE_URL=https://jgxukiayybgkssdvmhfu.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpneHVraWF5eWJna3NzZHZtaGZ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAwMDcyMTAsImV4cCI6MjA5NTU4MzIxMH0.q_V7uqBXmOy5D-w_DimMi2gIKt_8U68NcVtEG54cIMo
```

## Backend API (Spring Boot)

```bash
# Desenvolvimento local
VITE_API_URL=http://localhost:8080

# Produção
VITE_API_URL=https://comprai.logos.api.br
```

## OAuth Redirect

```bash
VITE_REDIRECT_URL=comprai://login-callback
```

---

## ⚠️ IMPORTANTE - Segurança

**NUNCA exponha no frontend:**
- ❌ `SUPABASE_SERVICE_KEY` (só no backend!)
- ❌ `SUPABASE_JWT_SECRET` (só no backend!)
- ❌ `ANTHROPIC_API_KEY` (só no backend!)

**Seguro expor no frontend:**
- ✅ `SUPABASE_URL`
- ✅ `SUPABASE_ANON_KEY` (chave pública)
- ✅ `API_URL` (endpoint público)

---

## Integração Supabase no Frontend

```typescript
// src/lib/supabase.ts
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
```

## Auth Social - Login

```typescript
// Login com Google
const { data, error } = await supabase.auth.signInWithOAuth({
  provider: 'google',
  options: {
    redirectTo: 'comprai://login-callback'
  }
})

// Login com Apple
const { data, error } = await supabase.auth.signInWithOAuth({
  provider: 'apple',
  options: {
    redirectTo: 'comprai://login-callback'
  }
})
```

## Chamadas para o Backend AI

```typescript
// Exemplo: Parse List
const token = (await supabase.auth.getSession()).data.session?.access_token

const response = await fetch(`${import.meta.env.VITE_API_URL}/api/ai/parse-list`, {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    listId: 'uuid-here',
    imageBase64: 'base64-string',
    mediaType: 'image/jpeg'
  })
})

const result = await response.json()
```
