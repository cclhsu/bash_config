# https://www.gnu.org/software/make/manual/make.html
# https://www.gnu.org/software/make/manual/html_node/Simple-Makefile.html
##### HOWTO #####

##### VARIABLES #####
# TOP_DIR=$(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
TOP_DIR=$(shell dirname $(abspath $(firstword $(MAKEFILE_LIST))))
PROJECT_TYPE=
# https://hub.docker.com/_/<OFFICIAL_DOCKER_PROJECT>
# make USE_OFFICIAL=1 <COMMAND>
ifdef USE_OFFICIAL
	# docker.io | quay.io | gcr.io
	DOCKER_REGISTRY=
	# <OFFICIAL_DOCKER_PROJECT> | $(shell echo $(notdir $(TOP_DIR)) | cut -d '/' -f2 | tr -d '[:space:]' | cut -d '_' -f2)
	DOCKER_PROJECT=$(shell echo $(notdir $(TOP_DIR)) | cut -d '/' -f2 | tr -d '[:space:]' | cut -d '_' -f2)
else
	# $(DISTRO)_base | cclhsu
	DOCKER_REGISTRY=alpine_base/
	# <DISTRO>_helloworld | $(notdir $(TOP_DIR)) | helloworld
	DOCKER_PROJECT=$(notdir $(TOP_DIR))
endif
DOCKER_PROJECT_NAME=$(shell echo $(DOCKER_PROJECT) | cut -d '/' -f2 | tr -d '[:space:]')
# Dockerfile | SDK.Dockerfile | SDKMAN.Dockerfile | Multi-Stages.Dockerfile
DOCKER_FILE=Dockerfile
# docker-compose.yml | docker-compose.yaml
DOCKER_COMPOSE_FILE=docker-compose.yml

# latest | alpine3.14 | 13.3-buster | $(shell grep -i version VERSION.txt | cut -d '=' -f 2 | tr -d '[:space:]')
DOCKER_TAG=latest
# USER_NAME=
# USER_PASSWORD=
# SRC_DIR=
# MOUNT_DIR=
WEBUI_PORT=8080
DAEMON_PORT=3000
DB_NAME=
DB_USER_NAME=
DB_USER_PASSWORD=
DB_PORT=5432
PROJECT_FOLDER=/project
CONF_FOLDER=etc/$(DOCKER_PROJECT)
SRC_FOLDER=src
# TEST_FOLDER=tests
DATA_FOLDER=data
LOG_FOLDER=log
SSH_USER=user
SSH_USER_PASSWORD=pass
HOST_IP=localhost
HOST_PORT=3000
REMOTE_PATH=/home/$(SSH_USER)
LOCAL_PATH=$(TOP_DIR)/tmp

# docker_network | <docker-compose-project>_docker_network | host
# DOCKER_NETWORK=docker_network
# DOCKER_RUN=docker run --rm -d
DOCKER_RUN=docker run --rm -ti
# DOCKER_PARAMETERS=--network host --user $(id -u):$(id -g)
# DOCKER_PARAMETERS=-e USER_NAME=$(USER_NAME) -e USER_PASSWORD=$(USER_PASSWORD) -p $(WEBUI_PORT):$(WEBUI_PORT) -p $(DAEMON_PORT):$(DAEMON_PORT) -v $(SRC_DIR):$(MOUNT_DIR)
# DOCKER_PARAMETERS=-e DB_NAME=$(DB_NAME) -e DB_USER_NAME=$(DB_USER_NAME) -e DB_USER_PASSWORD=$(DB_USER_PASSWORD) -p $(DB_PORT):$(DB_PORT)
# DOCKER_COMMAND=/bin/bash
# DOCKER_COMMAND=entrypoint.sh

# ifneq ("$(wildcard VERSION.txt)", "")
#	 TAG=$(shell grep -i version VERSION.txt | cut -d '=' -f 2 | tr -d '[:space:]')
# else ifdef LATEST
#	 TAG=latest
# else
#	 TAG=latest
# endif

# ifneq ("$(wildcard ${HOME}/.my_libs/$(PROJECT_TYPE)/myenv)", "")
#	 include ${HOME}/.my_libs/$(PROJECT_TYPE)/myenv
# else ifneq ("$(wildcard env)", "")
#	 include env
# else
#	 GITHUB_USER=cclhsu
#	 GITHUB_USER_PASSWORD=
#	 GITHUB_USER_TOKEN=
#	 GITHUB_USER_EMAIL=cclhsu@yahoo.com
#	 DOCKER_USER=cclhsu
#	 DOCKER_PASSWORD=
# endif

DISTRO ?= $(shell cat /etc/*-release 2>/dev/null | uniq -u | grep ^ID= | cut -d = -f 2 | sed s/\"//g | sed s/linux/-linux/g && sw_vers -productName 2>/dev/null | sed 's/ //g' | tr A-Z a-z)
OS ?= $(shell uname -s | tr A-Z a-z)
ARCH ?= $(shell uname -m | sed -e 's/x86_64/amd64/' -e 's/aarch64/arm64/')

GITHUB_USER=
GITHUB_PROJECT=
GIT_COMMIT:=$(shell git rev-parse --short HEAD 2>/dev/null)-$(shell date "+%Y%m%d%H%M%S")
GIT_TAG:=$(shell git describe --tags --dirty 2>/dev/null)

# https://github.com/${GITHUB_USER}/${GITHUB_PROJECT}/releases
ifneq ("$(wildcard VERSION.txt)", "")
	 PACKAGE_VERSION=$(shell grep -i PACKAGE_VERSION VERSION.txt | cut -d '=' -f 2 | tr -d '[:space:]')
else ifdef LATEST
	 PACKAGE_VERSION=latest
else
	 PACKAGE_VERSION ?= $(shell curl -s "https://api.github.com/repos/${GITHUB_USER}/${GITHUB_PROJECT}/releases/latest" | jq --raw-output .tag_name)
endif

##### INTERNAL VARIABLES #####
# Read all subsequent tasks as arguments of the first task
RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(args) $(RUN_ARGS):;@:)

##### ##### #####

.DEFAULT_GOAL := help

.PHONY: help
help:  ## help
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> help...\n"
	@#make -rpn | sed -n -e '/^$$/ { n ; /^[^ .#][^ ]*:/ { s/:.*$$// ; p ; } ; }' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo -e "\n======================================================================\n"

.PHONY: all
all:  ## all
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> ...\n"
	make clean
	make build
	make status
	@# make version
	@echo -e "\n======================================================================\n"

##### TASKS #####

.PHONY: $(TARGETS)
$(TARGETS):  ## TARGETS
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> targets...\n"
	@ ls -p scripts | grep -v / | xargs -I {} chmod +x scripts/{}
	@ ./scripts/$@
	@echo -e "\n======================================================================\n"

.PHONY: func_list
func_list:
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> targets...\n"
	for TARGET in $(TARGETS); do \
		echo $$TARGET; \
	done
	@echo -e "\n======================================================================\n"

.PHONY: env
env:  ## env
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> env...\n"
	@echo -e "\n======================================================================\n"

.PHONY: clean
clean:  ## clean
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> clean...\n"
	docker rm -f $(DOCKER_PROJECT) 2>/dev/null; true
	docker rmi $(DOCKER_REGISTRY)$(DOCKER_PROJECT):$(DOCKER_TAG) 2>/dev/null; true
	docker rm $(shell docker ps -a -q) 2>/dev/null; true
	docker rmi $(shell docker images -f "dangling=true" -q) 2>/dev/null; true
	docker volume prune --force 2>/dev/null; true
	rm -rf tmp
	@# sudo rm -rf ${SRC_DIR}
	@# find "$(TOP_DIR)" -type f -name "*.log" -print -delete;
	@# find "$(TOP_DIR)" -type f -name "*.pyc" -print -delete;
	@# find "$(TOP_DIR)" -type f -name "*.pid" -print -delete;
	@echo -e "\n======================================================================\n"

.PHONY: lint
lint:  ## lint
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> lint...\n"
	@echo -e "\n======================================================================\n"

.PHONY: build
build:  ## build
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> build...\n"
	@# make clean
	@# docker build -f $(DOCKER_FILE) -t $(DOCKER_REGISTRY)$(DOCKER_PROJECT):$(DOCKER_TAG) .
	docker build --rm -f $(DOCKER_FILE) -t $(DOCKER_REGISTRY)$(DOCKER_PROJECT):$(DOCKER_TAG) .
	docker rmi $(shell docker images -f "dangling=true" -q) 2>/dev/null; true
	@echo -e "\n======================================================================\n"

.PHONY: nocache
nocache:  ## nocache
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> nocache...\n"
	@# make clean
	@# docker build -f $(DOCKER_FILE) -t $(DOCKER_REGISTRY)$(DOCKER_PROJECT):$(DOCKER_TAG) --no-cache .
	docker build --rm -f $(DOCKER_FILE) -t $(DOCKER_REGISTRY)$(DOCKER_PROJECT):$(DOCKER_TAG) --no-cache .
	docker rmi $(shell docker images -f "dangling=true" -q) 2>/dev/null; true
	@echo -e "\n======================================================================\n"

.PHONY: pull
pull:  ## pull
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> pull...\n"
	docker pull $(DOCKER_REGISTRY)$(DOCKER_PROJECT):$(DOCKER_TAG)
	@echo -e "\n======================================================================\n"

.PHONY: push
push:  ## push
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> push...\n"
	docker push $(DOCKER_REGISTRY)$(DOCKER_PROJECT):$(DOCKER_TAG)
	@echo -e "\n======================================================================\n"

.PHONY: run
run:  ## run
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> run...\n"
	$(DOCKER_RUN) $(DOCKER_PARAMETERS) --name $(DOCKER_PROJECT_NAME) $(DOCKER_REGISTRY)$(DOCKER_PROJECT):$(DOCKER_TAG) $(DOCKER_COMMAND)
	@echo -e "\n======================================================================\n"

.PHONY: test
test:  ## test
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> test...\n"
	$(DOCKER_RUN) $(DOCKER_PARAMETERS) --name $(DOCKER_PROJECT_NAME) $(DOCKER_REGISTRY)$(DOCKER_PROJECT):$(DOCKER_TAG) $(DOCKER_COMMAND)
	@echo -e "\n======================================================================\n"

.PHONY: stop
stop:  ## stop
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> stop...\n"
	docker stop $(DOCKER_PROJECT_NAME); true
	docker rm -f $(DOCKER_PROJECT_NAME) 2>/dev/null; true
	docker volume prune --force 2>/dev/null; true
	rm -rf tmp
	sudo rm -rf ${DATA_FOLDER}
	@echo -e "\n======================================================================\n"

.PHONY: logs
logs:  ## logs
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> logs...\n"
	docker logs $(DOCKER_PROJECT_NAME)
	@echo -e "\n======================================================================\n"

.PHONY: bash_container
bash_container:  ## bash_container
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> bash_container...\n"
	bash -c "clear && docker exec -it $(DOCKER_PROJECT_NAME) /bin/sh"
	@echo -e "\n======================================================================\n"

.PHONY: bash
bash:  ## bash
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> bash...\n"
	@# $(COMMAND) /bin/bash
	$(DOCKER_RUN) --entrypoint "" $(DOCKER_PARAMETERS) -h $(DOCKER_PROJECT_NAME) --name $(DOCKER_PROJECT_NAME) $(DOCKER_REGISTRY)$(DOCKER_PROJECT):$(DOCKER_TAG) /bin/bash
	@echo -e "\n======================================================================\n"

.PHONY: cp_default_config
cp_default_config:
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> ...\n"
	rm -rf defaultfs
	mkdir -p defaultfs/etc/
	docker cp $(DOCKER_PROJECT_NAME):/etc/$(APP) defaultfs/etc/$(APP) 2>/dev/null; true
	docker cp $(DOCKER_PROJECT_NAME):/etc/$(APP).conf defaultfs/etc/$(APP).conf 2>/dev/null; true
	@# mkdir -p defaultfs/etc/conf.d
	@# docker cp $(DOCKER_PROJECT_NAME):/etc/conf.d/$(APP) defaultfs/etc/conf.d/$(APP) 2>/dev/null; true
	@# mkdir -p defaultfs/etc/init.d
	@# docker cp $(DOCKER_PROJECT_NAME):/etc/init.d/$(APP) defaultfs/etc/init.d/$(APP) 2>/dev/null; true
	@# mkdir -p defaultfs/etc/logrotate.d
	@# docker cp $(DOCKER_PROJECT_NAME):/etc/logrotate.d/$(APP) defaultfs/etc/logrotate.d/$(APP) 2>/dev/null; true
	@# mkdir -p defaultfs/etc/sysconfig/
	@# docker cp $(DOCKER_PROJECT_NAME):/etc/sysconfig/$(APP) defaultfs/etc/sysconfig/$(APP) 2>/dev/null; true
	@# mkdir -p defaultfs/etc/ssl
	@# docker cp $(DOCKER_PROJECT_NAME):/etc/ssl/$(APP) defaultfs/etc/ssl/$(APP) 2>/dev/null; true
	@# mkdir -p defaultfs/etc/pki
	@# docker cp $(DOCKER_PROJECT_NAME):/etc/pki/$(APP) defaultfs/etc/pki/$(APP) 2>/dev/null; true
	@# mkdir -p defaultfs/usr/share/
	@# docker cp $(DOCKER_PROJECT_NAME):/usr/share/$(APP) defaultfs/usr/share/$(APP) 2>/dev/null; true
	@# mkdir -p defaultfs/var/www/
	@# docker cp $(DOCKER_PROJECT_NAME):/var/www/html defaultfs/var/www/html 2>/dev/null; true
	@echo -e "\n======================================================================\n"

.PHONY: stop_all
stop_all:
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> ...\n"
	docker stop $(shell docker ps -a -q) 2>/dev/null; true
	docker volume prune --force 2>/dev/null; true
	@echo -e "\n======================================================================\n"

.PHONY: status
status:  ## status
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> status...\n"
	@echo -e "\n>>> $(TOP_DIR)..."
	@echo -e "\n>>> $(GITHUB_USER)/$(GITHUB_PROJECT)/$(PACKAGE_VERSION)..."
	@echo -e "\n>>> $(DISTRO)/$(OS)/$(ARCH)..."
	docker ps -a && echo
	docker volume ls && echo
	docker images && echo
	@echo -e "\n======================================================================\n"

.PHONY: version
version:  ## version
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> version...\n"
	@# make clean
	@echo -e "\n======================================================================\n"
*EOF*

# .PHONY: curl
# curl:  ## curl
#	  @echo -e "\n======================================================================\n"
#	  @echo -e "\n>>> curl...\n"
#	  @# curl -x 0.0.0.0:3128 -L http://www.google.com/
#	  curl -OL http://localhost:${PORT}
#	  @echo -e "\n======================================================================\n"

# .PHONY: browser
# browser:  ## browser
#	  @echo -e "\n======================================================================\n"
#	  @echo -e "\n>>> browser...\n"
#	  open http://localhost:${PORT}/
#	  @echo -e "\n======================================================================\n"

.PHONY: compose_up
compose_up:  ## compose_up
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> compose_up...\n"
	docker-compose -f $(DOCKER_COMPOSE_FILE) up
	@echo -e "\n======================================================================\n"

.PHONY: compose_down
compose_down:  ## compose_down
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> compose_down...\n"
	docker-compose -f $(DOCKER_COMPOSE_FILE) down
	@echo -e "\n======================================================================\n"

.PHONY: compose_start
compose_start:  ## compose_start
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> compose_start...\n"
	docker-compose -f $(DOCKER_COMPOSE_FILE) start
	@echo -e "\n======================================================================\n"

.PHONY: compose_stop
compose_stop:  ## compose_stop
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> compose_stop...\n"
	docker-compose -f $(DOCKER_COMPOSE_FILE) stop
	@echo -e "\n======================================================================\n"

.PHONY: compose_ps
compose_ps:  ## compose_ps
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> compose_ps...\n"
	docker-compose -f $(DOCKER_COMPOSE_FILE) ps
	@echo -e "\n======================================================================\n"
