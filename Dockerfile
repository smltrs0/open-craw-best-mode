# ============================================================
# Dockerfile — OpenClaw + Python (extensión de imagen Hostinger)
# Base: ghcr.io/hostinger/hvps-openclaw:latest
#
# ⚠️  Esta imagen NO tiene apt-get. Usa Linuxbrew (brew).
# ============================================================
FROM ghcr.io/hostinger/hvps-openclaw:latest

USER root

# ── 1. Asegurar que brew está en el PATH para todos los RUN ───────────────────
ENV HOMEBREW_NO_AUTO_UPDATE=1 \
    HOMEBREW_NO_INSTALL_CLEANUP=1 \
    PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

# ── 2. Instalar Python y herramientas del sistema vía brew ────────────────────
RUN brew install python3 || echo "WARN: python3 ya instalado o no disponible"
RUN brew install git || true
RUN brew install ffmpeg || true
RUN brew install opus || true
RUN brew install poppler || true
RUN brew install jq || true
RUN brew install cmake || true

# ── 3. Alias python → python3 ────────────────────────────────────────────────
RUN ln -sf "$(which python3)" /usr/local/bin/python 2>/dev/null || true

# ── 4. pip — paquetes Python core ─────────────────────────────────────────────
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

# ── 5. LangChain — separado por si falla ──────────────────────────────────────
RUN pip3 install --no-cache-dir --break-system-packages \
    "langchain>=0.2" langchain-openai langchain-anthropic \
    || pip3 install --no-cache-dir \
    "langchain>=0.2" langchain-openai langchain-anthropic \
    || echo "WARN: langchain no instalado"

# ── 6. Playwright ─────────────────────────────────────────────────────────────
RUN pip3 install --no-cache-dir --break-system-packages playwright \
    || pip3 install --no-cache-dir playwright \
    || echo "WARN: playwright no instalado"
RUN python3 -m playwright install chromium --with-deps 2>/dev/null || echo "WARN: chromium no instalado"

# ── 7. ML/Vector — opcionales ─────────────────────────────────────────────────
RUN pip3 install --no-cache-dir --break-system-packages chromadb \
    || pip3 install --no-cache-dir chromadb \
    || echo "WARN: chromadb no instalado"
RUN pip3 install --no-cache-dir --break-system-packages faiss-cpu \
    || echo "WARN: faiss-cpu no disponible"
RUN pip3 install --no-cache-dir --break-system-packages "sentence-transformers>=2.7.0" \
    || echo "WARN: sentence-transformers no instalado"

# ── 8. Directorio de skills ───────────────────────────────────────────────────
RUN mkdir -p /home/node/.openclaw/workspace/skills 2>/dev/null || \
    mkdir -p /root/.openclaw/workspace/skills || true

# ── 9. Variables de entorno ───────────────────────────────────────────────────
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Entrypoint y CMD heredados de la imagen base
