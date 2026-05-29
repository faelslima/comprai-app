# ComprAI - Lista de Compras Inteligente com IA

App mobile para gerenciar listas de compras colaborativas com assistente de IA (Claude) integrado.

## 📁 Estrutura do Projeto

Este repositório contém apenas as **migrations do Supabase** e a documentação central.

Os outros componentes estão em repositórios separados:

```
comprai/
├── comprai-app/           # 👉 VOCÊ ESTÁ AQUI (Supabase migrations + docs)
│   ├── supabase/migrations/
│   │   ├── 20250001_initial_schema.sql
│   │   └── 20250002_rls_policies.sql
│   ├── ARCHITECTURE.md    # Arquitetura completa
│   ├── FRONTEND_ENV.md    # Variáveis de ambiente do frontend
│   └── CLAUDE.md          # Instruções do projeto
│
├── comprai/               # Frontend Lovable (React + TanStack)
│   └── [Frontend completo já implementado]
│
└── ws-comprai/            # Backend Spring Boot
    └── [Backend completo já implementado]
```

## 🚀 Quick Start

### 1. Database (Supabase)

As migrations já foram aplicadas no projeto:
- URL: `https://jgxukiayybgkssdvmhfu.supabase.co`
- ✅ Schema completo (5 tabelas)
- ✅ RLS policies
- ✅ Realtime habilitado

### 2. Backend

```bash
cd ../ws-comprai
./mvnw spring-boot:run
```

Porta: `8080`

### 3. Frontend

```bash
cd ../comprai
bun install
bun run dev
```

Porta: `5173`

## 📚 Documentação

- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - Arquitetura completa do sistema
- **[FRONTEND_ENV.md](./FRONTEND_ENV.md)** - Configuração de variáveis de ambiente
- **[CLAUDE.md](./CLAUDE.md)** - Instruções do projeto

## 🗄️ Database Schema

5 tabelas principais:
1. `lists` - Listas de compras
2. `list_members` - Membros (colaboração)
3. `items` - Itens das listas
4. `item_price_observations` - Observações de preços
5. `purchase_history` - Histórico de compras

Veja detalhes em [ARCHITECTURE.md](./ARCHITECTURE.md)

## 🤖 Features IA

- 📸 **Parse List** - Extrai itens de foto da lista
- 💡 **Suggest** - Sugere itens baseado em contexto
- 💰 **Check Cart** - Verifica se está dentro do orçamento
- 🏠 **Scan Home** - Detecta itens faltando na despensa
- 📊 **Optimize Budget** - Otimiza compras pelo orçamento

## 🔐 Autenticação

- Supabase Auth (Google + Apple OAuth)
- JWT tokens
- Row Level Security (RLS)

## ✅ Status

Todas as etapas concluídas:
- ✅ Migrations aplicadas no Supabase
- ✅ Backend Spring Boot completo
- ✅ Frontend Lovable completo
- ✅ Integração Claude API
- ✅ Documentação completa
- ✅ Variáveis de ambiente sincronizadas

## 🎯 Próximos Passos

1. Configurar OAuth providers no Supabase Dashboard
2. Deploy do backend em produção
3. Build mobile com Capacitor
4. Testes E2E

---

**Projeto**: ComprAI  
**Stack**: React + Spring Boot + Supabase + Claude AI  
**Data**: Maio 2026
