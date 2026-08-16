# Changelog

## Unreleased

- Share Homebrew trust between activation and interactive commands by adding `muxy-app/tap` and preserving the existing trusted casks in `.homebrew/trust.json`; nix-config deploys both Homebrew trust paths from this file.
- Give scmpuff's `git` wrapper a fallback command word, `${SCMPUFF_GIT_CMD:-${commands[git]}}`, at each of its four call sites. scmpuff exports the variable and defines the function in one `eval`, but the two travel apart: Claude Code's shell snapshot replays the function into a non-interactive shell without the environment, leaving an empty command word, so every `git` call there failed with "permission denied". The `:-` arm never runs in a shell that sourced this file, so nothing changes for an interactive one.
- Add the Emacs configuration directory to `PATH` so MCP clients can resolve the Anvil launcher.
- Add `gu`/`gf`/`gl` git aliases for push, pull, and a graph log.
- Move the npm global bin directory from `.zshrc` to `.zshenv` so non-interactive Zsh sessions, such as Claude Code hooks, also resolve globally installed tools like `codegraph`.
- Make the Go toolchain path and `IC_BOX` available to all Zsh invocations.
- Add Claude command shortcuts, translate `--fs` to `--fork-session`, and make the Nix system profile and UTF-8 locale available to Zsh.
- Give `ls` back the numeric shortcuts SCM Breeze used to wrap it with, through `scmpuff exec --relative`, and guard the whole scmpuff block on the binary being present. nix-config Declares scmpuff on every host now, but one that has not switched yet would otherwise print "command not found" at each shell and be left with no `ls` at all. The eza alias test forks the same way.
- Add explicit Vim `dp` and `dg` mappings for diff put and diff get after remapping `d` to a no-yank character delete.
- Remove obsolete SCM Breeze loading, keep the eza alias test independent of optional tools, and keep the OTTY integration test from writing generated Zim state into the repository.
- Set the OTTY sidebar width to 159 pixels and remove stale comments for settings that use their defaults.
- Authenticate git over HTTPS through `gh` rather than git-credential-manager, with `helper = !gh auth git-credential` for github.com and gist.github.com. The helper is written without an absolute path so it resolves on the Debian hosts too, where the Nix path `gh auth setup-git` emits does not exist. This also drops the GCM helper and the Azure DevOps entry that the cask's installer had appended.
- Bind alt-1 through alt-6 to TTY7 tabs and ctrl-v to paste, and add the comma the keybindings block was missing, which had left the file invalid JSON and unparseable by TTY7.
- Trust the ten third-party Homebrew taps whose formulae and casks nix-config now Declares. `brew bundle` refuses to load a formula from an untrusted tap and takes `darwin-rebuild switch` down with it. Activation reads this file rather than `~/.config/homebrew/trust.json` because it runs without `XDG_CONFIG_HOME`, so entries have to be written with `env -u XDG_CONFIG_HOME brew trust --taps`.
- Drop the Homebrew coreutils gnubin directory from `PATH`: nix-config installs plain `coreutils` system-wide, so GNU `ls`/`cp`/`rm`/`date` still win without Homebrew, and the directory no longer exists.
- Track the TTY7 configuration for deployment through nix-config.
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
- Load scmpuff shell integration, extending its git wrapper so numeric file shortcuts also expand for difftool and mergetool.
- Track Homebrew's trusted-taps file so emacs-plus installs without a trust prompt.
