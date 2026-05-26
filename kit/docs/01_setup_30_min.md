# Setup em 30 minutos — Diana Starter Kit

Guia step-by-step. Cronometrei: dá em ~30 min se Homebrew/Python já estão prontos.

## Checklist pré-instalação (5 min)

```bash
# 1. Homebrew instalado?
brew --version || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Python 3.10+ instalado?
python3 --version  # deve ser ≥ 3.10
# Senão: brew install python@3.12

# 3. RAM check (Mac M-series)
sysctl hw.memsize | awk '{print $2/1073741824 " GB"}'
# Mínimo recomendado: 24GB

# 4. Disk free
df -h ~ | awk 'NR==2 {print $4}'
# Mínimo: 50GB

# 5. Local AI dirs
mkdir -p ~/ia-local/{data/logs,data/work_log,bin}
mkdir -p ~/Library/LaunchAgents
```

## Etapa 1: Instalar Ollama (3 min)

```bash
brew install --cask ollama
open -a Ollama   # vai dar permissão no Mac
```

Espera o ícone aparecer na barra de status. Confere:
```bash
curl http://127.0.0.1:11434
# Deve responder "Ollama is running"
```

## Etapa 2: Baixar modelo (10-15 min, depende da net)

```bash
ollama pull qwen3:14b
```

~9GB. Demora.

Enquanto baixa, continua etapa 3 em outro terminal.

## Etapa 3: Setup Python env (3 min)

```bash
# Cria virtualenv
python3 -m venv ~/ia-local/bin/env
source ~/ia-local/bin/env/bin/activate

# Instala deps mínimas
pip install ollama feedparser pypdf chromadb

# (Opcional) MLX se quer fine-tune depois
pip install mlx mlx-lm mlx-lm-lora
```

## Etapa 4: Copiar configs do starter kit (3 min)

```bash
# Você descompactou o kit em ~/diana-starter-kit
cd ~/diana-starter-kit

# Copia scripts
cp kit/scripts/*.py ~/ia-local/
chmod +x ~/ia-local/*.py

# Copia configs
cp kit/configs/.env.example ~/ia-local/.env
# Edita ~/ia-local/.env com seu nome, etc

# Copia LaunchAgents
cp kit/plists/*.plist ~/Library/LaunchAgents/
```

## Etapa 5: Editar configs essenciais (5 min)

Edita `~/ia-local/.env`:

```bash
DIANA_USER_NAME=Rafael          # seu nome
DIANA_USER_EMAIL=...            # opcional
DIANA_AGENT_NAME=Diana          # nome do seu agente
DIANA_FAST_MODEL=qwen3:14b
DIANA_LLM_STRATEGY=ollama-only
DIANA_MEM0_ENABLED=1
```

## Etapa 6: Carregar LaunchAgents (2 min)

```bash
launchctl load -w ~/Library/LaunchAgents/com.rafa.diana-call.plist
launchctl load -w ~/Library/LaunchAgents/com.rafa.diana-knowledge-feed.plist
launchctl load -w ~/Library/LaunchAgents/com.rafa.diana-work-loop.plist
launchctl load -w ~/Library/LaunchAgents/com.rafa.diana-learning.plist
```

Confere:
```bash
launchctl list | grep diana
# Deve mostrar 4 entradas
```

## Etapa 7: Smoke test (2 min)

```bash
# Diana respondendo?
curl http://127.0.0.1:8600/healthz
# {"status":"alive","service":"diana-call-server"}

# Test inferência
curl http://127.0.0.1:11434/api/generate -d '{
  "model": "qwen3:14b",
  "prompt": "Diga oi em PT-BR brasileiro",
  "stream": false,
  "think": false
}'
# response: "Oi" (ou similar curto e direto)
```

Se chegou aqui: **Diana rodando** ✅

## Próximos passos opcionais

### Customizar personality
Edita `~/ia-local/configs/personality_system_prompt.md`. Diana usa esse system prompt em toda conversa.

### Adicionar Tom (segundo agente)
```bash
# Veja docs/06_multi_agent.md (se incluído)
# Padrão: copiar diana-call.plist com env diferente,
# nova identidade ed25519 em ~/.diana-tom/keys
```

### Treinar ORPO adapter
```bash
# Acumular pares chosen/rejected primeiro
# (work_loop captura via preference_collector)
# Depois: docs/04_finetuning_cheatsheet.md
```

### Knowledge feed customizado
Edita `~/ia-local/knowledge_feed.py`:
- Adiciona/remove keywords AI_KEYWORDS, CRYPTO_KEYWORDS
- Adiciona sources (subreddit, RSS feeds)

## Troubleshooting

**Ollama "model not found"**
→ Esqueceu `ollama pull qwen3:14b`. Demora.

**Healthz 8600 retorna 000**
→ LaunchAgent não carregou. `launchctl list | grep diana-call`. Se status `-6`: erro fatal — `tail data/logs/diana_call_server.err.log`.

**Knowledge feed não roda**
→ Cron horário (02h + 21h). Force manual: `python3 ~/ia-local/knowledge_feed.py`.

**Latência absurda (>10s "oi")**
→ Modelo muito grande pro RAM. Use qwen3:8b. Ou esqueça multi-modelo.

**OOM Metal**
→ Outros modelos Ollama carregados. `curl http://127.0.0.1:11434/api/ps` mostra. Use `keep_alive: 0` pra descarregar.

## Cheatsheets adicionais

- `docs/02_ollama_cheatsheet.md` — API, CLI, env vars
- `docs/03_mlx_cheatsheet.md` — quando ir nativo Apple Silicon
- `docs/04_finetuning_cheatsheet.md` — LoRA + ORPO
- `docs/05_debugging_cheatsheet.md` — bugs comuns

## Suporte

Discord: `diana-starter-kit.gumroad.com/discord` (free)
Issues: `github.com/rafaelvieira/diana-starter-kit`

⚡ Se valeu, manda uns sats: `bc1qsawwace2ef97eklnv9snjflrluamkacwreynqz`
