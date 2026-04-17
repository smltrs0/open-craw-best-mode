# ============================================================
# Dockerfile — OpenClaw con soporte completo para Skills Python
# Base: ghcr.io/hostinger/hvps-openclaw:latest  (Debian Bookworm)
#
# FIX v2: Debian 12 requiere --break-system-packages en pip.
#         Paquetes que necesitan compilación (faiss-cpu, sentence-transformers)
#         se instalan con sus dependencias de build correctas.
# ============================================================
FROM ghcr.io/hostinger/hvps-openclaw:latest

USER root

# ── 1. Paquetes del sistema (Debian Bookworm / apt-get) ──────────────────────
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
    build-essential \
    cmake \
    g++ \
    libgomp1 \
    poppler-utils \
    pandoc \
    ffmpeg \
    libopus-dev \
    dnsutils \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# ── 2. Alias python → python3 ────────────────────────────────────────────────
RUN ln -sf /usr/bin/python3 /usr/bin/python

# ── 3. Librerías Python esenciales ───────────────────────────────────────────
# Debian 12 (Bookworm) requiere --break-system-packages fuera de un venv.
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
    "pydantic-settings" \
    python-dotenv \
    rich \
    typer \
    pytest

# ── 4. Paquetes de ML / Vector DB ────────────────────────────────────────────
# Separados porque necesitan cmake/g++ del paso 1.
# faiss-cpu tiene fallback: si falla en la arquitectura, la build no muere.
RUN pip3 install --no-cache-dir --break-system-packages \
    chromadb \
    "sentence-transformers>=2.7.0" \
    && pip3 install --no-cache-dir --break-system-packages faiss-cpu \
    || echo "WARN: faiss-cpu no disponible en esta arquitectura, continuando..."

# ── 5. Instalar navegadores de Playwright (solo Chromium) ────────────────────
RUN python3 -m playwright install chromium --with-deps || true

# ── 6. Directorio de skills personalizado ────────────────────────────────────
RUN mkdir -p /root/.openclaw/workspace/skills

# ── 7. Variables de entorno ───────────────────────────────────────────────────
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright \
    DISPLAY=:99

# Entrypoint y CMD heredados de la imagen base
