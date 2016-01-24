### Predicates
_is_os() { [[ "$OSTYPE" =~ ^$1 ]] }
_has_cmd() { [[ -n ${commands[$1]} ]] }

is_mac() { _is_os darwin }
is_freebsd() { _is_os freebsd }
is_linux() { _is_os linux-gnu }

has_brew() { _has_cmd brew}
has_apt() { _has_cmd apt }
has_pacman() { _has_cmd pacman }

has_function() {
  whence -w $1 >/dev/null
}

### Helpers
# Collapse the pwd to a tilde if it is the home directory.
collapse_pwd() {
  echo $(pwd | sed -e "s,^$HOME,~,")
}
