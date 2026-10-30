#!/usr/bin/env sh
# Symlink custom OpenCode commands, skills, scripts, and plugins into ~/.config/opencode/
# and ensure external_directory permissions are configured for local project dumps.

set -eu

REPO_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
OPENCODE_CONFIG_DIR="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"

mkdir -p "$OPENCODE_CONFIG_DIR/dumps"

if [ -d "$REPO_DIR/scripts" ]; then
  chmod +x "$REPO_DIR/scripts/"* 2>/dev/null || true
fi

link_children() {
  src_dir="$1"
  dest_dir="$2"
  [ -d "$src_dir" ] || return 0
  mkdir -p "$dest_dir"

  for item in "$src_dir"/*; do
    [ -e "$item" ] || continue
    name="$(basename "$item")"
    target="$dest_dir/$name"

    if [ -L "$target" ]; then
      rm -f "$target"
    elif [ -f "$item" ] && [ -f "$target" ] && cmp -s "$item" "$target" 2>/dev/null; then
      rm -f "$target"
    elif [ -d "$item" ] && [ -d "$target" ] && diff -rq "$item" "$target" >/dev/null 2>&1; then
      rm -rf "$target"
    elif [ -e "$target" ]; then
      backup="${target}.bak.$(date +%Y%m%d%H%M%S)"
      echo "Backing up existing $target -> $backup"
      mv "$target" "$backup"
    fi

    ln -s "$item" "$target"
    echo "Linked $target -> $item"
  done
}

link_children "$REPO_DIR/commands" "$OPENCODE_CONFIG_DIR/commands"
link_children "$REPO_DIR/skills"   "$OPENCODE_CONFIG_DIR/skills"
link_children "$REPO_DIR/scripts"  "$OPENCODE_CONFIG_DIR/scripts"
link_children "$REPO_DIR/plugins"  "$OPENCODE_CONFIG_DIR/plugins"

# Idempotently configure ~/.config/opencode/dumps permissions in opencode.json
JS_RUNNER=""
if command -v node >/dev/null 2>&1; then
  JS_RUNNER="node"
elif command -v bun >/dev/null 2>&1; then
  JS_RUNNER="bun"
fi

if [ -n "$JS_RUNNER" ]; then
  "$JS_RUNNER" -e '
    const fs = require("node:fs");
    const configPath = process.argv[1];
    const homeDumps = process.argv[2];

    let cfg = { "$schema": "https://opencode.ai/config.json" };
    if (fs.existsSync(configPath)) {
      cfg = JSON.parse(fs.readFileSync(configPath, "utf8"));
    }
    if (!Array.isArray(cfg.permissions)) {
      cfg.permissions = [];
    }

    const required = [
      { action: "external_directory", resource: "~/.config/opencode/dumps*", effect: "allow" },
      { action: "external_directory", resource: `${homeDumps}*`, effect: "allow" },
      { action: "read", resource: "~/.config/opencode/dumps/*", effect: "allow" },
      { action: "read", resource: `${homeDumps}/*`, effect: "allow" },
      { action: "edit", resource: "~/.config/opencode/dumps/*", effect: "allow" },
      { action: "edit", resource: `${homeDumps}/*`, effect: "allow" },
    ];

    let added = 0;
    for (const rule of required) {
      const exists = cfg.permissions.some(
        (r) => r && r.action === rule.action && r.resource === rule.resource && r.effect === rule.effect
      );
      if (!exists) {
        cfg.permissions.push(rule);
        added++;
      }
    }

    if (!fs.existsSync(configPath) || added > 0) {
      fs.writeFileSync(configPath, JSON.stringify(cfg, null, 2) + "\n", "utf8");
      console.log(`Updated ${configPath} (${added} permission rule(s) added)`);
    } else {
      console.log(`Permissions already up to date in ${configPath}`);
    }
  ' "$OPENCODE_CONFIG_DIR/opencode.json" "$OPENCODE_CONFIG_DIR/dumps"
else
  echo "Warning: neither node nor bun found; skipped opencode.json permission merge." >&2
fi

echo "Done! OpenCode custom setup linked into $OPENCODE_CONFIG_DIR"
