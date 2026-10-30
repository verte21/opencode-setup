# opencode-setup

Personal custom setup for **OpenCode 2** (`opencode2`): reusable slash commands, agent skills, helper scripts, and optional plugins symlinked cleanly into `~/.config/opencode/`.

## Structure

```text
.
├── commands/                 # Custom TUI slash commands (-> ~/.config/opencode/commands/)
│   ├── dump.md               # /dump — distill session findings & tested CLI commands
│   └── peek.md               # /peek — browse or load saved project dumps
├── skills/                   # Agent Skills (-> ~/.config/opencode/skills/)
│   └── project-dumps/
│       └── SKILL.md          # Autonomous lookup of prior project findings & CLI recipes
├── scripts/                  # Shared CLI helpers (-> ~/.config/opencode/scripts/)
│   └── dumps-peek.sh         # Fast indexer + terminal viewer for ~/.config/opencode/dumps/
└── install.sh                # Idempotent symlink & permission installer
```

*(Session dump notes themselves stay strictly local in `~/.config/opencode/dumps/<project>/<domain>/` and are never tracked in git.)*

## Installation

```sh
git clone https://github.com/verte21/opencode-setup.git
cd opencode-setup
./install.sh
```

`./install.sh`:
1. Symlinks every item under `commands/`, `skills/`, `scripts/` (and `plugins/` if added later) into `~/.config/opencode/` without disturbing runtime state or third-party integrations.
2. Idempotently adds `external_directory`, `read`, and `edit` allow-rules for `~/.config/opencode/dumps*` inside `~/.config/opencode/opencode.json`.

You can also install just the skills via the Agent Skills CLI:

```sh
npx skills add verte21/opencode-setup
```

## Included Workflows

### `/dump [optional focus or domain]`
Distills high-signal findings, mental models, architectural trade-offs, and **every verified CLI command** tested during the session into:

```text
~/.config/opencode/dumps/<current-folder-name>/<domain>/<topic>.md
```

- Reuses existing `<domain>` directories when appropriate and merges into existing topic notes rather than creating duplicates.
- Stamps YAML frontmatter (`title`, `domain`, `updated`, `summary`) so peeking stays fast and low-token.

### `/peek [optional domain or query]`
- `/peek` — lists all saved domains, notes, and one-line summaries for the current folder.
- `/peek <query>` — searches metadata/contents, reads matching notes, and loads findings + copy-pasteable CLI commands into the active session.

### Terminal Peeking (`dumps-peek.sh`)
Inspect project dumps directly from your shell outside `opencode2`:

```sh
~/.config/opencode/scripts/dumps-peek.sh          # Grouped summary for current folder ($PWD)
~/.config/opencode/scripts/dumps-peek.sh -f       # Interactive fzf browser with bat/cat preview
~/.config/opencode/scripts/dumps-peek.sh <query>  # Search filenames & contents for current folder
~/.config/opencode/scripts/dumps-peek.sh --all    # List all projects with saved dumps
```

Optional shell alias (`~/.zshrc`):

```sh
alias ocpeek="$HOME/.config/opencode/scripts/dumps-peek.sh"
```

## Extending

Add new files to `commands/`, `skills/<name>/SKILL.md`, `scripts/`, or `plugins/` and re-run `./install.sh` to symlink new entries into `~/.config/opencode/`. Edits to already-linked files are tracked immediately in git.
