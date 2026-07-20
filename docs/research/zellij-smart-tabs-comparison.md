# zjstatus versus zellij-smart-tabs

Research date: 2026-07-19 PDT. Scope: planning only; no migration was applied.

## Bottom line

`zellij-smart-tabs` cannot directly replace `zjstatus` as the persistent one-row bar. It is a background tab-name manager. Its visible UI is an optional dashboard, and the dashboard intentionally renders nothing below three rows. The current layout gives `zjstatus` one row, so substituting the smart-tabs WASM at that location would produce a blank row, not a smart tab bar ([dashboard guard](https://github.com/YesYouKenSpace/zellij-smart-tabs/blob/v0.2.4/src/ui.rs#L29-L51), [upstream demo using Zellij's separate built-in tab bar](https://github.com/YesYouKenSpace/zellij-smart-tabs/blob/v0.2.4/demo/demo-layout.kdl#L1-L24)).

There is also no smart-tabs theme setting. Its configuration covers naming format, polling, debounce, debug, substitutions, and skipped programs; its dashboard uses Zellij UI palette slots rather than defining a palette ([configuration parser](https://github.com/YesYouKenSpace/zellij-smart-tabs/blob/v0.2.4/src/config.rs#L41-L100), [dashboard styling](https://github.com/YesYouKenSpace/zellij-smart-tabs/blob/v0.2.4/src/ui.rs#L53-L87)). The initial migration therefore needs one more product decision:

1. Load smart-tabs in the background and use Zellij's built-in `tab-bar` or `compact-bar` as the persistent themed bar; or
2. Load smart-tabs in the background and intentionally have no persistent bar.

The first option is the closest semantic replacement. Zellij's built-in tab bar displays the names smart-tabs writes, uses the active Zellij theme, retains the session name, and marks fullscreen, synchronized panes, and bell state ([tab-bar theme/session integration](https://github.com/zellij-org/zellij/blob/v0.44.3/default-plugins/tab-bar/src/main.rs#L125-L159), [tab state rendering](https://github.com/zellij-org/zellij/blob/v0.44.3/default-plugins/tab-bar/src/tab.rs#L98-L119)). Zellij's separate built-in `status-bar` supplies mode and keybinding information; `tab-bar` alone does not replace that part of the current zjstatus row ([official default layout](https://github.com/zellij-org/zellij/blob/v0.44.3/zellij-utils/assets/layouts/default.kdl)).

## Current local integration

The tracked dotfiles layout installs one borderless row per tab and runs `zjstatus` from its floating `releases/latest` URL. It hard-codes the Modus Operandi Tinted palette, renders the mode and tabs on the left and session name on the right, limits display to eight tabs, and defines fullscreen, sync, and floating indicators ([current tracked layout](https://github.com/marcuslannister/dotfiles/blob/a7ab438bc21cde3175b5dc23fdb121c429bdeb6d/.config/zellij/layouts/default.kdl#L1-L79)). A configured git-branch command is not referenced by any of the three output formats, so it currently contributes no visible text.

The dirty shared checkout contains an uncommitted tab-label experiment in that layout: inactive labels change from `{index} {name}` to `#{index}`, while active labels change to `#{index} · {focused_pane_title}`. The user has explicitly allowed a later migration to supersede this experiment. This observation came from `git diff -- .config/zellij/layouts/default.kdl`; the research branch does not contain or alter the dirty file.

The Nix integration is important. `home/home.nix` asserts that the tracked remote zjstatus URL is present, then rewrites it to the packaged `${pkgs.zjstatus}/bin/zjstatus.wasm` before installing the generated layout ([Nix rewrite](https://github.com/marcuslannister/nix-config/blob/3dd8ca0f34b6f7b329940a614b4a6c0030ef3451/home/home.nix#L16-L23), [generated layout target](https://github.com/marcuslannister/nix-config/blob/3dd8ca0f34b6f7b329940a614b4a6c0030ef3451/home/home.nix#L109-L112)). A future implementation must remove or replace that zjstatus-specific assertion and rewrite; changing only the dotfiles layout would make nix-darwin evaluation fail.

The running binary reports `zellij 0.44.3` and comes from the active Nix store derivation `zellij-0.44.3`. The nix-darwin package list selects `unstable.zellij`. This satisfies smart-tabs' documented Zellij 0.44.2 minimum ([prerequisites](https://github.com/YesYouKenSpace/zellij-smart-tabs/blob/69776ecf6016a756b4fa7a4c72df22281ea2817e/README.md#L19-L25)). The current config already selects `theme "modus_operandi_Tinted"` and retains aliases for Zellij's built-in `tab-bar`, `status-bar`, and `compact-bar` ([current Zellij config](https://github.com/marcuslannister/dotfiles/blob/a7ab438bc21cde3175b5dc23fdb121c429bdeb6d/.config/zellij/config.kdl#L264-L299)).

## Latest release and minimal smart-tabs configuration

GitHub's latest release is [v0.2.4](https://github.com/YesYouKenSpace/zellij-smart-tabs/releases/tag/v0.2.4), published 2026-07-17. It contains one 3,778,473-byte WASM asset. GitHub reports SHA-256 `094492c4958064b7a35b8b86c28569b9d1c2443d60a872da9f26a61e68c5df2d`; a fresh local download matched that digest. The user-selected floating URL currently resolves to that asset:

```text
https://github.com/YesYouKenSpace/zellij-smart-tabs/releases/latest/download/zellij-smart-tabs.wasm
```

Upstream documentation uses an explicit version URL and says to update the version to the latest. It registers one alias and loads one background instance ([current upstream installation and quickstart](https://github.com/YesYouKenSpace/zellij-smart-tabs/blob/69776ecf6016a756b4fa7a4c72df22281ea2817e/README.md#L27-L67)). Adapting only the URL to the user's floating-latest decision, the minimal smart-tabs portion is:

```kdl
plugins {
    smart-tabs location="https://github.com/YesYouKenSpace/zellij-smart-tabs/releases/latest/download/zellij-smart-tabs.wasm"
}

load_plugins {
    smart-tabs
}
```

No child configuration block is needed for default behavior. On first load the plugin requests `ReadApplicationState`, `ChangeApplicationState`, and `RunCommands`, then subscribes to tab, pane, working-directory, command, timer, configuration, key, and mouse events ([load implementation](https://github.com/YesYouKenSpace/zellij-smart-tabs/blob/v0.2.4/src/main.rs#L809-L838)). A Nerd Font is required for its default program and status icons ([prerequisites](https://github.com/YesYouKenSpace/zellij-smart-tabs/blob/69776ecf6016a756b4fa7a4c72df22281ea2817e/README.md#L19-L25)).

That KDL only starts the renamer. A separate layout choice remains mandatory if a persistent bar is desired. The minimum native companion would be a one-row `tab-bar`; using smart-tabs itself inside that row is invalid.

## Default naming and theme behavior

All tabs begin managed. The default name is:

- the first tiled pane's Git repository basename, or its current directory basename when it is not in a repository;
- followed by a Nerd Font separator and detected program when present; and
- followed by a piped application status when non-empty.

The exact default template and substitutions are defined in source ([default format and substitutions](https://github.com/YesYouKenSpace/zellij-smart-tabs/blob/v0.2.4/src/config.rs#L1-L39)). Top-level variables alias the first tiled pane; pane-indexed variables are also available ([template variables and examples](https://github.com/YesYouKenSpace/zellij-smart-tabs/blob/v0.2.4/README.md#L123-L173)). Floating panes are excluded from the naming data ([event/data design](https://github.com/YesYouKenSpace/zellij-smart-tabs/blob/v0.2.4/DESIGN.md#L100-L111)). Manual renames require switching the tab to manual mode through a plugin message; the upstream-recommended keybinding is not part of the minimal defaults ([manual-control instructions](https://github.com/YesYouKenSpace/zellij-smart-tabs/blob/v0.2.4/README.md#L179-L226)).

The plugin has no built-in bar theme. With a native bar, the existing `modus_operandi_Tinted` Zellij theme remains the initial theme and the bar consumes it automatically. The smart-tabs dashboard likewise uses Zellij's UI component colors. Theme tuning can remain out of scope, but the migration contract must stop describing smart-tabs as owning the bar or theme.

## Information retained and lost

| Information or behavior | Current zjstatus row | Smart-tabs alone | Smart-tabs plus native `tab-bar` |
|---|---|---|---|
| Persistent one-row renderer | Yes | No | Yes |
| Automatic repo/directory/program naming | No | Yes | Yes; native bar displays the renamed tab |
| Mode badge | Yes, custom | No | No; native `status-bar` is required |
| Session name | Yes | No | Yes |
| Fullscreen and synchronized-pane state | Yes | No | Yes |
| Floating-pane state | Yes | No; floating panes excluded | No explicit native tab-bar marker |
| Tab overflow | Fixed eight-tab cap and count markers | Not applicable | Width-based collapsing around active tab |
| Palette | Hard-coded Modus colors | No theme setting | Active Zellij theme |
| Pane application status | No visible app-status protocol | Optional, program-fed pipe status in tab name | Same renamed tab text |

Smart-tabs `status` does not mean Zellij's input mode or session status. Programs must send it with `zellij pipe --name pane_status`; defaults map `idle`, `running`, `pending`, `done`, and `error` to icons or empty text ([pane-status protocol](https://github.com/YesYouKenSpace/zellij-smart-tabs/blob/v0.2.4/README.md#L228-L242)). Its documented template variables are limited to directory, Git root, program, application status, and pane-indexed forms. It has no variables for Zellij mode, session, fullscreen, floating, or synchronized-pane state.

## Project and release health

The project is young but active: created 2026-04-07, pushed 2026-07-17, MIT-licensed, not archived, and at research time had 26 stars and 5 forks ([repository](https://github.com/YesYouKenSpace/zellij-smart-tabs)). Recent main [CI](https://github.com/YesYouKenSpace/zellij-smart-tabs/actions/runs/29554103108), scheduled [CodeQL](https://github.com/YesYouKenSpace/zellij-smart-tabs/actions/runs/29584945913), and the v0.2.4 [release workflow](https://github.com/YesYouKenSpace/zellij-smart-tabs/actions/runs/29551959812) were green.

Two cautions matter for the prototype and migration plan:

- The open [PaneCmd timeout bug](https://github.com/YesYouKenSpace/zellij-smart-tabs/issues/18) affects command/CWD discovery with more panes; the owner reproduced it, and it remains unresolved. A prototype should include several panes and verify naming updates, not only a one-pane happy path.
- Release discipline is rough. v0.2.4 is the same source commit as v0.2.3; its `Cargo.toml` still says `0.2.3`, so the dashboard reports v0.2.3, and the release body says v0.2.4 was another misclick ([package version](https://github.com/YesYouKenSpace/zellij-smart-tabs/blob/v0.2.4/Cargo.toml#L1-L6), [release](https://github.com/YesYouKenSpace/zellij-smart-tabs/releases/tag/v0.2.4)). The changelog also records that v0.2.2 was tagged without the intended package-version and changelog updates before being re-released as v0.2.3 ([changelog](https://github.com/YesYouKenSpace/zellij-smart-tabs/blob/v0.2.4/CHANGELOG.md#L8-L21)). Verification should therefore identify the expected asset by release tag and digest, and should expect the dashboard's embedded version to lag at 0.2.3.

## Constraints for the remaining wayfinding tickets

- Correct the map premise: smart-tabs owns tab names, not the persistent bar or theme.
- Decide between a native Zellij bar and no bar before prototyping; a one-row smart-tabs pane is not a valid option.
- If choosing a native bar, decide whether `tab-bar` alone is enough or whether preserving mode visibility requires `status-bar`/`compact-bar` behavior too.
- Keep smart-tabs at default naming configuration initially, as requested; manual-mode keybindings and application-status hooks are later tuning unless explicitly pulled into scope.
- Remove or replace the zjstatus-specific Nix assertion/rewrite during implementation.
- Test Zellij permission approval, several tabs and panes, CWD/repository/program-driven renames, tab overflow, fullscreen/sync display on the chosen native bar, theme inheritance, restart behavior, and the known multi-pane timeout risk.
- Treat the floating `latest` URL as a deliberate non-reproducible update policy. Record the resolved tag and digest during verification.
