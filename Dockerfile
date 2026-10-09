# Thin layer on top of official OpenClaw image.
# Adds system tools needed by skills and agents.
#
# renovate datasource=docker depName=ghcr.io/openclaw/openclaw
FROM ghcr.io/openclaw/openclaw:2026.9.9-slim@sha256:7f10d5cc975a90b65192eaa099454fe33ce8ce2390806c61c65cd868e9ef730d

USER root

ENV PLAYWRIGHT_BROWSERS_PATH=/home/node/.cache/ms-playwright

# All system tooling in a single layer:
#   - ffmpeg, jq, git: required by skills/agents
#   - vim: provides the vi editor for interactive edits
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
        vim \
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
COPY --from=ghcr.io/astral-sh/uv:0.13.0@sha256:cdc6093146eb3ff6a40107b38f008b789e050e77ad87865e381d9917da55a168 /uv /usr/local/bin/uv
ENV UV_LINK_MODE=copy

USER node
