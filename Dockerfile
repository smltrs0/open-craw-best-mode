# ============================================================
# Dockerfile - OpenClaw con soporte completo para Skills Python
# Base: ghcr.io/hostinger/hvps-openclaw:latest
# ============================================================
FROM ghcr.io/hostinger/hvps-openclaw:latest

# Correr como root para instalar paquetes
USER root

# ── 1. Actualizar APT e instalar dependencias del sistema ────────────────────
# Python core, utilidades, PDF, multimedia, red
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    curl \
    wget \
    git \
    jq \
    unzip \
    zip \
    ca-certificates \
    gnupg \
    poppler-utils \
    pandoc \
    ffmpeg \
    libopus-dev \
    dnsutils \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# ── 2. Alias python → python3 ────────────────────────────────────────────────
RUN ln -sf /usr/bin/python3 /usr/bin/python

# ── 3. Actualizar pip e instalar librerías Python más comunes en Skills ───────
# LLM, scraping, datos/archivos, utilidades, vector DB, testing
RUN pip3 install --no-cache-dir --break-system-packages \
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
RUN mkdir -p /root/.openclaw/workspace/skills

# ── 6. Variables de entorno útiles para skills que invocan Python ────────────
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright \
    DISPLAY=:99

# ── 7. El entrypoint y CMD los hereda de la imagen base ──────────────────────
