# `dotfiles`

These are my dotfiles, that I use those to setup servers as well as desktops.
Several operating systems are supported: macOS, Linux and FreeBSD.

## Bootstrap

To get started you need `curl` and `sudo` installed. The user that installs
dotfiles requires sudo privileges.

``` sh
sh <(curl -s https://raw.githubusercontent.com/critocrito/dotfiles/master/bootstrap.sh)
```

## Deploy

There are two profiles available in [~./profiles~](./profiles), one for a server
setup, and one for the desktop. To use either of one run:

``` sh
./dot server
./dot desktop
```

