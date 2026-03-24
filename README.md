# openclaw-image

Custom OpenClaw Docker image — thin layer on top of the official `ghcr.io/openclaw/openclaw:slim` with extra system tools.

## What's added

| Package | Why |
|---|---|
| `ffmpeg` | Video frame extraction (video-frames skill) |
| `jq` | JSON processing in scripts |
| `git` | Lazy clone for project repos |
| `curl` | HTTP requests from scripts |
| `ca-certificates` | TLS for outbound connections |

## How it works

```
ghcr.io/openclaw/openclaw:slim     ← official upstream
        ↓
ghcr.io/mekanics/openclaw-image    ← this image (+ffmpeg +jq +git +curl)
        ↓
homelab k3s deployment             ← consumed via Helm chart
```

## Automation

- **Renovate** watches for new upstream `slim` tags and opens PRs
- **GitHub Actions** builds multi-arch (`amd64` + `arm64`) and pushes to GHCR
- **Tags:** `latest`, `YYYYMMDD`, short SHA

## Adding tools

Edit the `Dockerfile`, push to `main`. GitHub Actions rebuilds automatically.

## Local build

```bash
docker build -t openclaw-custom .
```
