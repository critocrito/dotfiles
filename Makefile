DOTFILEDIR := $(shell pwd)
TARGETDIR := ~$(USER)

all: git mail xmonad zsh mpd

mail:
	@echo Installing mail ...
	@[[ -f $(TARGETDIR)/.mail_lastlongsync ]] || touch $(TARGETDIR)/.mail_lastlongsync
	@[[ -d $(TARGETDIR)/.mail/cryptodrunks ]] || mkdir -p $(TARGETDIR)/.mail/cryptodrunks
	@[[ -d $(TARGETDIR)/.config/systemd/user ]] || mkdir -p $(TARGETDIR)/.config/systemd/user
	@stow -t $(TARGETDIR) --ignore .config/systemd mail
	@cp -a $(DOTFILEDIR)/mail/.config/systemd $(TARGETDIR)/.config
	@systemctl --user --quiet reenable offlineimap.timer
	@systemctl --user --quiet reenable offlineimap.service
	@systemctl --user --quiet reenable index-mail.timer
	@systemctl --user --quiet reenable index-mail.service
	@systemctl --user --quiet reenable index-addressbook.timer
	@systemctl --user --quiet reenable index-addressbook.service
	@systemctl --user --quiet daemon-reload

git:
	@echo Installing git ...
	@stow -t $(TARGETDIR) git

xmonad:
	@echo Installing xmonad ...
	@stow -t $(TARGETDIR) xmonad
	@xmonad --recompile

shell:
	@echo Installing shell basics ...
	@stow -t $(TARGETDIR) shell

zsh: shell
	@echo Installing zsh ...
	@stow -t $(TARGETDIR) zsh

mpd:
	@echo Installing MPD ...
	@[[ -d $(TARGETDIR)/.mpd ]] || mkdir -p $(TARGETDIR)/.mpd
	@[[ -f $(TARGETDIR)/.mpd/mpd.log ]] || touch $(TARGETDIR)/.mpd/mpd.log
	@stow -t $(TARGETDIR) --ignore .config/systemd mpd
	@cp -a $(DOTFILEDIR)/mpd/.config/systemd $(TARGETDIR)/.config
	@systemctl --user --quiet reenable mpd.service
	@systemctl --user --quiet restart mpd.service
	@systemctl --user --quiet daemon-reload

.PHONY: git mail xmonad shell zsh mpd
