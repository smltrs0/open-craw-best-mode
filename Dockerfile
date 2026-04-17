# ============================================================
# Dockerfile - OpenClaw con soporte completo para Skills Python
# Base: ghcr.io/hostinger/hvps-openclaw:latest
# Nota: la imagen base usa Homebrew como gestor de paquetes
# ============================================================
FROM ghcr.io/hostinger/hvps-openclaw:latest

# ── 1. Instalar dependencias del sistema vía Homebrew ────────────────────────
# Python core, utilidades, PDF, multimedia, red
# Nombres de paquetes Homebrew (≠ apt): poppler-utils→poppler,
#   libopus-dev→opus, dnsutils→bind
RUN brew install \
    python \
    curl \
    wget \
    git \
    jq \
    gnupg \
    poppler \
    pandoc \
    ffmpeg \
    opus \
    bind

# ── 2. Alias python → python3 ────────────────────────────────────────────────
RUN brew link python --overwrite 2>/dev/null || true

# ── 3. Instalar librerías Python más comunes en Skills ───────────────────────
# LLM, scraping, datos/archivos, utilidades, vector DB, testing
RUN pip3 install --no-cache-dir \
    openai \
    anthropic \
    langchain \
    langchain-openai \
    langchain-anthropic \
    requests \
    httpx \
    beautifulsoup4 \
    playwright \
    pandas \
    openpyxl \
    pypdf \
    pdfplumber \
    python-docx \
    pillow \
    pydantic \
    python-dotenv \
    rich \
    typer \
    chromadb \
    faiss-cpu \
    sentence-transformers \
    pytest

# ── 4. Instalar navegadores de Playwright ────────────────────────────────────
#    Solo Chromium (más liviano). Cambia a "playwright install" para todos.
RUN python3 -m playwright install chromium --with-deps || true

# ── 5. Crear directorio de skills personalizado en el workspace ───────────────
RUN mkdir -p ~/.openclaw/workspace/skills

# ── 6. Variables de entorno útiles para skills que invocan Python ────────────
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright \
    DISPLAY=:99

# ── 7. El entrypoint y CMD los hereda de la imagen base ──────────────────────
