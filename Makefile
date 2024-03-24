HUGO_VERSION := 0.122.0

help:           ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

.phony: run
run: .bin/hugo   ## Run site
	@.bin/hugo serve

.phony: build
build: .bin/hugo   ## Build the site
	@.bin/hugo

.phony: new
new: .bin/hugo  ## New hugo site - only used once
	@.bin/hugo new site . --force --format yaml
	@find . -maxdepth 1 -type d -not -name '.*' | while read dir; do touch $${dir}/.gitkeep; done

.bin/hugo:
	@mkdir .bin || true
	@curl -Lo .bin/hugo.tar.gz https://github.com/gohugoio/hugo/releases/download/v$(HUGO_VERSION)/hugo_$(HUGO_VERSION)_linux-amd64.tar.gz
	@tar -xzf .bin/hugo.tar.gz -C .bin
	@rm .bin/hugo.tar.gz

# Help Source: https://gist.github.com/prwhite/8168133