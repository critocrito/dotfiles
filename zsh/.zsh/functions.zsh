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

# Create a new directory and enter it.
md() {
  mkdir -p "$@" && cd "$@"
}

# Shorthand for find
f() {
  find . -name "$1" 2>&1 | grep -v 'Permission denied'
}

# Git commmit browser
log() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --toggle-sort=\` \
      --bind "ctrl-m:execute:
                echo '{}' | grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R'"
}

# Start a webserver, optionally specifying a port
server() {
  local port="${1:-8000}"
  python -m http.server $port
}

# Copy w/ progress
cp_p () {
  rsync -WavP --human-readable --progress $1 $2
}

# get gzipped size
gz() {
	echo "orig size    (bytes): "
	cat "$1" | wc -c
	echo "gzipped size (bytes): "
	gzip -c "$1" | wc -c
}

csvview() {
      sed 's/,,/, ,/g;s/,,/, ,/g' "$@" | column -s, -t | less -#2 -N -S
}
