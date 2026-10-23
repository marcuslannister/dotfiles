# Herdr and Ctrl+V for text and image paste

Question: can Herdr use Ctrl+V directly for text and image paste, so that the Alt+V dispatcher is not necessary?

Short answer: no. Herdr has no text-paste action and no local image-paste action. Its only paste key, `keys.remote_image_paste`, operates only in `herdr --remote`, only for images, and when the clipboard has no image it sends the raw key to the pane. Thus text paste must always come from the outer terminal (Kitty or Ghostel). A clipboard-type dispatcher in the outer terminal is necessary. Keep the current Alt+V dispatcher.

Versions examined: Herdr 0.9.5 (`herdr --version`, Homebrew formula `herdr` 0.9.5), source tag `v0.9.5` (commit `2ecf19a92fc3a7fff75b6ce3655ef04f4625ec01`) of <https://github.com/herdrdev/herdr>; Kitty 0.49.2; Claude Code 2.1.308; Pi (`@earendil-works/pi-coding-agent`) 1.4.0; Ghostel `ghostel-20261012.1316`.

Abbreviation: `H` = `https://github.com/herdrdev/herdr/blob/v0.9.5`.

## 1. Herdr image-paste key

- The config key is `keys.remote_image_paste`. It is a string with one key combination. The default is `"ctrl+v"`. An empty string disables it. Sources: `H/src/config/model.rs#L1148`, `H/src/config.rs#L157-L165`, `herdr --default-config` line 99: `# remote_image_paste = "ctrl+v" # only active in herdr --remote; empty disables raw-key image paste`.
- Local value: `remote_image_paste = "alt+v"` in `~/Projects/dotfiles/.config/herdr/config.toml:4` (installed through Home Manager; `~/.config/herdr/config.toml` links into the Nix store). The reason is in `~/Projects/nix-config/CHANGELOG.md:62`.
- Syntax to use Ctrl+V: remove the line (default), or set `remote_image_paste = "ctrl+v"` in `[keys]`. Herdr accepts one combination, not a list (`H/src/config/model.rs#L389` declares `pub remote_image_paste: String`).
- Cmd+V: not examined. Herdr can only see Cmd+V if the outer terminal sends it as a key. Kitty and Ghostel use Cmd+V themselves. UNVERIFIED whether `parse_key_combo` accepts a `cmd`/`super` modifier.
- The key is remote-only. `should_bridge_clipboard_image_paste` returns `false` when the client is not remote (`H/src/client/clipboard_images.rs#L71-L73`). The 0.7.1 changelog removed the local Ctrl+V trigger so that Vim gets block-visual Ctrl+V (`H/CHANGELOG.md#L593`, section `## [0.7.1]` at line 577).
- Herdr's action is image-only. It does not paste text:
  - On a key match, Herdr reads the local clipboard as PNG with `osascript` (`«class PNGf»`) (`H/src/platform/macos.rs#L698-L716`).
  - If there is an image, Herdr sends it to the remote server and drops the key (`continue`) (`H/src/client/mod.rs#L976-L989`, shell-mode path `#L847-L861`).
  - If there is no image, Herdr logs `clipboard image paste trigger received, but local clipboard has no image` and sends the original key bytes to the pane (`H/src/client/mod.rs#L990-L1007`). It does not read or paste clipboard text.
- On the remote server, Herdr writes the image to a temporary file and pastes the file path into the pane as a paste event (`H/src/server/headless.rs#L1157-L1226`). Official docs say the same: "copying the image to a remote temp file and pasting that path" (`H/docs/next/website/src/content/docs/persistence-remote.mdx#L57`).
- Two other remote triggers exist: an empty bracketed paste `ESC[200~ESC[201~` (`H/src/client/clipboard_images.rs#L74-L76`), and a pasted absolute path to a `.png`/`.jpg`/`.gif`/`.webp` file (`#L171-L200`, `#L240-L248`).

## 2. What the inner application receives

- Local Herdr: Herdr does not act on Ctrl+V or Alt+V. It sends the key to the pane unchanged (`H/src/client/clipboard_images.rs#L71-L73`; then `ClientMessage::Input` at `H/src/client/mod.rs#L1004`). The pane application decides what the key does. The Herdr maintainer confirms: "local ctrl+v should pass through to the pane as ^v, and local agents should read the os clipboard themselves" (<https://github.com/herdrdev/herdr/issues/986>, maintainer comment). Issue #646 (<https://github.com/herdrdev/herdr/issues/646>, closed) is the Vim block-visual bug that caused the change.
- There is no local image-paste key. Feature requests for one: issue #986 (closed; the fix only removed the local empty-paste bridge) and discussion #1749 (<https://github.com/herdrdev/herdr/discussions/1749>, open request).
- Remote Herdr, image in clipboard: Herdr drops the key. The pane gets a pasted remote file path, not the key (section 1).
- Remote Herdr, no image in clipboard: the pane gets the raw key. In a shell or readline, Ctrl+V is literal-next (quoted-insert). In Vim it starts block-visual mode. UNVERIFIED for each application; this is standard shell/Vim behaviour and was not tested here.
- Remote mode and keybindings: the paste key comes from the local client config (`H/src/client/mod.rs#L208`). `--remote-keybindings` defaults to `local` (`herdr --help`). UNVERIFIED whether `--remote-keybindings server` changes the image-paste key.

## 3. Claude Code and Pi

- Claude Code: action `chat:imagePaste`, default `Ctrl+V` on macOS (`Alt+V` on Windows and WSL) (<https://code.claude.com/docs/en/keybindings.md>, table row `chat:imagePaste`). The interactive-mode page lists "`Ctrl+V` or `Cmd+V` (iTerm2) ... Paste image from clipboard" (<https://code.claude.com/docs/en/interactive-mode.md>, keyboard table line 28). Claude Code reads the clipboard of the host where it runs.
- Local value: `~/.claude/keybindings.json` sets `"ctrl+v": null` and `"alt+v": "chat:imagePaste"` in the `Chat` context.
- Claude Code with `chat:imagePaste` and a text-only clipboard: the docs do not say that it pastes text. UNVERIFIED. Assume that it does not paste text.
- Pi: action `app.clipboard.pasteImage`, default `ctrl+v` (`alt+v` on Windows and WSL) (Pi package `docs/keybindings.md:129`; `dist/core/keybindings.js:62-65`). Pi's handler tries clipboard file paths, then an image, then text as "the final fallback" (`dist/modes/interactive/interactive-mode.js:2436-2491`). Pi reads the clipboard of the host where it runs, so on a remote host it cannot see the local clipboard.
- Local value: `~/.pi/agent/keybindings.json` sets `"app.clipboard.pasteImage": ["ctrl+shift+v", "alt+v"]`.

## 4. Kitty and Ghostel

- Kitty: `paste_from_clipboard` sends only text. If the clipboard has no text, Kitty sends nothing (no empty bracketed paste), unless the application enabled Kitty paste events (<https://github.com/kovidgoyal/kitty/blob/v0.49.2/kitty/boss.py#L3001-L3008>, `window.py#L2197-L2205`). Herdr does not enable Kitty paste events (no `5522` in Herdr source; `rg 5522 src` gave no result). Thus Herdr's empty-paste trigger cannot fire from Kitty.
- Current Kitty files: `~/Projects/dotfiles/.config/kitty/kitty.conf:830` and `:832` map `ctrl+v` and `cmd+v` to `kitten smart_paste.py`. `~/Projects/dotfiles/.config/kitty/smart_paste.py:14-17` sends `alt+v` for any `image/*` MIME type, else calls `boss.paste_from_clipboard()`.
- Current Emacs files: `~/Projects/emacs.d/lisp/init-local-shell.el:152-168` (`ml/ghostel-smart-paste`, `ml/ghostel-bind-smart-paste`). Same logic: `image/*` target sends `M-v`, else `ghostel-yank`.
- Can these files be deleted? No. Without them, Ctrl+V (Cmd+V after Karabiner) gives text paste only, and an image-only clipboard gives nothing. Herdr cannot add the text fallback (section 1). The only change possible is the key that the dispatcher sends for an image (Alt+V or Ctrl+V). This does not make the code smaller.
- Ghostel `yank-media`: Ghostel writes a clipboard image to a local temp file and pastes the shell-quoted path "followed by a space" (`ghostel.el:2025-2040`, `:5254-5271`). In remote Herdr, the path trigger accepts a path only after it removes trailing `\r`/`\n` (`H/src/client/clipboard_images.rs#L183-L186`), so the trailing space probably blocks the extension match. UNVERIFIED (source reading only, not tested). TIFF clipboards are also not in Herdr's extension list.

## 5. Karabiner

- Live file: `~/.config/karabiner` links into the Nix store; `cmp` shows that `~/.config/karabiner/karabiner.json` is identical to `~/Projects/dotfiles/.config/karabiner/karabiner.json`. Line numbers below refer to the dotfiles copy.
- Profile `simple_modifications` swap `left_command` and `left_control` (`karabiner.json:651-659`). An external keyboard (vendor 20037, product 17746) also swaps `left_command` and `left_option` (`karabiner.json:604-628`).
- Rule "Control+v to Super+v: paste" (`karabiner.json:202-231`): `from` `v` with mandatory `left_control`, `to` `v` with `command`, condition `frontmost_application_if` with these bundle IDs (`karabiner.json:208-214`):
  - `^net\.kovidgoyal\.kitty$` (Kitty; confirmed with `osascript -e 'id of app "kitty"'`)
  - `^com\.stablyai\.orca$`
  - `^com\.muxy\.app$`
  - `^sh\.paseo\.desktop$`
  - `^org\.gnu\.Emacs$` (Emacs; confirmed with `osascript -e 'id of app "Emacs"'`)
- Order: "Karabiner-Elements changes keys by Simple Modifications, and then changes them by Complex Modifications" (<https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-evaluation-priority/>). Thus the key that macOS reports as `left_control` after the swap is the physical left Command-position key. In Kitty and Emacs, both the "Ctrl" key the user presses and the physical Ctrl key give Cmd+V. Derived from the config and the doc; not tested with Karabiner-EventViewer.
- Right Control is not swapped and is not in the rule (`mandatory: ["left_control"]`), so right Ctrl+V reaches Kitty as Ctrl+V. Derived; not tested.
- Change option: remove the Kitty and Emacs IDs from `bundle_identifiers`, or use `frontmost_application_unless` (<https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/conditions/frontmost-application/>: "Change an event if/unless the frontmost application is the specified application"). Then Kitty and Emacs get Ctrl+V.
- What the change does not fix: Ctrl+V reaches the terminal, but the terminal must still choose text paste or image key. If Kitty does not map `ctrl+v`, Herdr and the pane get raw Ctrl+V, and there is no text paste (sections 1 to 3). Thus the dispatcher is still necessary.
- What the change breaks or changes:
  - The physical Ctrl+V key (which is `left_command` after the swap) still gives Cmd+V. The two physical keys then do different things in Kitty and Emacs.
  - In Emacs outside Ghostel, the user's Ctrl+V becomes `C-v` (`scroll-up-command`) instead of Cmd+V paste (`yank`). This changes normal Emacs paste.
  - The Kitty and Emacs maps for `cmd+v`/`s-v` can then go, but the `ctrl+v`/`C-v` maps stay. No net code saving.
- Recommendation for Karabiner: do not change it. The rule makes Ctrl+V paste in the same way in all five apps. The dispatchers already handle both Ctrl+V and Cmd+V.

## 6. Options

| Option | Text local | Image local | Text remote | Image remote | Changes | Problems |
|---|---|---|---|---|---|---|
| A. Current: dispatcher sends Alt+V; Claude Code, Pi, Herdr bound to Alt+V | yes | yes | yes | yes | none | Three custom Alt+V bindings to keep in sync. Kitty test confirmed (handoff note); Emacs not yet confirmed by user. |
| B. Dispatcher sends Ctrl+V for an image; return Claude Code, Pi, Herdr to their default Ctrl+V | yes | yes (UNVERIFIED) | yes | yes (UNVERIFIED) | edit 2 dispatchers, delete 3 custom bindings | Same code size. Raw Ctrl+V in a shell pane when the clipboard has an image starts quoted-insert. Not tested. |
| C. Only change Herdr to Ctrl+V; no dispatcher | Cmd+V only | Claude Code/Pi only if they see raw Ctrl+V; Kitty and Emacs send Cmd+V | Cmd+V only | only if the raw key reaches Herdr | delete dispatchers, edit Herdr config | Ctrl+V does not paste text. Fails the goal. |
| D. Karabiner exclusion plus raw Ctrl+V to Herdr | no | yes (local apps read clipboard) | no | yes | edit Karabiner, delete dispatchers | No text paste on Ctrl+V; Emacs `C-v` scroll conflicts. Fails the goal. |
| F. Run local sessions as `herdr --remote localhost` to get the bridge locally | same as remote | yes (third-party report in issue #986, UNVERIFIED here) | yes | yes | change how Herdr starts | Not a supported local mode; adds SSH to every local session; still needs the dispatcher for text. |
| E. Herdr empty-paste or file-path trigger | yes | no | yes | Kitty: no (sends nothing); Ghostel `yank-media`: probably no (trailing space) | new Ghostel binding | Remote only; mixed text+image clipboard pastes text. Fails the goal. |

Recommendation: keep option A. It is the only option that is confirmed to work for local and remote, text and image, and it needs no new change. Herdr cannot replace the dispatcher, because Herdr's paste key is remote-only and image-only. Option B is possible, but it only changes the key name, it saves no code, and it is not tested.

## Unverified claims

- Herdr `parse_key_combo` support for `cmd`/`super`.
- Effect of `--remote-keybindings server` on `keys.remote_image_paste`.
- Claude Code `chat:imagePaste` behaviour with a text-only clipboard.
- Shell and Vim behaviour of raw Ctrl+V in panes (standard behaviour, not tested).
- Option B in practice.
- Ghostel `yank-media` path with Herdr's remote file-path trigger.
- Option F (`herdr --remote localhost`), based only on a user comment in issue #986.
- Karabiner physical-key results (derived from config and docs, not observed in EventViewer).
