autoload -U colors && colors
# Only GNU coreutils have dircolors, not so on Mac or other BSD's.
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
if is_linux; then
  eval "$(dircolors -b)"
else
  export CLICOLOR=1
  export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD
fi
setopt prompt_subst
