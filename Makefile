# https://www.gnu.org/software/make/manual/make.html
# https://www.gnu.org/software/make/manual/html_node/Simple-Makefile.html
##### HOWTO #####

##### VARIABLES #####
# bash | cclhsu
BASE=bash
# TOP_DIR=$(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
TOP_DIR=$(shell dirname $(abspath $(firstword $(MAKEFILE_LIST))))
# PROJECT=$(notdir $(TOP_DIR))
PROJECT=config
REPO=$(BASE)/$(DOCKER_PROJECT_NAME)

ifneq ("$(wildcard VERSION.txt)", "")
	TAG=$(shell grep -i version VERSION.txt | cut -d '=' -f 2 | tr -d '[:space:]')
else ifdef LATEST
	TAG=latest
else
	TAG=latest
endif

COMMAND=docker run --rm -ti
# DOCKER_PARAMETERS=

ifneq ("$(wildcard ${HOME}/.my_libs/bash/myenv)", "")
	include ${HOME}/.my_libs/bash/myenv
else ifneq ("$(wildcard env)", "")
	include env
else
	GITHUB_USER=cclhsu
	GITHUB_USER_PASSWORD=
	GITHUB_USER_TOKEN=
	GITHUB_USER_EMAIL=cclhsu@yahoo.com
	DOCKER_USER=cclhsu
	DOCKER_PASSWORD=
endif

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
	@echo -e "\n>>> Help"
	@make -rpn | sed -n -e '/^$$/ { n ; /^[^ .#][^ ]*:/ { s/:.*$$// ; p ; } ; }' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@#grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo -e "\n======================================================================\n"

.PHONY: install
install:  ## install
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> Install ${HOME}/.my_libs/bash"
	mkdir -p ${HOME}/.my_libs/bash
	cp $(TOP_DIR)/myconfigs_template ${HOME}/.my_libs/bash/myconfigs
	cp $(TOP_DIR)/myenv_sample ${HOME}/.my_libs/bash/myenv
	cp $(TOP_DIR)/mysecrets_sample ${HOME}/.my_libs/bash/mysecrets
	cp $(TOP_DIR)/mylib_template ${HOME}/.my_libs/bash/mylib
	cp $(TOP_DIR)/myprojects_template ${HOME}/.my_libs/bash/myprojects
	@# cp $(TOP_DIR)/myenv_template ${HOME}/.my_libs/bash/myenv
	@# cp $(TOP_DIR)/mysecrets_template ${HOME}/.my_libs/bash/mysecrets
	ls -alh ${HOME}/.my_libs/bash
	@echo -e "\n======================================================================\n"

.PHONY: update
update:  ## update
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> Install ${HOME}/.my_libs/bash"
	cp $(TOP_DIR)/myconfigs_template ${HOME}/.my_libs/bash/myconfigs
	@# cp $(TOP_DIR)/myenv_template ${HOME}/.my_libs/bash/myenv
	cp $(TOP_DIR)/mylib_template ${HOME}/.my_libs/bash/mylib
	cp $(TOP_DIR)/myprojects_template ${HOME}/.my_libs/bash/myprojects
	ls -alh ${HOME}/.my_libs/bash
	@echo -e "\n======================================================================\n"

.PHONY: clean
clean:  ## clean
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> Remove ${HOME}/.my_libs/bash"
	rm -f ${HOME}/.my_libs/bash
	@echo -e "\n======================================================================\n"

.PHONY: status
list:  ## status
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> List ${HOME}/.my_libs/bash"
	ls ${HOME}/.my_libs/bash || true
	@echo -e "\n======================================================================\n"

.PHONY: open
open:  ## open
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> Open ${HOME}/.my_libs/bash"
	code ${HOME}/.my_libs/bash || true
	@echo -e "\n======================================================================\n"
