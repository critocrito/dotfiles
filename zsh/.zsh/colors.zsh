autoload -U colors && colors
# Only GNU coreutils have dircolors, not so on Mac or other BSD's.
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
if is_linux; then
  eval "$(dircolors -b)"
  # zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
else
  export CLICOLOR=1
  # zstyle ':completion:*:default' list-colors ''
  export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD
fi
# unset LSCOLORS
setopt prompt_subst
