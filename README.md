# Requirements

- `make`
- `stow`

# ZSH

    curl -L http://install.ohmyz.sh | sh

NOTE: oh-my-zsh must be installed manually. The installer creates a
new ~/.zshrc. Run make zsh again.

    rm ~/.zshrc
    make zsh

# Mail Setup

    sudo pacman -S \
      postfix \
      offlineimap \
      mutt \
      notmuch

    notmuch setup

## References

- http://dev.gentoo.org/~tomka/mail.html
