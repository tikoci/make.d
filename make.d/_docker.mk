## ** DESKTOP DOCKER **
# > Targets for Desktop Docker for local testing/building

# NOTE: Makefile works for local usage with Docker, too

# For local make.d development and expirimentation...
# ... when used on a desktop with Docker installed
# `make docker-build` will create a **local** version for testing,
# ... and put you the moral-equivalent of /container/shell.
# various out docker- things are below

# ** DO NOT EDIT container files **  -  edit Makefile on PC then re-run "make docker-shell"
# N.B.: since docker-shell will REMOVE the container when you exit - this forces automting things in recipe...
#       Now.. some quick changes are okay - but this forces a cut-and-paste back to a make.d/*.mk.

DOCKER_PORTMAP ?= 28080:80
DOCKER_RUN ?= --net=host

.PHONY: docker-shell
.ONESHELL: docker-shell
docker-shell:
	docker buildx build $(DOCKER_OPTS) --tag make.d .
	PID=$$(docker run --detach $(DOCKER_RUN) `docker images | awk '{print $$3}' | awk 'NR==2'` $(SERVICES)) && docker exec -it $$PID /bin/bash && docker kill $$PID && docker rm $$PID;

.PHONY: docker-run
.ONESHELL: docker-run
docker-run:
	docker buildx build $(DOCKER_OPTS) --tag make.d .
	PID=$$(docker run -p $(DOCKER_PORTMAP) --detach $(DOCKER_RUN) `docker images | awk '{print $$3}' | awk 'NR==2'` $(SERVICES))

# todo: quick hack for test, should be built on GitHub
.PHONY: docker-build
docker-build: docker-build-arm6 docker-build-arm7 docker-build-arm64 docker-build-x86

.PHONY: docker-build-arm6
.ONESHELL: docker-build-arm6
docker-build-arm6:
	docker buildx build --output type=oci --platform=linux/arm/v6 --tag make.d . > make.d-arm6.tar

.PHONY: docker-build-arm7
.ONESHELL: docker-build-arm7
docker-build-arm7:
	docker buildx build --output type=oci --platform=linux/arm/v7 --tag make.d . > make.d-arm7.tar

.PHONY: docker-build-arm64
.ONESHELL: docker-build-arm64
docker-build-arm64:
	docker buildx build --output type=oci --platform=linux/arm64 --tag make.d . > make.d-arm64.tar

.PHONY: docker-build-x86
.ONESHELL: docker-build-x86
docker-build-x86:
	docker buildx build --output type=oci --platform=linux/amd64 --tag make.d . > make.d-x86.tar