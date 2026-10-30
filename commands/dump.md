---
description: Distill key findings and concepts from this session into ~/.config/opencode/dumps/<project>/<domain>/
---

Distill the reusable findings, concepts, and project mechanics from this session into a structured reference note saved under this project's dump folder.

## Environment Snapshot

!`sh "$HOME/.config/opencode/scripts/dumps-peek.sh" --index`

Optional user focus / domain hint: $ARGUMENTS

## Steps

1. **Extract high-signal knowledge and every useful CLI command from the session**
   Capture what helps a future session or developer working in this project without re-exploring from scratch:
   - **Core concepts & mental models**: how the subsystem, library, or domain actually works.
   - **Key findings & root causes**: non-obvious invariants, edge cases, constraints, or debugging discoveries.
   - **Verified CLI commands (mandatory audit)**: scan the entire session—user `!` shell turns, commands pasted or mentioned by the user, and agent shell executions—and collect **every useful CLI command that worked** (tests, builds, debug/inspection one-liners, `curl`/API calls, DB/migration runs, flags that mattered). Record the final working invocation verbatim with exact flags/pipes, note any required working directory or env vars (replacing secret values with `$ENV_VAR` or `<REDACTED>`), and drop failed trial-and-error typos.
   - **Decisions & trade-offs**: why the chosen approach won and what traps to avoid.
   - **Project pointers**: relative workspace paths and key symbols (reference files by path rather than duplicating large code blocks that go stale).

   If `$ARGUMENTS` is provided, scope the summary and domain selection to match it. If `$ARGUMENTS` is empty and the session covered genuinely separate domains, split them into separate domain notes rather than mixing unrelated topics in one file (use a `cli` or `tooling` domain if commands are project-wide rather than tied to one feature domain).

2. **Resolve the target `<domain>` folder and note path**
   - Base path: use the exact absolute `DUMP_ROOT` path printed above (never pass a literal `~` to file tools).
   - Inspect `EXISTING_DOMAINS` and `EXISTING_NOTES` first:
     - **Reuse** an existing `<domain>` directory whenever the topic fits it; otherwise create a concise `kebab-case` `<domain>` folder (e.g. `auth`, `effect-ts`, `cli`, `db-migrations`).
     - **Merge over duplicate**: if an existing note in `EXISTING_NOTES` already covers the same concept or subsystem, read that file first and integrate the new findings and newly tested CLI commands—preserving still-valid commands from the existing file, updating `updated`, and replacing superseded claims—instead of creating a duplicate sibling file.
     - Otherwise, create `<DUMP_ROOT>/<domain>/<topic-slug>.md` with a descriptive `kebab-case` filename.

3. **Write the note**
   Format every dump file with YAML frontmatter so `/peek` can index it without reading full files:

   ````markdown
   ---
   title: "<Concise concept or finding title>"
   domain: <domain-folder>
   updated: <TODAY from snapshot>
   summary: "<Single-line summary of what this note explains, solves, or runs>"
   ---

   # <Title>

   ## Findings & Concepts
   ...

   ## Verified CLI Commands
   ```sh
   # <What it does / when to run it (note CWD or env vars if non-obvious)>
   <exact working command>
   ```

   ## Gotchas & Decisions
   ...

   ## Pointers
   ...
   ````

   **Completion check**: every useful CLI command tested or verified in the session is accounted for in `## Verified CLI Commands` (omit that section only when zero CLI commands occurred in the session). Keep prose concise for fast scanning, and redact any secrets, tokens, or credentials.

4. **Confirm**
   Report each written/updated file path (`<domain>/<topic-slug>.md`) and a 2–4 bullet recap of captured findings and saved CLI commands.
