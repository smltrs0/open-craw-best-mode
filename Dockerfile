# ============================================================
# Dockerfile — OpenClaw + Python (extensión de imagen Hostinger)
# Base: ghcr.io/hostinger/hvps-openclaw:latest
#
# Estrategia: cada apt-get es independiente con || true
# para que UN paquete que no exista no mate todo el build.
# ============================================================
FROM ghcr.io/hostinger/hvps-openclaw:latest

USER root

ENV DEBIAN_FRONTEND=noninteractive

# ── 1. Solo lo esencial y garantizado en cualquier Debian/Ubuntu ──────────────
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-dev \
    build-essential \
    git \
    curl \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ── 2. Paquetes opcionales — cada uno aislado, falla silenciosamente ──────────
RUN apt-get update -qq && apt-get install -y --no-install-recommends ffmpeg     2>/dev/null || true && rm -rf /var/lib/apt/lists/*
RUN apt-get update -qq && apt-get install -y --no-install-recommends libopus-dev 2>/dev/null || true && rm -rf /var/lib/apt/lists/*
RUN apt-get update -qq && apt-get install -y --no-install-recommends poppler-utils 2>/dev/null || true && rm -rf /var/lib/apt/lists/*
RUN apt-get update -qq && apt-get install -y --no-install-recommends pandoc      2>/dev/null || true && rm -rf /var/lib/apt/lists/*
RUN apt-get update -qq && apt-get install -y --no-install-recommends jq unzip zip 2>/dev/null || true && rm -rf /var/lib/apt/lists/*
RUN apt-get update -qq && apt-get install -y --no-install-recommends cmake g++ libgomp1 2>/dev/null || true && rm -rf /var/lib/apt/lists/*

# ── 3. Alias python → python3 ────────────────────────────────────────────────
RUN ln -sf /usr/bin/python3 /usr/bin/python

# ── 4. pip — paquetes core garantizados ──────────────────────────────────────
# Intentamos con --break-system-packages primero (Debian 12),
# si falla probamos sin él (Debian 11 / Ubuntu más antiguo)
RUN pip3 install --no-cache-dir --break-system-packages \
    openai \
    anthropic \
    requests \
    httpx \
    beautifulsoup4 \
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
    pytest \
    2>/dev/null \
    || pip3 install --no-cache-dir \
    openai \
    anthropic \
    requests \
    httpx \
    beautifulsoup4 \
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
    pytest

# ── 5. LangChain — separado por si alguna sub-dependencia falla ───────────────
RUN pip3 install --no-cache-dir --break-system-packages \
    "langchain>=0.2" langchain-openai langchain-anthropic \
    || pip3 install --no-cache-dir \
    "langchain>=0.2" langchain-openai langchain-anthropic \
    || echo "WARN: langchain no instalado"

# ── 6. Playwright ─────────────────────────────────────────────────────────────
RUN pip3 install --no-cache-dir --break-system-packages playwright \
    || pip3 install --no-cache-dir playwright \
    || echo "WARN: playwright no instalado"
RUN python3 -m playwright install chromium --with-deps || echo "WARN: chromium no instalado"

# ── 7. ML/Vector — muy opcionales, fallan silenciosamente ────────────────────
RUN pip3 install --no-cache-dir --break-system-packages chromadb \
    || pip3 install --no-cache-dir chromadb \
    || echo "WARN: chromadb no instalado"
RUN pip3 install --no-cache-dir --break-system-packages faiss-cpu \
    || echo "WARN: faiss-cpu no disponible en esta arquitectura"
RUN pip3 install --no-cache-dir --break-system-packages "sentence-transformers>=2.7.0" \
    || echo "WARN: sentence-transformers no instalado"

# ── 8. Directorio de skills ───────────────────────────────────────────────────
RUN mkdir -p /root/.openclaw/workspace/skills 2>/dev/null || \
    mkdir -p /home/node/.openclaw/workspace/skills && \
    chown -R node:node /home/node/.openclaw 2>/dev/null || true

# ── 9. Variables de entorno ───────────────────────────────────────────────────
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright \
    DEBIAN_FRONTEND=

# Entrypoint y CMD heredados de la imagen base
