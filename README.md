# openclaw-image

Custom OpenClaw Docker image — thin layer on top of the official `ghcr.io/openclaw/openclaw:slim` with extra system tools.

## What's added

| Package           | Why                                          |
| ----------------- | -------------------------------------------- |
| `ffmpeg`          | Video frame extraction (video-frames skill)  |
| `jq`              | JSON processing in scripts                   |
| `git`             | Lazy clone for project repos                 |
| `curl`            | HTTP requests from scripts                   |
| `ca-certificates` | TLS for outbound connections                 |
| `gh`              | GitHub CLI — PR-based workflow for agents     |
| `playwright`      | Browser automation (Chromium)                |
| `uv`              | Fast Python package/project manager          |

## Automation

- **Renovate** watches for new upstream `slim` tags and opens PRs
- **GitHub Actions** builds multi-arch (`amd64` + `arm64`) and pushes to GHCR
- **Tags:** `latest`, `YYYYMMDD`, short SHA

## Adding tools

Edit the `Dockerfile`, open a PR. GitHub Actions rebuilds on merge to `main`.

## Local build

```bash
docker build -t openclaw-custom .
```
