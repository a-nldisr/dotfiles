.PHONY: all bin dotfiles test 

all: bin dotfiles 

bin:
	# add aliases to all in bin
	for file in $(shell find $(CURDIR)/bin -type f -not -name "*-backlight" -not -name ".*.swp"); do \
		f=$$(basename $$file); \
		sudo ln -sf $$file /usr/local/bin/$$f; \
	done

dotfiles:
	# add aliases for dotfiles
	for file in $(shell find $(CURDIR) -name ".*" -not -name ".gitignore" -not -name ".travis.yml" -not -name ".git" -not -name ".*.swp" -not -name ".gnupg"); do \
		f=$$(basename $$file); \
		ln -sfn $$file $(HOME)/$$f; \
	done; \
	gpg --list-keys || true;
	ln -sfn $(CURDIR)/.gnupg/gpg.conf $(HOME)/.gnupg/gpg.conf;
	ln -sfn $(CURDIR)/.gnupg/gpg-agent.conf $(HOME)/.gnupg/gpg-agent.conf;
	ln -fn $(CURDIR)/gitignore $(HOME)/.gitignore;
	git update-index --skip-worktree $(CURDIR)/.gitconfig;

test: 
	./test.sh

# We don't want to attach a TTY if this isnt interactive.
# If this is interactive users need to be able to ^C

INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -t
endif
