# NOSTROMO MK.II / Ubuntu Bash adapter. Loaded only in interactive shells.
[[ $- == *i* ]] || return
[[ ${NOSTROMO_BASH_LOADED:-} == 1 ]] && return
NOSTROMO_BASH_LOADED=1
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac
[[ ${TERM:-dumb} != dumb ]] && export COLORTERM=truecolor
export BAT_THEME=ansi
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+$FZF_DEFAULT_OPTS }--color=bg:-1,bg+:#1b2b30,fg:#ddd3b8,fg+:#f5edda,hl:#e9ae55,hl+:#ffd58a,prompt:#e9ae55,pointer:#78c7c4,marker:#78c7c4,info:#71858a,spinner:#e9ae55,header:#78c7c4,border:#71858a"
command -v fzf >/dev/null && eval "$(fzf --bash)"
command -v zoxide >/dev/null && eval "$(zoxide init bash)"
command -v starship >/dev/null && eval "$(starship init bash)"
alias hud='fastfetch'
alias lg='lazygit'
alias top='btop'
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first'
alias la='eza -la --icons --group-directories-first'
alias lt='eza --tree --icons --level=2'
alias cat='bat --paging=never --style=plain'

nostromo_boot() {
  [[ -t 1 && ${TERM:-dumb} != dumb ]] || return 0
  local node="${HOSTNAME%%.*}" link=LOCAL row
  [[ -n ${SSH_CONNECTION:-}${SSH_TTY:-} ]] && link=SSH
  if (( ${COLUMNS:-80} < 64 )); then
    printf '\033[33m NOSTROMO / COMMAND DECK\033[0m\n'
    printf '\033[36m hud: systems  zi: nav  lg: git\033[0m\n'
    return 0
  fi
  local rule='────────────────────────────────────────────────────────'
  printf '\n\033[90m  ┌%s┐\033[0m\n' "$rule"
  printf '\033[90m  │\033[1;33m %-54s \033[0;90m│\033[0m\n' 'N O S T R O M O                         COMMAND DECK'
  printf '\033[90m  │\033[36m %-54s \033[90m│\033[0m\n' 'SYS / NAV / VCS                                  MK.II'
  printf '\033[90m  ├%s┤\033[0m\n' "$rule"
  row="NODE ${node:0:18}   /   $link   /   BASH ${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}"
  printf '\033[90m  │\033[37m %-54s \033[90m│\033[0m\n' "$row"
  printf '\033[90m  │\033[36m %-54s \033[90m│\033[0m\n' 'hud  systems     zi  navigation     lg  git console'
  printf '\033[90m  └%s┘\033[0m\n' "$rule"
}
nostromo_boot
