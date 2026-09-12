# NOSTROMO MK.II / startup panel. Only shell builtins; no polling or network calls.
nostromo_boot() {
  emulate -L zsh
  [[ -t 1 && "$TERM" != dumb ]] || return 0
  local node="${HOST%%.*}" link='LOCAL' row
  [[ -n "$SSH_CONNECTION$SSH_TTY" ]] && link='SSH'
  if (( COLUMNS < 64 )); then
    printf '\033[33m NOSTROMO / COMMAND DECK\033[0m\n'
    printf '\033[36m hud: systems  zi: nav  lg: git\033[0m\n'
    return 0
  fi
  local rule='────────────────────────────────────────────────────────'
  printf '\n\033[90m  ┌%s┐\033[0m\n' "$rule"
  printf '\033[90m  │\033[1;33m %-54s \033[0;90m│\033[0m\n' 'N O S T R O M O                         COMMAND DECK'
  printf '\033[90m  │\033[36m %-54s \033[90m│\033[0m\n' 'SYS / NAV / VCS                                  MK.II'
  printf '\033[90m  ├%s┤\033[0m\n' "$rule"
  row="NODE ${node[1,20]}   /   $link   /   ZSH $ZSH_VERSION"
  printf '\033[90m  │\033[37m %-54s \033[90m│\033[0m\n' "$row"
  printf '\033[90m  │\033[36m %-54s \033[90m│\033[0m\n' 'hud  systems     zi  navigation     lg  git console'
  printf '\033[90m  └%s┘\033[0m\n' "$rule"
}
