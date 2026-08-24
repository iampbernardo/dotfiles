# dotfiles

Mi setup de Mac: Ghostty + Starship + zsh en terminal, sketchybar + borders
a nivel sistema — todo en **Tokyo Night Storm** — gestionado con
[GNU Stow](https://www.gnu.org/software/stow/manual/stow.html).

## Qué incluye

| Archivo | Qué hace |
|---|---|
| [`.zshrc`](.zshrc) | oh-my-zsh, plugins (autosuggestions, syntax-highlighting, completions), alias/funciones (`eza`, `bat`, `zoxide`, `fzf`, `lg`=lazygit, `top`=btop), banner `fastfetch`, helpers `dot`/`dotsync`/`dotpush`/`dotbrew`/`dothelp` |
| [`.gitconfig`](.gitconfig) | credenciales vía `gh`, diffs con `delta` |
| [`.config/ghostty/config`](.config/ghostty/config) | terminal — tema Tokyo Night Storm, fuente JetBrainsMono Nerd Font |
| [`.config/starship.toml`](.config/starship.toml) | prompt, mismos colores que Ghostty |
| [`.config/btop/`](.config/btop) | monitor de sistema (`top`), tema custom |
| [`.config/lazygit/config.yml`](.config/lazygit/config.yml) | TUI de git (`lg`) |
| [`.config/fastfetch/config.jsonc`](.config/fastfetch/config.jsonc) | banner de sistema al abrir terminal |
| [`.config/sketchybar/`](.config/sketchybar) | barra de menú custom (app activa, reloj, batería) |
| [`.config/borders/bordersrc`](.config/borders/bordersrc) | borde de color en la ventana activa |
| [`.config/raycast/TokyoNightStorm.rctheme`](.config/raycast/TokyoNightStorm.rctheme) | tema de Raycast (import manual desde Preferences → Appearance) |
| [`macos-defaults.sh`](macos-defaults.sh) | Dock, Finder, teclado, capturas — vía `defaults write` |
| [`scripts/gen_wallpaper.py`](scripts/gen_wallpaper.py) | genera el wallpaper degradado Tokyo Night (sin dependencias) |
| [`Brewfile`](Brewfile) | todo lo que hay que instalar vía Homebrew |
| [`install.sh`](install.sh) | bootstrap completo para una Mac nueva |

## Instalar en una Mac nueva

```bash
git clone https://github.com/iampbernardo/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

Esto instala Homebrew (si falta), todo el `Brewfile` (Ghostty, sketchybar,
la fuente, starship, eza, bat, fzf, zoxide, delta...), `uv`, oh-my-zsh y sus
plugins, enlaza todo con `stow .`, aplica `macos-defaults.sh`, y arranca
sketchybar/borders al final.

Si algún archivo ya existe en `$HOME` (p. ej. un `.zshrc` por defecto), Stow avisa del conflicto — hay que moverlo o borrarlo antes de correr `stow .` de nuevo.

**Después de correrlo, manual:**
- El tema de Raycast no se aplica solo: `open -a Raycast ~/.config/raycast/TokyoNightStorm.rctheme` y confirmar el import desde la UI de Raycast.
- El wallpaper no lo pone `install.sh` — `python3 scripts/gen_wallpaper.py` y luego aplicarlo desde Preferencias del Sistema (o `osascript`).

## Uso diario

Todo esto vive como funciones/alias en el `.zshrc`, ya disponibles en cualquier terminal:

```bash
dot              # cd a ~/dotfiles
dotsync          # stow . + muestra qué cambió (sin commitear)
dotpush "msg"    # stow . + commit + push
dothelp          # chuleta rápida de estos comandos
```

## Agregar un dotfile nuevo

1. Mueve el archivo real a `~/dotfiles` manteniendo su ruta relativa a `$HOME`
   (p. ej. `~/.config/tmux/tmux.conf` → `~/dotfiles/.config/tmux/tmux.conf`)
2. `dotsync` — crea el symlink de vuelta a `$HOME`
3. Si el paquete que instalaste no está en `Brewfile`, agrégalo ahí también.

## Recursos

- [GNU Stow](https://www.gnu.org/software/stow/manual/stow.html)
- [Ghostty](https://ghostty.org)
- [Starship](https://starship.rs)
