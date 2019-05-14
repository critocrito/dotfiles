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
