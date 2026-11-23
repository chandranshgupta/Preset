---
description: FINAL_CHECK before calling a task done (alias of .agents/workflows/finalize-task.md)
---

# Finalize task

Follow `.agents/workflows/finalize-task.md` exactly: `sh .agents/bin/precheck.sh --final`, scan new
dependencies (scan → fix → rescan; no scanner → mark UNSCANNED), self-review, sync docs and memory,
then hand off with evidence.
