# Dotfiles agent instructions

This repository is a GNU Stow source tree for the home directory. Do not edit the live file through its home-directory symlink; edit the tracked source and run `stow .` only after review.

## Safety

- Never read, copy, or commit credentials, OAuth state, private keys, tokens, `auth.json`, sessions, package caches, or local application databases.
- Keep secret-bearing integrations (for example Epeo/1Password) optional and documented; their private material stays outside this repository.
- Treat bootstrap changes as high impact. Preserve idempotence and document manual prerequisites and rollback.

## Change workflow

1. Check `git status`; do not overwrite another session's work.
2. Update `README.md` and `install.sh` together when bootstrap behavior changes.
3. Run `make check`, inspect `git diff`, and manually test Stow/Pi changes where possible.
4. Keep `my-pi` as a submodule; use `make pi` rather than copying Pi runtime state into this repository.
