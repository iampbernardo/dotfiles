# NOSTROMO on Ubuntu

The Ubuntu adapter shares the Mac's versioned visual configuration. It is designed
for Ubuntu 24.04 x86_64, with Python 3, Git, curl/HTTPS access, and the standard
ncurses `tic` command available. It requires no sudo and keeps the account's Bash
login shell. The first target is the user's Ithaka VPS.

## What lives where

`~/dotfiles` is a Git checkout of this repository without recursive submodules.
The installer links these source files directly into the user's config directory:

- `.config/starship.toml`: shared prompt and real SSH/hostname marker.
- `.config/fastfetch/config.jsonc`: shared spacecraft telemetry readout.
- `.config/lazygit/config.yml`: shared Git palette and delta diff renderer.
- `.config/btop/themes/nostromo.theme`: shared monitor colours.
- `scripts/ubuntu/btop.conf`: Ubuntu defaults, including no battery display and
  no automatic preference writes back into the versioned file.
- `scripts/ubuntu/init.bash`: Ubuntu startup, command deck, aliases, fzf, and zoxide.

Font, window, cursor and terminal palette remain controlled by Ghostty on the Mac.
The VPS needs no desktop, GPU renderer, or Nerd Font installation. The included
`ghostty.terminfo` is exported from Ghostty 1.3.1's bundled terminal definition and
compiled into the remote user's `~/.terminfo` for terminal-program compatibility.

The Bash adapter is intentionally separate from the Mac `.zshrc`: it does not load
Homebrew, OrbStack, macOS Keychain helpers, Oh My Zsh, or agent-specific wrappers.
It adds one managed block to `.bashrc` and preserves the existing shell content.
It affects interactive shells only. Non-interactive SSH commands remain quiet.
It does not change the login shell, SSH authentication, Git identity, project files,
agent settings, service configuration, or the `my-pi` submodule.

## Installation

```sh
git clone --no-recurse-submodules https://github.com/iampbernardo/dotfiles ~/dotfiles
cd ~/dotfiles
python3 scripts/ubuntu/install.py
```

The installer downloads official release archives listed in `releases.json`, checks
their SHA-256 digests, extracts only the selected executable, and installs it under
`~/.local/bin`. It verifies all archives before touching existing shell configuration.
Starship, Fastfetch, btop, lazygit, fzf, zoxide, bat, eza, and delta are included.
Versions and official download URLs are pinned in the manifest. No curl-to-shell
installer or package repository is added. HTTPS/network access to GitHub release
assets is required. Release hashes come from GitHub release asset metadata.

Existing files replaced by the installer are backed up under
`~/.local/state/nostromo/backups/<timestamp>/`. `new-files.json` records new files
and links so they can be distinguished during rollback. Re-running the installer
checks the same pinned releases and keeps a single managed Bash startup block.
It creates a backup directory for each run, even if no existing file needs replacing.

Open a new SSH session after installation. In a plain current Bash shell without
an agent or other foreground program, `source ~/.bashrc` also activates the setup.
The command deck identifies the remote hostname and SSH connection. The local time
in the prompt follows the VPS timezone, which can differ from the Mac timezone.

## Everyday commands

- `hud`: system snapshot with NOSTROMO spacecraft art.
- `top`: btop telemetry; `q` exits.
- `lg`: Git interface in a repository; `q` exits.
- `z name` / `zi`: jump to visited directories or choose one interactively.
- Control–R: fuzzy shell-history search; Escape cancels.
- `ls`, `ll`, `la`, `lt`: eza views; `cat`: bat using terminal ANSI colours.

Bash and zsh share this appearance and these tools, but their editing behaviour
and plugins are not identical. This adapter does not install zsh autosuggestions.
It also does not set up persistence for coding agents; that is a separate task.

## Validation

```sh
bash -n ~/.bashrc
bash -n ~/.config/nostromo/init.bash
~/.local/bin/starship --version
~/.local/bin/fastfetch --version
infocmp xterm-ghostty >/dev/null
```

Open a fresh Ghostty SSH session, inspect the prompt, run `hud`, and briefly open
`top` and `lg` to check full-screen rendering. Verify that a non-interactive SSH
command still emits only its requested output. Agent processes are not used as
installation tests.

## Keeping both machines aligned

Review and commit shared appearance changes in the dotfiles repository, then on
the other machine review `git status` and use `git pull --ff-only`. Do not overwrite
uncommitted work. Shared files are linked, so a new shell/prompt or reopened tool
picks up changes without copying themes again. If the Ubuntu adapter or release
manifest changes, review and rerun `python3 scripts/ubuntu/install.py`.

The Linux adapter is not a full machine bootstrap. It deliberately does not clone
or configure credentials, agents, project repositories, or private submodules.
Use Git to synchronise reviewed configuration, not runtime state.

## Rollback

Before rollback, inspect the chosen backup and current files for subsequent edits.
Restore only replaced files from the backup and remove only installer-created paths
listed in its `new-files.json` that you no longer need. In `.bashrc`, removing the
BEGIN NOSTROMO / END NOSTROMO block disables startup integration while preserving
other later shell edits. New shells then use their preceding prompt.

User-installed binaries can remain without being used. Remove them only after
checking that nothing else depends on them. The compiled user terminfo definition
is additive and may remain; no system terminfo database is modified. To change the
shared theme, edit the source in `~/dotfiles`, not a live symlink.
