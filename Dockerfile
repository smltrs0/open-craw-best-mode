# ============================================================
# Dockerfile — OpenClaw Hostinger + ffmpeg (para notas de voz)
# Base: ghcr.io/hostinger/hvps-openclaw:latest (usa brew, NO apt)
# ============================================================
FROM ghcr.io/hostinger/hvps-openclaw:latest

USER root

ENV HOMEBREW_NO_AUTO_UPDATE=1 \
    HOMEBREW_NO_INSTALL_CLEANUP=1 \
    PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

# ── ffmpeg: necesario para decodificar notas de voz .ogg/Opus ─────────────────
RUN brew install ffmpeg || true

# ── Herramientas útiles para skills ───────────────────────────────────────────
RUN brew install git || true
RUN brew install jq || true
RUN brew install python3 || true

# ── pip: librerías Python por si tus skills las necesitan ─────────────────────
RUN pip3 install --no-cache-dir --break-system-packages \
    openai anthropic requests httpx beautifulsoup4 \
    pandas pillow pydantic python-dotenv rich \
    2>/dev/null \
    || pip3 install --no-cache-dir \
    openai anthropic requests httpx beautifulsoup4 \
    pandas pillow pydantic python-dotenv rich \
    || echo "WARN: pip install parcial"

# Alias
RUN ln -sf "$(which python3)" /usr/local/bin/python 2>/dev/null || true

ENV PYTHONUNBUFFERED=1

# Entrypoint heredado de la imagen base
