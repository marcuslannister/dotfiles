# Changelog

## Unreleased

- Add Bun's global bin directory to PATH so pinned global installs (e.g. ccstatusline) resolve.
- Add shortcuts for Claude Tap sessions with Claude and Codex clients.
- Preserve modifier chords in app-specific Karabiner swaps.
- Load FZF Zsh integration so Ctrl-R history search works on remote hosts.
- Remove program names from Smart Tabs labels.
- Pad Smart Tabs glyph boundary to prevent right-edge clipping.
- Load Smart Tabs from a Nix-managed local plugin file.
- Document repository issue tracking, triage labels, and domain context conventions for engineering agents.
- Keep ANSI black text visible in Kitty's light theme.
- Load zjstatus from its latest GitHub release instead of a local plugin copy.
- Stop starting Zellij sessions in locked mode.
- Add --impure to the drb/drs darwin-rebuild aliases so the nix-config flake's dynamic username resolves instead of evaluating to an empty string.
- Remap Vim's x/X, d, and U to match Hel's Kakoune-style line selection, no-yank delete, and redo bindings.
