# NOSTROMO — terminal setup and daily use

**Current baseline:** Ghostty 1.3.1, zsh 5.9, Starship 1.26.0 on macOS / Apple M4.
Versions reflect the initial validation, not requirements pinned by this guide.
[DESIGN.md](DESIGN.md) defines the reusable style and colour semantics.

## Responsibilities and files

Paths below are relative to the root of this dotfiles repository.

| Component | Role | Source |
| --- | --- | --- |
| Ghostty | Window, font, palette, block cursor | `.config/ghostty/config` |
| zsh | Tool initialization, aliases, fuzzy-search colours | `.zshrc` |
| Startup panel | Compact command deck with narrow-pane fallback | `.config/ghostty/hud.zsh` |
| Starship | Two-line prompt, Git state, hostname, clock rail | `.config/starship.toml` |
| Fastfetch | Spacecraft diagram and system snapshot | `.config/fastfetch/config.jsonc` |
| lazygit | Amber active borders, cyan accents, dark selections | `.config/lazygit/config.yml` |
| btop | Square instrument panels and semantic meter colours | `.config/btop/btop.conf`, `.config/btop/themes/nostromo.theme` |
| Portable design | Colour and typography exports | `docs/nostromo/tokens.json`, `docs/nostromo/tokens.css` |

The home-directory configuration paths are GNU Stow symlinks into this repository.
Edit the source files here. `docs/` is excluded from Stow; it stays in the repository.
The existing installer still supplies the base tools; this theme adds no packages.
Do not run the entire installer just to reload a theme: it also bootstraps tooling
and applies macOS preferences.

## Everyday controls

| Action | Command or key | Meaning |
| --- | --- | --- |
| Reload Ghostty appearance | Command–Shift–comma | Reload the app configuration |
| New terminal tab | Command–T | Load the current shell configuration |
| System readout | `hud` | One Fastfetch snapshot, then return to the prompt |
| Live instrument panel | `top` | Alias for btop; `q` exits |
| Git console | `lg` | Alias for lazygit; `q` exits |
| Jump to a known directory | `z name` | zoxide uses directories you have visited |
| Choose a known directory | `zi` | Interactive zoxide/fzf chooser |
| Search shell history | Control–R | fzf history search; Escape cancels |
| Full configuration directory | `dot` | Change to the dotfiles repository |

`z` and `zi` are not searches over every directory on the disk. Visit a repository
normally once before expecting it to appear in zoxide. These tools are configured,
but the broader project-launching workflow is still to be designed with the user.

## Reading the prompt

Example (illustrative state, not a reading of a particular repository):

```text
┌─ [Nostromo] // project :: main ~2 ↑1 ───────────────── 01:24
└─ ▶
```

- Bracketed label: hostname of the machine running this shell/Starship.
- Cyan path: current directory, shortened to fit the configured path limit.
- Branch and Git symbols: `~` modified, `+` staged, `?` untracked, `↑` ahead,
  `↓` behind, `≡` stashed; numbers are counts. Conflicts and in-progress Git
  operations get explicit labels. Detached HEAD shows its commit hash.
- `T+`: duration of a command that took at least two seconds.
- `EXIT:n` and a red pointer: the previous command returned a nonzero status.
- `JOBS:n`: background shell jobs. The right-hand time is local prompt creation time.

The decorative NOSTROMO startup heading is the theme name. The NODE/hostname field
is the actual machine label. A remote machine needs its own compatible configuration
to show this prompt; installing this on the Mac does not configure VPSs. The `SSH`
marker is inferred from SSH environment variables and is not a security boundary.

## Apply and validate

On this configured Mac, reload Ghostty and open a new tab. Avoid restarting an
existing shell that has running jobs simply to see the new appearance.

For a reviewed checkout on another already-provisioned machine:

```sh
make check
zsh -n .zshrc
zsh -n .config/ghostty/hud.zsh
stow --simulate --verbose .
# Review the proposed links and resolve any conflicts, then:
stow .
```

Make sure the tools in the table and **JetBrainsMono Nerd Font Mono** are installed.
`make check` currently checks bootstrap shell syntax and forbidden tracked paths;
it does not fully validate every application's configuration.

On macOS, Ghostty can check its own config:

```sh
/Applications/Ghostty.app/Contents/MacOS/ghostty +validate-config
```

Then open a fresh tab and exercise `hud`, `zi`, `lg`, and `top`. Escape or `q` exits
selectors and interfaces as appropriate. Read-only theme validation does not prove
every interactive action or remote workflow works.

## Rollback and maintenance

Keep local backups outside the tracked repository. This Mac has pre-change copies
under `Documents/ChatGPT/OPTIMIZE my Mac/terminal-backups/`; the `*-mk2` backup
contains the preceding accepted style and a list of files newly added for MK.II.

To restore a theme, compare the selected backup with the current tracked sources
and restore only the affected appearance files. Reload Ghostty and open a new tab.
Preserve subsequent edits and unrelated Git/agent configuration. A reviewed Git
revert of the theme commit is another option after checking for later changes.

Keep `tokens.json`, `tokens.css`, and explicit application values synchronized.
The palette is not generated automatically. btop/lazygit can save preferences;
inspect their diffs before committing. Never use a blanket dotfile push for a
scoped theme update when other work is present.

## Why Ghostty, and when to reconsider Warp

Ghostty is the current baseline because this native terminal and the independently
configured shell, Git, and monitoring tools now fit the user's preferred look.
This is a workflow choice, not a measured claim that Ghostty outperforms Warp on
this Mac or that Warp cannot support these agents or colours.

[Warp's current documentation](https://docs.warp.dev/) describes command blocks,
rich editing, a code editor/review interface, and support for third-party CLI agents
including Claude Code and Codex. Those capabilities could reduce context switching.
[Ghostty](https://ghostty.org/docs/about) supplies native terminal features while
leaving the editor and agent workflow to the user's chosen tools.

Reconsider with one real project: compare opening the project, editing a command,
resuming an agent session, inspecting a diff, and SSH work. Judge completion effort
and friction, not appearance alone. The NOSTROMO tokens can be ported if Warp wins;
this theme is not a reason to lock the user into Ghostty.

## Ubuntu / Ithaka

The remote deployment uses this same repository with a small Bash adapter.
Follow [UBUNTU.md](UBUNTU.md) for installation, verification, and rollback.
Run the Ubuntu installer there; do not Stow the Mac `.zshrc` onto Linux.
