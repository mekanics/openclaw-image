# Thin layer on top of official OpenClaw image.
# Adds system tools needed by skills and agents.
#
# renovate datasource=docker depName=ghcr.io/openclaw/openclaw
FROM ghcr.io/openclaw/openclaw:2026.11.5-slim@sha256:9c74476e3e79b5a1595fd5cf904286eaba3471c10c640aaa9a361a89b41d0882

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
    # The base image ships /home/node as 0700 (owner node, uid 1000). The
    # homelab chart runs the pod as uid 1024 to match the all-squash NFS
    # export, so that uid must be able to traverse /home/node to reach the
    # volumes mounted at /home/node/.openclaw and /home/node/.openclaw-state.
    # Execute alone is not enough: doctor opens /home/node itself for read
    # (open() gives EACCES at 0711), so use 0755 like the pre-2026.11.5
    # images. Contents keep their own modes.
    chmod 755 /home/node; \
    test "$(stat -c %a /home/node)" = 755; \
    \
    rm -rf /var/lib/apt/lists/*

# Install uv — fast Python package/project manager
# https://docs.astral.sh/uv/
# renovate datasource=docker depName=ghcr.io/astral-sh/uv
COPY --from=ghcr.io/astral-sh/uv:0.13.9@sha256:d3b601f0c7b118bc1753febf7c41cc80981df678445e0254284eecf84db79a7d /uv /usr/local/bin/uv
ENV UV_LINK_MODE=copy

USER node
