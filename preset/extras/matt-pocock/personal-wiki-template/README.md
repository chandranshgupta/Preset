# Personal / Audience LLM Wiki & Triage Workspace

Modeled on Matt Pocock's Karpathy-style LLM Wiki workflow (`[01:52:42]`–`[01:57:35]`):
- **Automated Ingestion (`scripts/ingest-wiki-cron.sh`):** Runs every 3 hours to pull external signals (social mentions, Discord/Slack threads, emails) into `inbox/` and synthesize structured Markdown pages in `wiki/`.
- **Voice-to-Triage (`todo-triage.md`):** Captures voice-dictated tasks (e.g., from smartwatch/phone dictation) into a triaged backlog for daily standups and time-blocked scheduling.
- **Human Offline Planning Rule:** Use the wiki to gather audience/user questions and learning goals, then step *away* from the screen with physical index cards or pen-and-paper to structure high-density courses/plans at human cognitive speed before dictating the final structure back into the repo.
