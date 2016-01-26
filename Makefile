DOTFILEDIR := $(shell pwd)
TARGET := ~$(USER)
SYSTEMD_USER := $(TARGET)/.config/systemd/user
LOCAL_BIN := $(TARGET)/.local/bin
STOW := stow -t $(TARGET)

all: git mail X xmonad urxvt zsh mpd rtorrent keyring python node tmux emacs irssi android gnupg

ensurezshenvd:
	@[[ -d $(TARGET)/.zshenv.d ]] || mkdir $(TARGET)/.zshenv.d

ensurezshd:
	@[[ -d $(TARGET)/.zsh.d ]] || mkdir $(TARGET)/.zsh.d

ensuresystemd:
	@[[ -d $(SYSTEMD_USER) ]] || mkdir -p $(SYSTEMD_USER)

ensurebin:
	@[[ -d $(LOCAL_BIN) ]] || mkdir -p $(LOCAL_BIN)


mail: ensuresystemd
	@echo Installing mail ...
	@[[ -f $(TARGET)/.mail_lastlongsync ]] || touch $(TARGET)/.mail_lastlongsync
	@[[ -d $(TARGET)/.mail/cryptodrunks ]] || mkdir -p $(TARGET)/.mail/cryptodrunks
	@[[ -d $(TARGET)/.mail/tacticaltech ]] || mkdir -p $(TARGET)/.mail/tacticaltech

	@$(STOW) --ignore systemd mail
	@cp -a $(DOTFILEDIR)/mail/systemd/offlineimap.timer $(TARGET)/.config/systemd/user
	@cp -a $(DOTFILEDIR)/mail/systemd/offlineimap.service $(TARGET)/.config/systemd/user
	@cp -a $(DOTFILEDIR)/mail/systemd/index-mail.timer $(TARGET)/.config/systemd/user
	@cp -a $(DOTFILEDIR)/mail/systemd/index-mail.service $(TARGET)/.config/systemd/user
	@cp -a $(DOTFILEDIR)/mail/systemd/index-addressbook.timer $(TARGET)/.config/systemd/user
	@cp -a $(DOTFILEDIR)/mail/systemd/index-addressbook.service $(TARGET)/.config/systemd/user

	@systemctl --user --quiet reenable offlineimap.timer
	@systemctl --user --quiet reenable offlineimap.service
	@systemctl --user --quiet reenable index-mail.timer
	@systemctl --user --quiet reenable index-mail.service
	@systemctl --user --quiet reenable index-addressbook.timer
	@systemctl --user --quiet reenable index-addressbook.service
	@systemctl --user --quiet daemon-reload

git:
	@echo Installing git ...
	@$(STOW) git

xmonad:
	@echo Installing xmonad ...
	@$(STOW) xmonad
	@xmonad --recompile

shell: ensurezshd
	@echo Installing shell basics ...
	@$(STOW) shell

zsh: shell ensurezshenvd ensurezshd
	@echo Installing zsh ...
	@$(STOW) zsh

mpd: ensuresystemd
	@echo Installing MPD ...
	@[[ -d $(TARGET)/.mpd ]] || mkdir -p $(TARGET)/.mpd
	@[[ -d $(TARGET)/.mpd/playlists ]] || mkdir -p $(TARGET)/.mpd/playlists
	@[[ -f $(TARGET)/.mpd/mpd.log ]] || touch $(TARGET)/.mpd/mpd.log
	@$(STOW) --ignore systemd mpd
	@cp -a $(DOTFILEDIR)/mpd/systemd/mpd.service $(TARGET)/.config/systemd/user
	@systemctl --user --quiet reenable mpd.service
	@systemctl --user --quiet restart mpd.service
	@systemctl --user --quiet daemon-reload

rtorrent:
	@echo Installing rtorrent ...
	@[[ -d $(TARGET)/.rtorrent/incoming ]] || mkdir -p $(TARGET)/.rtorrent/incoming
	@[[ -d $(TARGET)/.rtorrent/session ]] || mkdir -p $(TARGET)/.rtorrent/session
	@[[ -d $(TARGET)/.rtorrent/Torrents ]] || mkdir -p $(TARGET)/Torrents
	@[[ -d $(TARGET)/.rtorrent/Downloads ]] || mkdir -p $(TARGET)/Downloads
	@$(STOW) rtorrent

keyring: ensurezshenvd
	@echo Installing keyring ...
	@$(STOW) keyring

ruby: ensurezshenvd ensurezshd
	@echo Installing ruby ...
	@[[ -d $(TARGET)/.rbenv ]] || git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
	@[[ -d $(TARGET)/.rbenv/plugins/ruby-build ]] || git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
	@$(STOW) ruby

python: ensurezshenvd ensurezshd
	@echo Installing python ...
	@[[ -d $(TARGET)/.pyenv ]] || git clone https://github.com/yyuu/pyenv.git ~/.pyenv
	@[[ -d $(TARGET)/.pyenv/plugins/pyenv-pip-rehash ]] || git clone https://github.com/yyuu/pyenv-pip-rehash.git ~/.pyenv/plugins/pyenv-pip-rehash
	@[[ -d $(TARGET)/.pyenv/plugins/pyenv-virtualenv ]] || git clone https://github.com/yyuu/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv
	@$(STOW) python

haskell: ensurezshd
	@echo Installing haskell ...
	@$(STOW) haskell

X:
	@echo Installing X ...
	@$(STOW) X

urxvt:
	@echo Installing urxvt ...
	@$(STOW) urxvt

tmux:
	@echo Installing tmux ...
	@$(STOW) tmux

emacs: ensuresystemd
	@echo Installing emacs ...
	@$(STOW) --ignore systemd emacs
	@echo Installing emacs systemd unit ...
	@sudo cp $(DOTFILEDIR)/emacs/systemd/emacs.service $(SYSTEMD_USER)/emacs.service
	@systemctl --user daemon-reload
	@systemctl --user enable emacs.service
	@systemctl --user restart emacs.service

node: ensurezshd
	@echo Installing node ...
	@[[ -d $(TARGET)/.nvm ]] || (git clone https://github.com/creationix/nvm.git ~/.nvm && cd ~/.nvm && git checkout `git describe --abbrev=0 --tags` && cd -)
	@$(STOW) node

irssi:
	@echo Installing irssi ...
	@$(STOW) irssi

android: ensurezshd
	@echo Installing android ...
	@$(STOW) android

gnupg:
	@echo Installing gnupg
	@$(STOW) gnupg

.PHONY: ensurezshenv ensurezshd \
	git mail xmonad shell zsh mpd rtorrent keyring python X urxvt tmux \
	emacs node irssi ruby android gnupg
