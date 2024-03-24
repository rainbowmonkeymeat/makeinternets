git_hash = $(shell git rev-parse --short -q HEAD)
version := 0.10.0
release_date := $(shell date +%Y-%m-%d)


DOCKER_REPO=quay.io/ssmiller25
IMAGE_NAME=makeinternets


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
	@curl -Lo .bin/hugo.tar.gz https://github.com/gohugoio/hugo/releases/download/v$(hugo_version)/hugo_$(hugo_version)_linux-amd64.tar.gz
	@tar -xzf .bin/hugo.tar.gz -C .bin
	@rm .bin/hugo.tar.gz

.PHONY: build-docker
build-docker:  # Build the docker container
	@docker build . -t ${DOCKER_REPO}/$(IMAGE_NAME):${git_hash} \
		$(docker_extra_param) \
		--build-arg GIT_HASH=${git_hash} \
		--build-arg VERSION=${version} \
		--build-arg RELEASE_DATE=${release_date}
	@docker tag ${DOCKER_REPO}/$(IMAGE_NAME):${git_hash} ${DOCKER_REPO}/$(IMAGE_NAME):latest

.PHONY: build-nocache
build-docker-nocache: docker_extra_param=--no-cache # Build without using any cached information
build-docker-nocache: build-docker


.PHONY: run-docker
run-docker:  # Run the docker container
	@docker run -d --rm -p 8080:80 --name $(IMAGE_NAME) ${DOCKER_REPO}/$(IMAGE_NAME):latest 
	@echo "Local running.  Go to http://localhost:8080/ to view"

.PHONY: stop-docker
stop-docker: # Stop the docker container - should self-cleanup
	@echo "Stopping $(IMAGE_NAME) - should self-cleanup"
	@docker stop $(IMAGE_NAME)

.PHONY: push-docker
push-docker: # Pusht he docker container to the upstream repo
	@docker push ${DOCKER_REPO}/$(IMAGE_NAME):$(git_hash)
	@docker push ${DOCKER_REPO}/$(IMAGE_NAME):latest

# Help Source: https://gist.github.com/prwhite/8168133