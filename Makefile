# https://www.gnu.org/software/make/manual/make.html
# https://www.gnu.org/software/make/manual/html_node/Simple-Makefile.html
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

##### HOWTO #####


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
update:	 ## update
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> Install ${HOME}/.my_libs/bash"
	cp $(TOP_DIR)/myconfigs_template ${HOME}/.my_libs/bash/myconfigs
	@# cp $(TOP_DIR)/myenv_template ${HOME}/.my_libs/bash/myenv
	cp $(TOP_DIR)/mylib_template ${HOME}/.my_libs/bash/mylib
	cp $(TOP_DIR)/myprojects_template ${HOME}/.my_libs/bash/myprojects
	ls -alh ${HOME}/.my_libs/bash
	@echo -e "\n======================================================================\n"

.PHONY: clean
clean:	## clean
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> Remove ${HOME}/.my_libs/bash"
	rm -f ${HOME}/.my_libs/bash
	@echo -e "\n======================================================================\n"

.PHONY: list
list:  ## list
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
