DOTFILEDIR := $(shell pwd)
TARGETDIR := ~$(USER)

all: git mail

mail:
	@echo Installing mail ...
	@stow -t $(TARGETDIR) mail
	@[[ -f $(TARGETDIR)/.mail_lastlongsync ]] || touch $(TARGETDIR)/.mail_lastlongsync
	@[[ -d $(TARGETDIR)/.mail/cryptodrunks ]] || mkdir -p $(TARGETDIR)/.mail/cryptodrunks

git:
	@echo Installing git ...
	@stow -t $(TARGETDIR) git

.PHONY: git mail
