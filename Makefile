DOTFILEDIR := $(shell pwd)
TARGET := ~$(USER)

all: git mail xmonad zsh mpd rtorrent

mail:
	@echo Installing mail ...
	@[[ -f $(TARGET)/.mail_lastlongsync ]] || touch $(TARGET)/.mail_lastlongsync
	@[[ -d $(TARGET)/.mail/cryptodrunks ]] || mkdir -p $(TARGET)/.mail/cryptodrunks
	@[[ -d $(TARGET)/.config/systemd/user ]] || mkdir -p $(TARGET)/.config/systemd/user
	@stow -t $(TARGET) --ignore .config/systemd mail
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
	@stow -t $(TARGET) git

xmonad:
	@echo Installing xmonad ...
	@stow -t $(TARGET) xmonad
	@xmonad --recompile

shell:
	@echo Installing shell basics ...
	@stow -t $(TARGET) shell

zsh: shell
	@echo Installing zsh ...
	@stow -t $(TARGET) zsh

mpd:
	@echo Installing MPD ...
	@[[ -d $(TARGET)/.mpd ]] || mkdir -p $(TARGET)/.mpd
	@[[ -f $(TARGET)/.mpd/mpd.log ]] || touch $(TARGET)/.mpd/mpd.log
	@stow -t $(TARGET) --ignore .config/systemd mpd
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
	@stow -t $(TARGET) rtorrent

.PHONY: git mail xmonad shell zsh mpd rtorrent
