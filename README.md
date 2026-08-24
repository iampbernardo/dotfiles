# dotfiles

Mi setup de terminal: Ghostty + Starship (tema Tokyo Night Storm) + zsh, gestionado con [GNU Stow](https://www.gnu.org/software/stow/manual/stow.html).

## Qué incluye

| Archivo | Qué hace |
|---|---|
| [`.zshrc`](.zshrc) | oh-my-zsh, plugins (autosuggestions, syntax-highlighting, completions), alias/funciones (`eza`, `bat`, `zoxide`, `fzf`), helpers `dot`/`dotsync`/`dotpush`/`dothelp` |
| [`.gitconfig`](.gitconfig) | credenciales vía `gh`, diffs con `delta` |
| [`.config/ghostty/config`](.config/ghostty/config) | tema Tokyo Night Storm, fuente JetBrainsMono Nerd Font |
| [`.config/starship.toml`](.config/starship.toml) | prompt, mismos colores que Ghostty |
| [`Brewfile`](Brewfile) | todo lo que hay que instalar vía Homebrew |
| [`install.sh`](install.sh) | bootstrap completo para una Mac nueva |

## Instalar en una Mac nueva

```bash
git clone https://github.com/iampbernardo/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

Esto instala Homebrew (si falta), todo el `Brewfile` (Ghostty, la fuente, starship, eza, bat, fzf, zoxide, delta...), `uv`, oh-my-zsh y sus plugins, y al final corre `stow .` para crear los symlinks.

Si algún archivo ya existe en `$HOME` (p. ej. un `.zshrc` por defecto), Stow avisa del conflicto — hay que moverlo o borrarlo antes de correr `stow .` de nuevo.

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
