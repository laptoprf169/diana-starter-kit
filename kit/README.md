# Diana Starter Kit

Pacote pré-configurado pra você ter uma **IA local PT-BR rodando em 30 minutos** no seu Mac.

> Não inclui pesos de modelo (são baixados via Ollama). Inclui tudo o que cerca: LaunchAgents, scripts, configs, system prompts, e os bugs já consertados.

## Contém

```
kit/
├── plists/                 # LaunchAgents prontos (cron, KeepAlive)
│   ├── diana-call.plist
│   ├── diana-knowledge-feed.plist
│   ├── diana-work-loop.plist
│   └── diana-learning.plist
├── scripts/                # Scripts Python validados
│   ├── knowledge_feed.py
│   ├── work_loop.py
│   ├── supervisor.py
│   └── update_dashboard.py
├── configs/                # Configs prontas
│   ├── .env.example
│   ├── ollama.json
│   └── personality_system_prompt.md
└── docs/                   # 5 cheatsheets + guia setup
    ├── 01_setup_30_min.md
    ├── 02_ollama_cheatsheet.md
    ├── 03_mlx_cheatsheet.md
    ├── 04_finetuning_cheatsheet.md
    └── 05_debugging_cheatsheet.md
```

## Setup

```bash
# 1. Descompacta
unzip diana-starter-kit-v1.zip ~/

# 2. Roda installer
cd ~/diana-starter-kit && bash install.sh

# 3. Em 30 min você tem:
#    - Ollama + qwen3:14b baixado
#    - Diana respondendo em port 8600
#    - Knowledge feed pegando arxiv 2x/dia
#    - Work loop processing autônomo
```

## Pré-requisitos

- Mac M-series (M1/M2/M3 — não Intel)
- macOS 14+
- 24GB+ RAM unified memory recomendado
- 50GB free space (modelos + cache)
- Python 3.10+ (`brew install python@3.12`)
- Homebrew

## O que vem CONFIGURADO

✅ LaunchAgents que sobrevivem reboot
✅ Knowledge feed PT-BR (arxiv + HN + r/LocalLLaMA)
✅ Ollama com keep_alive + parallel otimizado
✅ System prompt PT-BR brasileiro real (sem ChatGPT-ês)
✅ Guardrails de segurança (whitelist paths, blocklist commands)
✅ Auto-rollback se smoke tests quebram

## O que VOCÊ precisa fazer depois

- (Opcional) treinar próprio ORPO adapter — guia em docs/04
- (Opcional) integrar próprio RAG dataset — guia em docs/02
- (Opcional) adicionar agentes adicionais (Tom, Vera) — pattern documentado

## Licença

Tudo MIT. Use, modifique, redistribua. Atribuição opcional.

## Suporte

Discord (free tier): `diana-starter-kit.gumroad.com/discord`

Issues: github.com/rafaelvieira/diana-starter-kit

## Pagamento

Pay-what-you-want via Gumroad (R$0-99). Sugerido R$49 se pegou valor.

Ou direto em BTC:
⚡ `bc1qsawwace2ef97eklnv9snjflrluamkacwreynqz`
