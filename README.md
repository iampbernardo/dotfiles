# dotfiles

Version-controlled macOS terminal and coding-agent setup, installed with GNU Stow. Pi is the configured agentic coding environment; the Epeo/Claude helper remains an optional integration.

## What is tracked

- shell, Git, Ghostty, Starship, btop, lazygit, fastfetch, and Raycast configuration;
- Homebrew bootstrap and macOS defaults;
- the reviewed [`my-pi`](my-pi) Git submodule, linked safely into `~/.pi/agent/` by its own `make link` command.

Credentials, Pi OAuth/session/package state, Epeo private keys, 1Password state, and application databases are deliberately not tracked.

## Fresh-machine bootstrap

```bash
git clone --recurse-submodules https://github.com/iampbernardo/dotfiles ~/dotfiles
cd ~/dotfiles
make check
./install.sh
```

The installer installs the Brewfile, Node, Pi `0.85.1` with npm lifecycle scripts disabled, initializes `my-pi`, links its configuration, installs shell tooling, Stows this repository, and applies macOS defaults. Re-running it is intended to be safe, but review its output before accepting Stow conflicts.

After opening a new terminal:

1. run `pi` and use `/login` to authenticate locally; never commit its generated `auth.json`;
2. run `/reload` after changing Pi configuration;
3. optionally install Epeo/1Password separately. Its private key remains under `~/.config/epeo/` and is never copied here.

## Daily use

```bash
make check       # validate tracked JSON, shell syntax, and forbidden paths
make pi          # initialize/link the Pi submodule
stow .           # apply this repository's home-directory links
```

The `.zshrc` also provides `dot`, `dotsync`, `dotpush`, `dotbrew`, and `agent` (`pi`). Pi's own documentation, validation, rollback, and safety controls live in the `my-pi` submodule.

## Rollback

For normal dotfiles, remove or restore the affected Stow symlink and run `stow .` after fixing the tracked file. For Pi, use the timestamped backups created by `my-pi`'s `make link`; see `my-pi/docs/operations.md`.
