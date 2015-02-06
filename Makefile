DOTFILEDIR := $(shell pwd)
TARGET := ~$(USER)
STOW := stow -t $(TARGET)

all: git mail xmonad zsh mpd rtorrent keyring python X urxvt tmux emacs

ensurezshenvd:
	@[[ -d $(TARGET)/.zshenv.d ]] || mkdir $(TARGET)/.zshenv.d

ensurezshd:
	@[[ -d $(TARGET)/.zsh.d ]] || mkdir $(TARGET)/.zsh.d

mail:
	@echo Installing mail ...
	@[[ -f $(TARGET)/.mail_lastlongsync ]] || touch $(TARGET)/.mail_lastlongsync
	@[[ -d $(TARGET)/.mail/cryptodrunks ]] || mkdir -p $(TARGET)/.mail/cryptodrunks
	@[[ -d $(TARGET)/.config/systemd/user ]] || mkdir -p $(TARGET)/.config/systemd/user
	@$(STOW) --ignore .config/systemd mail
	@cp -a $(DOTFILEDIR)/mail/.config/systemd $(TARGET)/.config
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

zsh: shell ensurezshenvd
	@echo Installing zsh ...
	@$(STOW) zsh

mpd:
	@echo Installing MPD ...
	@[[ -d $(TARGET)/.mpd ]] || mkdir -p $(TARGET)/.mpd
	@[[ -f $(TARGET)/.mpd/mpd.log ]] || touch $(TARGET)/.mpd/mpd.log
	@$(STOW) --ignore .config/systemd mpd
	@cp -a $(DOTFILEDIR)/mpd/.config/systemd $(TARGET)/.config
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

python: ensurezshenvd ensurezshd
	@echo Installing python ...
	@[[ -d $(TARGET)/.pyenv ]] || git clone https://github.com/yyuu/pyenv.git ~/.pyenv
	@[[ -d $(TARGET)/.pyenv/plugins/pyenv-pip-rehash ]] || git clone https://github.com/yyuu/pyenv-pip-rehash.git ~/.pyenv/plugins/pyenv-pip-rehash
	@[[ -d $(TARGET)/.pyenv/plugins/pyenv-virtualenv ]] || git clone https://github.com/yyuu/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv
	@$(STOW) python

X:
	@echo Installing X ...
	@$(STOW) X

urxvt:
	@echo Installing urxvt ...
	@$(STOW) urxvt

tmux:
	@echo Installing tmux ...
	@$(STOW) tmux

emacs:
	@echo Installing emacs ...
	@$(STOW) emacs

.PHONY: ensurezshenv ensurezshd \
	git mail xmonad shell zsh mpd rtorrent keyring python X urxvt tmux emacs
