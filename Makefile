DOTFILEDIR := $(shell pwd)
TARGETDIR := ~$(USER)

all: git mail

mail:
	@echo Installing mail ...
	@[[ -f $(TARGETDIR)/.mail_lastlongsync ]] || touch $(TARGETDIR)/.mail_lastlongsync
	@[[ -d $(TARGETDIR)/.mail/cryptodrunks ]] || mkdir -p $(TARGETDIR)/.mail/cryptodrunks
	@[[ -d $(TARGETDIR)/.config/systemd/user ]] || mkdir -p $(TARGETDIR)/.config/systemd/user
	@stow -t $(TARGETDIR) --ignore .config/systemd mail
	@rm -rf $(TARGETDIR)/.config/systemd
	@cp -a $(DOTFILEDIR)/mail/.config/systemd $(TARGETDIR)/.config
	@systemctl --user --quiet reenable offlineimap.timer
	@systemctl --user --quiet reenable offlineimap.service
	@systemctl --user --quiet daemon-reload

git:
	@echo Installing git ...
	@stow -t $(TARGETDIR) git

.PHONY: git mail
