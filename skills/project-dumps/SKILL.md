---
name: project-dumps
description: Consult saved project findings, domain concepts, and verified CLI commands in ~/.config/opencode/dumps/<project>/. Use when the user references past dumps/notes, needs project CLI recipes, or works on a domain that may have prior session findings.
---

# Project Dumps Helper

Prior session findings, domain mental models, and verified CLI commands for each project live under `~/.config/opencode/dumps/<current-folder-name>/<domain>/<topic>.md`.

## Lookup Sequence

1. **Read the index first** rather than scanning full files:
   Run `sh "$HOME/.config/opencode/scripts/dumps-peek.sh" --index` to get the resolved `DUMP_ROOT`, available `<domain>` folders, and each note's one-line `summary`.
2. **Load selectively**:
   Read only the `<DUMP_ROOT>/<domain>/<topic>.md` file(s) whose domain or summary bears on the current task.
3. **Verify volatile details**:
   Treat conceptual mental models and architectural rationale as durable guidance, and verify specific line numbers or signatures against the live workspace if files have changed since `updated`.
