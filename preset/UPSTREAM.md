# Upstream: mattpocock/skills

This repository is **his tree plus one new folder**. Everything outside `preset/` is
<https://github.com/mattpocock/skills> byte for byte at the pinned commit. Only `preset/` is new.

| | |
|---|---|
| Pinned commit | `abeeaf95660ba9e8b7c753eb38f441ca707a8823` |
| Licence of the upstream tree | MIT, Copyright (c) 2026 Matt Pocock (the `LICENSE` at the repo root) |
| Files changed outside `preset/` | None. Not `README.md`, `AGENTS.md`, `CHANGELOG.md`, the manifests or any skill |
| Why nothing clashes | `preset/` did not exist upstream, so merging his later commits never touches it |

## Updating from upstream

```sh
git remote add upstream https://github.com/mattpocock/skills   # once
git pull upstream main                                         # no conflicts: preset/ is new
sh preset/tools/sync-matt-skills.sh .                          # refresh the copies bundled for the installer
bash preset/tests/selftest.sh                                  # includes a byte-identity check against ../skills
```

## Why `preset/payload/.agents/skills/` also holds copies of his skills

So `preset/` stays installable on its own (copy the folder, run `install.sh`) without needing the rest of
the tree. The self-test fails if those copies ever differ from `../skills/`, and the sync script above
refreshes them, so they cannot silently drift.

## Please report problems in the skills upstream

Anything wrong inside a Matt Pocock skill belongs in an issue on his repository, not here.
