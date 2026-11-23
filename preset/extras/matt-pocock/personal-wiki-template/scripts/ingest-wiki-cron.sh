#!/usr/bin/env bash
set -euo pipefail

# Scheduled via crontab every 3 hours:
# 0 */3 * * * /path/to/personal-wiki/scripts/ingest-wiki-cron.sh

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Running 3-hour wiki ingestion..."
claude -p "Read new items in inbox/, deduplicate against wiki/index.md, update relevant topic pages in wiki/, and summarize emerging user questions." --allowedTools "Read,Write,Edit,Glob,Grep"
