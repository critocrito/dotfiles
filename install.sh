#!/bin/sh

BUILD_DIR="$(mktemp -d -p .)"
DOTFILE_DIR="$(pwd)"

echo "Building dotfiles from $DOTFILE_DIR in $BUILD_DIR."

_is_os() {
  [ "$(uname)" = "$1" ]
}

is_mac() {
  _is_os "Darwin"
}

is_linux() {
  _is_os "Linux"
}

is_freebsd() {
  _is_os "FreeBSD"
}

is_openbsd() {
  _is_os "OpenBSD"
}

is_bsd() {
  is_freebsd || is_openbsd
}

get_var_or() {
  if [ -z "$1" ];
  then
    echo "$2"
  else
    echo "$1"
  fi
}

append_to_file() {
  # $1 -> type
  # $2 -> file
  # $3 -> alternate output file name
  source="$DOTFILE_DIR/$1/$2"
  source_os="$source.$(uname)"
  [ -z "$3" ] && target="$BUILD_DIR/.$2" || target="$BUILD_DIR/.$3"

  if [ -f "$source" ];
  then
    { echo ""; echo "# $1/$2"; cat "$source"; } >> "$target"
  fi

  if [ -f "$source_os" ];
  then
    { echo ""; echo "# $1/$2.$(uname)"; cat "$source_os"; } >> "$target"
  fi
}

# Configure home. Export variables that need to be accessible in erb templates.
if is_mac
then
  CONFIG_DIR="$HOME/Library/Preferences/"
  CACHE_DIR="$HOME/Library/Caches/"
  DATA_DIR="$HOME/Library/"
else
  CONFIG_DIR=$(get_var_or "$XDG_CONFIG_HOME" "$HOME/.config")
  CACHE_DIR=$(get_var_or "$XDG_CACHE_HOME" "$HOME/.cache")
  DATA_DIR=$(get_var_or "$XDG_DATA_HOME" "$HOME/.local/share")
fi

SYSTEMD_DIR="$CONFIG_DIR/systemd/user"
GIT_SUPER_STATUS_DIR="$HOME/.git-super-status"
NVM_DIR="$HOME/.nvm"
PYENV_ROOT="$HOME/.pyenv"
RBENV_ROOT="$HOME/.rbenv"

# Create directory structure.
for e in "$CONFIG_DIR" "$CACHE_DIR" "$DATA_DIR"; do mkdir -p "$e"; done
if is_linux; then mkdir -p "$SYSTEMD_DIR"; fi
if is_bsd || is_linux;
then
  for D in bkp doc img old snd spool tmp vid www; do mkdir -p "$HOME/$D"; done
fi

# Setup shell related configurations.
for F in functions env aliases profile rc
do
  for T in shell zsh ssh git grep mail gnupg emacs systemd rtorrent node python \
                 haskell ruby fzf rust firefox
  do
    append_to_file $T $F
  done
done

# ZSH.
for F in zprofile zshenv zshrc; do
  append_to_file "zsh" "$F"
done

# TMUX
append_to_file "tmux" "tmux.conf"

# Xorg
if is_bsd || is_linux;
then
  mkdir -p "$CONFIG_DIR/xorg"
  append_to_file "xorg" "resources" "Xresources"
fi

[ -d "$DOTFILE_DIR/build.bkp" ] && rm -rf "$DOTFILE_DIR/build.bkp";
[ -d "$DOTFILE_DIR/build" ] && mv "$DOTFILE_DIR/build" "$DOTFILE_DIR/build.bkp";
mv "$BUILD_DIR" "$DOTFILE_DIR/build"
