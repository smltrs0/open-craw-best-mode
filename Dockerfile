# ============================================================
# Dockerfile - OpenClaw con soporte completo para Skills Python
# Base: ghcr.io/hostinger/hvps-openclaw:latest
# ============================================================
FROM ghcr.io/hostinger/hvps-openclaw:latest

# Correr como root para instalar paquetes
USER root

# ── 1. Actualizar APT e instalar dependencias del sistema ────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    # --- Python core ---
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    # --- Utilidades de sistema que las Skills más usadas necesitan ---
    curl \
    wget \
    git \
    jq \
    unzip \
    zip \
    ca-certificates \
    gnupg \
    # --- Herramientas de archivos / PDF ---
    poppler-utils \
    pandoc \
    # --- Multimedia (skills de audio/video) ---
    ffmpeg \
    libopus-dev \
    # --- Navegador headless (skills de browser/Playwright) ---
    chromium \
    chromium-driver \
    # --- Acceso a red / APIs ---
    dnsutils \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# ── 2. Alias python → python3 ────────────────────────────────────────────────
RUN ln -sf /usr/bin/python3 /usr/bin/python

# ── 3. Actualizar pip e instalar librerías Python más comunes en Skills ───────
RUN pip3 install --no-cache-dir --break-system-packages \
    # --- LLM / Agentes ---
    openai \
    anthropic \
    langchain \
    langchain-openai \
    langchain-anthropic \
    # --- Web scraping / automatización ---
    requests \
    httpx \
    beautifulsoup4 \
    playwright \
    # --- Datos / archivos ---
    pandas \
    openpyxl \
    pypdf \
    pdfplumber \
    python-docx \
    pillow \
    # --- Utilidades generales ---
    pydantic \
    python-dotenv \
    rich \
    typer \
    # --- Vector DB / memoria ---
    chromadb \
    faiss-cpu \
    sentence-transformers \
    # --- Dev / testing ---
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
