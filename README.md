# openclaw-image

Custom OpenClaw Docker image — thin layer on top of the official `ghcr.io/openclaw/openclaw:slim` with extra system tools.

## What's added

| Package           | Why                                         |
| ----------------- | ------------------------------------------- |
| `ffmpeg`          | Video frame extraction (video-frames skill) |
| `jq`              | JSON processing in scripts                  |
| `git`             | Lazy clone for project repos                |
| `curl`            | HTTP requests from scripts                  |
| `ca-certificates` | TLS for outbound connections                |
| `gh`              | GitHub CLI — PR-based workflow for agents   |
| `playwright`      | Browser automation (Chromium)               |
| `uv`              | Fast Python package/project manager         |

## Automation

- **Renovate** watches for new upstream `slim` tags, waits 2 days (so any same-day `-1`/`-2` hotfix lands first), then opens an auto-merging PR
- **GitHub Actions** builds multi-arch (`amd64` + `arm64`) and pushes to GHCR on merge to `main`

## Pulling the image

Each successful build on `main` publishes four tags:

| Tag                                           | Mutability    | When to use                                                         |
| --------------------------------------------- | ------------- | ------------------------------------------------------------------- |
| `latest`                                      | floating      | Local dev, throwaway scripts                                        |
| `<upstream>` (e.g. `2026.4.15-slim`)          | floating      | "Track upstream version, accept our patches" — staging environments |
| `<upstream>-<run>` (e.g. `2026.4.15-slim-42`) | **immutable** | **Production. Pin this.** Reproducible across rebuilds.             |
| `<short-sha>` (e.g. `a1b2c3d`)                | **immutable** | Pinned to a specific source commit                                  |

`<upstream>` mirrors the upstream OpenClaw tag we built on. `<run>` is `github.run_number`, our own monotonically-incrementing build counter — playing the same role as upstream's `-1`/`-2` postfix but for our wrapper layer.

```bash
# Production — immutable, reproducible
docker pull ghcr.io/openclaw/openclaw-image:2026.4.15-slim-42

# Staging — picks up our latest patches on this upstream
docker pull ghcr.io/openclaw/openclaw-image:2026.4.15-slim
```

## Adding tools

Edit the `Dockerfile`, open a PR. GitHub Actions rebuilds on merge to `main`.

## Local build

```bash
docker build -t openclaw-custom .
```
