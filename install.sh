#!/bin/bash
# Diana Starter Kit installer
# Tested on macOS 14+, Apple Silicon

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Diana Starter Kit · Installer v1.0${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════${NC}"
echo

# Check macOS
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo -e "${RED}Este kit é só pra macOS.${NC}"
    exit 1
fi

# Check Apple Silicon
if [[ "$(uname -m)" != "arm64" ]]; then
    echo -e "${YELLOW}⚠️  Detectado Intel Mac. Performance será limitada.${NC}"
fi

# Check Homebrew
if ! command -v brew &> /dev/null; then
    echo -e "${RED}Homebrew não encontrado. Instala primeiro:${NC}"
    echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    exit 1
fi
echo -e "${GREEN}✓${NC} Homebrew encontrado"

# Check Python
if ! command -v python3 &> /dev/null; then
    echo -e "${YELLOW}Python3 não encontrado. Instalando...${NC}"
    brew install python@3.12
fi
PYTHON_VERSION=$(python3 --version | awk '{print $2}')
echo -e "${GREEN}✓${NC} Python $PYTHON_VERSION"

# Check Ollama
if ! command -v ollama &> /dev/null && ! [ -d "/Applications/Ollama.app" ]; then
    echo -e "${YELLOW}Ollama não encontrado. Instalando...${NC}"
    brew install --cask ollama
    open -a Ollama
    echo "Aguarda app abrir e dar permissão... [Enter quando pronto]"
    read
fi
echo -e "${GREEN}✓${NC} Ollama encontrado"

# Setup dirs
echo
echo -e "${YELLOW}→ Criando estrutura ~/ia-local...${NC}"
mkdir -p ~/ia-local/{data/{logs,work_log,knowledge_feed},bin}
mkdir -p ~/Library/LaunchAgents

# Copy files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo -e "${YELLOW}→ Copiando scripts e configs...${NC}"
cp -v "$SCRIPT_DIR"/kit/scripts/*.py ~/ia-local/ 2>/dev/null || true
cp -v "$SCRIPT_DIR"/kit/configs/.env.example ~/ia-local/.env.example
cp -v "$SCRIPT_DIR"/kit/configs/*.md ~/ia-local/ 2>/dev/null || true
cp -v "$SCRIPT_DIR"/kit/plists/*.plist ~/Library/LaunchAgents/

# Pull model (background)
echo
echo -e "${YELLOW}→ Baixando qwen3:14b (~9GB, demora 5-15 min)...${NC}"
ollama pull qwen3:14b &
PULL_PID=$!

# Setup virtualenv
echo -e "${YELLOW}→ Criando venv Python e instalando deps...${NC}"
python3 -m venv ~/ia-local/bin/env
source ~/ia-local/bin/env/bin/activate
pip install --quiet ollama feedparser pypdf chromadb sentence-transformers

# Wait for pull
echo -e "${YELLOW}→ Aguardando download terminar...${NC}"
wait $PULL_PID

# Verify model
if ! ollama list | grep -q "qwen3:14b"; then
    echo -e "${RED}✗ qwen3:14b não baixou. Roda manualmente: ollama pull qwen3:14b${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} qwen3:14b pronto"

# Setup .env if missing
if [ ! -f ~/ia-local/.env ]; then
    cp ~/ia-local/.env.example ~/ia-local/.env
    echo -e "${YELLOW}→ ~/ia-local/.env criado a partir do template${NC}"
    echo -e "${YELLOW}  Edita com seus dados ANTES de subir LaunchAgents${NC}"
fi

# Ollama settings
echo
echo -e "${YELLOW}→ Configurando Ollama parallel...${NC}"
launchctl setenv OLLAMA_NUM_PARALLEL 2
launchctl setenv OLLAMA_MAX_LOADED_MODELS 2
launchctl setenv OLLAMA_KEEP_ALIVE 10m

# Load LaunchAgents
echo
echo -e "${YELLOW}→ Carregando LaunchAgents...${NC}"
for plist in ~/Library/LaunchAgents/com.rafa.diana-*.plist; do
    if [ -f "$plist" ]; then
        launchctl unload -w "$plist" 2>/dev/null || true
        launchctl load -w "$plist"
        echo -e "${GREEN}✓${NC} loaded $(basename $plist)"
    fi
done

# Smoke test
sleep 3
echo
echo -e "${YELLOW}→ Smoke test...${NC}"
if curl -sf http://127.0.0.1:11434/api/tags > /dev/null; then
    echo -e "${GREEN}✓${NC} Ollama respondendo"
else
    echo -e "${RED}✗${NC} Ollama não responde"
fi

if curl -sf http://127.0.0.1:8600/healthz > /dev/null; then
    echo -e "${GREEN}✓${NC} Diana respondendo em :8600"
else
    echo -e "${YELLOW}⚠${NC} Diana 8600 ainda não disponível (aguarda 30s pra primeiro boot)"
fi

echo
echo -e "${GREEN}══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Setup concluído.${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════${NC}"
echo
echo "Próximos passos:"
echo
echo "  1. Edita ~/ia-local/.env (seu nome, etc)"
echo "  2. Testa: curl -s http://127.0.0.1:11434/api/generate \\"
echo "       -d '{\"model\":\"qwen3:14b\",\"prompt\":\"oi\",\"stream\":false}'"
echo "  3. Lê docs em ~/ia-local/01_setup_30_min.md"
echo
echo "Dúvida? Discord: diana-starter-kit.gumroad.com/discord"
echo "⚡ Se foi útil: bc1qsawwace2ef97eklnv9snjflrluamkacwreynqz"
echo
