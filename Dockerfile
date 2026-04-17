# ============================================================
# Dockerfile - OpenClaw con soporte completo para Skills Python
# Base: ghcr.io/hostinger/hvps-openclaw:latest
# ============================================================
FROM ghcr.io/hostinger/hvps-openclaw:latest

# ── 1. Instalar dependencias del sistema ─────────────────────────────────────
# Detecta el gestor de paquetes disponible: apk (Alpine) o apt-get (Debian/Ubuntu).
# Mapeo de nombres: libopus-dev→opus-dev(apk), dnsutils→bind-tools(apk),
#   iputils-ping→iputils(apk), python3-venv/dev incluidos en python3(apk).
RUN if command -v apk >/dev/null 2>&1; then \
        apk add --no-cache \
            python3 py3-pip python3-dev \
            curl wget git jq unzip zip \
            ca-certificates gnupg \
            poppler-utils pandoc ffmpeg \
            opus-dev bind-tools iputils; \
    elif apt-get update -qq >/dev/null 2>&1; then \
        apt-get install -y --no-install-recommends \
            python3 python3-pip python3-venv python3-dev \
            curl wget git jq unzip zip \
            ca-certificates gnupg \
            poppler-utils pandoc ffmpeg \
            libopus-dev dnsutils iputils-ping \
        && rm -rf /var/lib/apt/lists/*; \
    else \
        echo "WARNING: No supported package manager found, skipping system packages."; \
    fi

# ── 2. Alias python → python3 ────────────────────────────────────────────────
RUN ln -sf /usr/bin/python3 /usr/bin/python 2>/dev/null || true

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
