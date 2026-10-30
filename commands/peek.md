---
description: Peek into saved project dumps under ~/.config/opencode/dumps/<project>/
---

Inspect or load saved session findings for the current project.

## Project Dump Index

!`sh "$HOME/.config/opencode/scripts/dumps-peek.sh" --index`

User query / filter: $ARGUMENTS

## Behavior

- **When `User query / filter` above is blank**:
  Present a clean, scannable overview of `EXISTING_NOTES` grouped by `<domain>` (showing `<domain>/<file>.md`, date, and `summary`). Do not read individual note bodies yet—just show what is available and note that `/peek <domain or topic>` loads specific notes into context. If `EXISTING_NOTES` has `(none yet)`, tell the user no dumps exist yet for `PROJECT` and they can run `/dump` to create the first one.

- **When `User query / filter` is provided**:
  1. Match the query against domain names, filenames, and summaries in `EXISTING_NOTES`. If nothing matches on metadata alone, search file contents inside `DUMP_ROOT` (using the exact resolved `DUMP_ROOT` path above).
  2. Read the matching `.md` note(s) from `DUMP_ROOT`.
  3. Present a concise synthesis answering or briefing the user on that topic—including any `Verified CLI Commands` verbatim in copy-pasteable `sh` blocks—and cite the loaded `<domain>/<file>.md` note(s) so those findings are active in this session's context.
