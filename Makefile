DOTFILEDIR := $(shell pwd)
TARGET := ~$(USER)
STOW := stow -t $(TARGET)

all: git mail xmonad zsh mpd rtorrent keyring

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

shell:
	@echo Installing shell basics ...
	@$(STOW) shell

zsh: shell
	@echo Installing zsh ...
	@[[ -d $(TARGET)/.zshenv.d ]] || mkdir $(TARGET)/.zshenv.d
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

keyring:
	@echo install keyring ...
	@[[ -d $(TARGET)/.zshenv.d ]] || mkdir $(TARGET)/.zshenv.d
	@$(STOW) keyring

.PHONY: git mail xmonad shell zsh mpd rtorrent keyring
