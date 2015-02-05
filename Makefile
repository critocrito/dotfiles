DOTFILEDIR := $(shell pwd)
TARGETDIR := ~$(USER)

git:
	@echo Installing git ...
	@stow -t $(TARGETDIR) git

all: git

.PHONY: git
