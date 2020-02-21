#!/bin/sh

BUILD_DIR="$(mktemp -d)"
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
is_not_mac() {
  ! is_mac
}
is_not_linux() {
  ! is_linux
}

msg() {
  printf "\r\033[2K\033[0;32m[ .. ] %s\033[0m\n" "$*"
}

git_has_pullable_tag() {
  TARGET="$1"
  RETVAL=1

  if [ ! -d "$TARGET" ]
  then
    RETVAL=0
  else
    cd "$TARGET" || exit

    git fetch origin 1> /dev/null
    LATEST_TAG="$(git describe --abbrev=0 --tags --match 'v[0-9]*' origin)"

    if [ "$(git rev-parse @)" != "$(git rev-parse @\{"$LATEST_TAG"\} 2> /dev/null)" ]
    then
      RETVAL=0
    fi
    cd - 1> /dev/null || exit
  fi

  return "$RETVAL"
}

git_has_pullable_master() {
  TARGET="$1"
  RETVAL=1

  if [ ! -d "$TARGET" ]
  then
    RETVAL=0
  else
    cd "$TARGET" || exit

    git fetch origin 1> /dev/null

    if [ "$(git rev-parse @)" != "$(git rev-parse @\{u\} 2> /dev/null)" ]
    then
      RETVAL=0
    fi

    cd - 1> /dev/null || exit
  fi

  return "$RETVAL"
}

git_clone_or_pull_tag() {
  GIT_URL="$1"
  TARGET="$2"

  if [ ! -d "$TARGET" ]
  then
    echo "Installing $GIT_URL."
    git clone "$GIT_URL" "$TARGET" 1> /dev/null
  fi

  cd "$TARGET" || exit

  git fetch --tags origin 1> /dev/null
  LATEST_TAG="$(git describe --abbrev=0 --tags --match 'v[0-9]*' origin)"

  if [ "$(git rev-parse @)" != "$(git rev-parse @\{$LATEST_TAG\} 2> /dev/null)" ]
  then
    echo "Upgrading $TARGET to $LATEST_TAG"
    git checkout "$LATEST_TAG" 2> /dev/null
  fi

  cd - 1> /dev/null || exit
}

git_clone_or_pull_master() {
  GIT_URL="$1"
  TARGET="$2"

  if [ ! -d "$TARGET" ]
  then
    echo "Installing $GIT_URL."
    git clone "$GIT_URL" "$TARGET" 1> /dev/null
  else
    cd "$TARGET" || exit

    git fetch origin 1> /dev/null

    if [ "$(git rev-parse @)" != "$(git rev-parse @\{u\} 2> /dev/null)" ]
    then
      echo "Upgrading $TARGET to latest master"
      git checkout master 2> /dev/null
    fi

    cd - 1> /dev/null || exit
  fi
}

get_var_or() {
  [ -z "$1" ] && echo "$2" || echo "$1"
}

ensure_build_dir() {
  mkdir -p "$BUILD_DIR/$1"
}

append_to_file() {
  # $1 -> type
  # $2 -> file
  # $3 -> alternate output file name
  source="$DOTFILE_DIR/$1/$2"
  source_os="$source.$(uname)"
  [ -z "$3" ] && target="$BUILD_DIR/.${2#.}" || target="$BUILD_DIR/.${3#.}"

  [ -f "$source" ] && cat "$source" >> "$target"
  [ -f "$source_os" ] && cat "$source_os" >> "$target"
}

install_binary() {
  # $1 -> type
  # $2 -> file
  source="$DOTFILE_DIR/$1/$2"
  source_os="$source.$(uname)"
  target="$BUILD_DIR/.local/bin/${2#.}"

  [ -f "$source" ] && cp "$source" "$target"
  [ -f "$source_os" ] && cp "$source_os" "$target"
}

install_directory() {
  # $1 -> type
  # $2 -> source
  # $3 -> target
  source="$DOTFILE_DIR/$1/$2"
  target="$BUILD_DIR/$3"

  mkdir -p $target

  [ -d "$source" ] && cp -a "$source" "$target"
}

uncallable() {
  ! command -v "$1" >/dev/null
}

install_pkg() {
  # $1 -> pkg name
  if is_mac;
  then
    brew install "$1"
  fi
  if is_freebsd;
  then
    sudo pkg install "$i"
  fi
  # FIXME: Add support for Debian
}

ensure_pkg() {
  # $1 -> cmd
  # $2 -> optional package name
  cmd="$1"
  [ -z "$2" ] && pkg_name="$1" || pkg_name="$2"
  if uncallable "$cmd";
  then
    install_pkg "$pkg_name"
  fi
}

# Configure home. Export variables that need to be accessible later on.
if is_mac
then
  CONFIG_DIR=$(get_var_or "$XDG_CONFIG_HOME" "$HOME/Library/Preferences/")
  CACHE_DIR=$(get_var_or "$XDG_CACHE_HOME" "$HOME/Library/Caches/")
  DATA_DIR=$(get_var_or "$XDG_DATA_HOME" "$HOME/Library/")
else
  CONFIG_DIR=$(get_var_or "$XDG_CONFIG_HOME" "$HOME/.config")
  CACHE_DIR=$(get_var_or "$XDG_CACHE_HOME" "$HOME/.cache")
  DATA_DIR=$(get_var_or "$XDG_DATA_HOME" "$HOME/.local/share")
fi

SYSTEMD_DIR="$CONFIG_DIR/systemd/user"
BIN_DIR="$HOME/.local/bin"
BUILD_CONFIG_DIR="${CONFIG_DIR#$HOME/}"
BUILD_CACHE_DIR="${CACHE_DIR#$HOME/}"
BUILD_DATA_DIR="${DATA_DIR#$HOME/}"
BUILD_SYSTEMD_DIR="${SYSTEMD_DIR#$HOME/}"
BUILD_BIN_DIR="${BIN_DIR#$HOME/}"

# Create build directory structure.
for e in "$BUILD_CONFIG_DIR" "$BUILD_CACHE_DIR" "$BUILD_DATA_DIR" "$BUILD_BIN_DIR";
do
  ensure_build_dir "$e"
done
is_linux && ensure_build_dir "$BUILD_SYSTEMD_DIR"

basics() {
  # $1 -> module name
  module="$1"
  for F in functions env aliases profile rc;
  do
    append_to_file "$module" "$F"
  done
}

# Directory layout
if is_not_mac
then
  for D in prj doc spool bkp tmp
  do
    ensure_build_dir "$D"
  done
fi

for MODULE in "core" "zsh" "git" "emacs" "gnupg" "ssh" "fzf"
do
  msg "Preparing module $MODULE"
  
  # shellcheck source=modules/core/_init
  . "modules/$MODULE/_init" 2> /dev/null
  
  basics "modules/$T"

  for FUNC in "_deps" "_install"; do
    if type "$FUNC" 2> /dev/null | grep -q function;
    then
      "$FUNC"
      unset -f "$FUNC"
    fi
  done
done

# Modules:
#
# Server profile: core, git, zsh??, tmux-server, fzf, exa
#
# Desktop profile: core, git, zsh, tmux, fzf, exa, gnupg, clojure, nodejs,
# python, rust, ruby, alacritty, mail, xorg, haskell, grep, firefox

# Setup shell related configurations.
# for F in functions env aliases profile rc
# do
#   for T in shell zsh ssh git gnupg xdg xorg \
#            grep exa fzf emacs systemd firefox \
#            node python haskell ruby rust
#   do
#     append_to_file $T $F
#   done
# done

# # PAM environment
# if is_linux;
# then
#   append_to_file "pam" "pam_environment"
#   for T in ssh dbus; do append_to_file "$T" "pam_environment"; done
# fi

# # TMUX
# append_to_file "tmux" "tmux.conf"

# # XDG
# is_not_mac && append_to_file "xdg" "user-dirs.dirs" "$BUILD_CONFIG_DIR/user-dirs.dirs"

# # Xorg
# if is_bsd || is_linux;
# then
#   D="$BUILD_CONFIG_DIR/xorg"
#   ensure_build_dir "$D"
#   for F in resources modmap; do append_to_file "xorg" "$F" "$D/$F"; done
# fi

# is_linux && install_binary "bin" "get-volume"
# install_binary "bin" "regularly-commit.sh"
# install_binary "bin" "launch_emacs"

# if is_linux || is_freebsd
# then
#   append_to_file "xorg" "xinitrc"
#   cd "$BUILD_DIR" || exit
#   ln -s .xinitrc .xsession
#   cd - || exit
# fi

# if is_mac;
# then
#   append_to_file "xorg" "resources" "Xresources"
#   append_to_file "xorg" "modmap" "Xmodmap"
# fi

# # Xmonad
# if is_not_mac
# then
#   ensure_build_dir ".xmonad"
#   for F in xmonad.hs xmobarrc stack.yaml build
#   do
#     append_to_file "xmonad" "$F" ".xmonad/$F"
#   done
# fi

# # Alacritty terminal
# ensure_build_dir "$BUILD_CONFIG_DIR/alacritty"
# append_to_file "alacritty" "alacritty.yml" "$BUILD_CONFIG_DIR/alacritty/alacritty.yml"

[ -d "$DOTFILE_DIR/build.bkp" ] && rm -rf "$DOTFILE_DIR/build.bkp";
[ -d "$DOTFILE_DIR/build" ] && mv "$DOTFILE_DIR/build" "$DOTFILE_DIR/build.bkp";
mv "$BUILD_DIR" "$DOTFILE_DIR/build"

echo "Built the following dotfiles dir"
tree -a build

while true; do
  echo "Do you wish to install those dotfiles? Answer y or n."
  read -r yn
  case $yn in
    [Yy]* )
      find build/ | while read -r F; do
        [ -d "$F" ] && mkdir -p "$HOME/${F#build/}"
        [ -f "$F" ] && install -C -m 0644 "$F" "$HOME/${F#build/}"
        # FIXME: cp -P doesn't work on *BSD, this will instead copy the file
        #        and not the link.
        [ -L "$F" ] && cp -P "$F" "$HOME/${F#build/}"
      done
      # FIXME: Fix up some permissions. Is there a better way to use the
      #        install command?
      [ -d "$HOME/.gnupg" ] && chmod 0700 "$HOME/.gnupg"
      [ -f "$HOME/.xmonad/build" ] && chmod +x "$HOME/.xmonad/build"
      for f in ~/.local/bin/*; do chmod +x "$f"; done
      break
      ;;
    [Nn]* ) exit;;
    * ) echo "Please answer yes or no.";;
  esac
done

# # External dependencies
# GIT_SUPER_STATUS_DIR="$HOME/.git-super-status"
# NVM_DIR="$HOME/.nvm"
# PYENV_ROOT="$HOME/.pyenv"
# RBENV_ROOT="$HOME/.rbenv"
# XMONAD_DIR="$HOME/.xmonad"

# git_clone_or_pull_tag https://github.com/creationix/nvm.git "$NVM_DIR"
# git_clone_or_pull_tag https://github.com/pyenv/pyenv.git "$PYENV_ROOT"
# git_clone_or_pull_tag https://github.com/pyenv/pyenv-virtualenv.git "$PYENV_ROOT/plugins/pyenv-virtualenv"
# git_clone_or_pull_tag https://github.com/rbenv/rbenv.git "$RBENV_ROOT"
# git_clone_or_pull_tag https://github.com/rbenv/ruby-build.git "$RBENV_ROOT/plugins/ruby-build"

# # Xmonad
# git_clone_or_pull_tag https://github.com/xmonad/xmonad.git "$XMONAD_DIR/xmonad-git"
# git_clone_or_pull_tag https://github.com/xmonad/xmonad-contrib.git "$XMONAD_DIR/xmonad-contrib-git"
# git_clone_or_pull_tag https://github.com/jaor/xmobar.git "$XMONAD_DIR/xmobar-git"

# # rust
# if [ ! -f "$HOME/.cargo/bin/rustup" ];
# then
#   curl -Ss https://sh.rustup.rs > /tmp/rustup-init.sh
#   /bin/sh /tmp/rustup-init.sh -y --no-modify-path
#   rm /tmp/rustup-init
# fi

# if git_has_pullable_master "$GIT_SUPER_STATUS_DIR";
# then
#   git_clone_or_pull_master https://github.com/olivierverdier/zsh-git-prompt.git "$GIT_SUPER_STATUS_DIR"
#   cd "$GIT_SUPER_STATUS_DIR" || exit
#   # The right resolver is not available on FreeBSD.
#   if is_freebsd
#   then
#     sed -i '' -e 's/resolver: lts-5.0/resolver: lts-13.11/g' stack.yaml
#   fi
#   stack clean
#   stack setup
#   stack build
#   cp src/.bin/gitstatus ~/.local/bin
#   cd - || exit
# fi
