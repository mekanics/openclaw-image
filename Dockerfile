# Thin layer on top of official OpenClaw image.
# Adds system tools needed by skills and agents.
#
# renovate datasource=docker depName=ghcr.io/openclaw/openclaw
FROM ghcr.io/openclaw/openclaw:2026.4.15-slim@sha256:18e3d1bdd714e436c11eba954a212411c77378dde32efdedfee2d62c5cdcd4eb

USER root

ENV PLAYWRIGHT_BROWSERS_PATH=/home/node/.cache/ms-playwright

# All system tooling in a single layer:
#   - ffmpeg, jq, git: required by skills/agents
#   - gh: GitHub CLI (added via official apt repo)
#   - xvfb + Playwright Chromium: browser automation (the slim base
#     image only ships these when OPENCLAW_INSTALL_BROWSER=1)
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg; \
    \
    curl -fsSL --proto '=https' --tlsv1.2 \
        https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        -o /usr/share/keyrings/githubcli-archive-keyring.gpg; \
    chmod a+r /usr/share/keyrings/githubcli-archive-keyring.gpg; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list; \
    \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ffmpeg \
        gh \
        git \
        jq \
        xvfb; \
    \
    install -d -o node -g node "$PLAYWRIGHT_BROWSERS_PATH"; \
    node /app/node_modules/playwright-core/cli.js install --with-deps chromium; \
    chown -R node:node "$PLAYWRIGHT_BROWSERS_PATH"; \
    \
    rm -rf /var/lib/apt/lists/*

# Install uv — fast Python package/project manager
# https://docs.astral.sh/uv/
# renovate datasource=docker depName=ghcr.io/astral-sh/uv
COPY --from=ghcr.io/astral-sh/uv:0.11.7@sha256:240fb85ab0f263ef12f492d8476aa3a2e4e1e333f7d67fbdd923d00a506a516a /uv /usr/local/bin/uv
ENV UV_LINK_MODE=copy

USER node
