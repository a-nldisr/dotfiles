.PHONY: all bin dotfiles install test shellcheck

all: setup bin dotfiles install

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

setup:
	sudo mkdir -p /usr/local/bin
	sudo chown -R $(USER) /usr/local/bin

install:
	sudo ./bin/root_setup.sh
	bash /usr/local/bin/install_darwin.sh all
	bash /usr/local/bin/setup_config.sh
	bash /usr/local/bin/vscode_extensions.sh
	
test: shellcheck

# We don't want to attach a TTY if this isnt interactive.
# If this is interactive users need to be able to ^C

INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -t
endif

shellcheck:
	docker run --rm -i $(DOCKER_FLAGS) \
		--name df-shellcheck \
		-v $(CURDIR):/usr/src:ro \
		--workdir /usr/src \
		anldisr/shellcheck ./test.sh
