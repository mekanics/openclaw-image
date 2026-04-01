# Thin layer on top of official OpenClaw image.
# Adds system tools needed by skills and agents.
#
# renovate datasource=docker depName=ghcr.io/openclaw/openclaw
FROM ghcr.io/openclaw/openclaw:2026.3.31-slim@sha256:260b658c7ce73c794a9eb6a2a7f6b4fa65f2f15fd68bc47b916d1816d0227846

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    jq \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI (gh)
# https://github.com/cli/cli/blob/trunk/docs/install_linux.md
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && apt-get install -y --no-install-recommends gh && \
    rm -rf /var/lib/apt/lists/*

# Install Playwright + Chromium for browser automation
# The official slim image only includes this with OPENCLAW_INSTALL_BROWSER=1
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y --no-install-recommends xvfb && \
    mkdir -p /home/node/.cache/ms-playwright && \
    PLAYWRIGHT_BROWSERS_PATH=/home/node/.cache/ms-playwright \
    node /app/node_modules/playwright-core/cli.js install --with-deps chromium && \
    chown -R node:node /home/node/.cache/ms-playwright && \
    rm -rf /var/lib/apt/lists/*
ENV PLAYWRIGHT_BROWSERS_PATH=/home/node/.cache/ms-playwright

# Install uv — fast Python package/project manager (replaces pip + venv)
# https://docs.astral.sh/uv/
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
ENV UV_LINK_MODE=copy

USER node
