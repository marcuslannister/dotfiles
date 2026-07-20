# AGENTS.md — dotfiles

## Apply changes (nix-darwin)

- After committing changes here: `cd ~/Projects/nix-config`; `nix flake update dotfiles`; `sudo -E darwin-rebuild switch --flake .`. This repo is a flake input; edits don't take effect until rebuilt.
- `sudo` prompts for password — surface the result; don't assume success.

## Scripts

- `local/bin/` holds personal scripts (synced to `~/.local/bin` on rebuild).
- `repo-check` — sweep repos for uncommitted + unpushed changes (default list at top of script; override via args). Aliased as `repo-check` in `.zshrc`.

## Agent skills

### Issue tracker

Issues live in this repo's GitHub Issues. See `docs/agents/issue-tracker.md`.

### Triage labels

Default triage label vocabulary. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context layout. See `docs/agents/domain.md`.
