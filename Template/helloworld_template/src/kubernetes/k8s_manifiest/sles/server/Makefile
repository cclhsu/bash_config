# https://www.gnu.org/software/make/manual/make.html
# https://www.gnu.org/software/make/manual/html_node/Simple-Makefile.html
# $(DISTRO)_base | cclhsu
BASE=osle_base
# TOP_DIR=$(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
TOP_DIR=$(shell dirname $(abspath $(firstword $(MAKEFILE_LIST))))
# PROJECT=$(notdir $(TOP_DIR))
PROJECT=helloworld-server

# ifneq ("$(wildcard VERSION.txt)", "")
#	TAG=$(shell grep -i version VERSION.txt | cut -d '=' -f 2 | tr -d '[:space:]')
#	OFFICIAL_TAG=latest
# else ifdef LATEST
#	TAG=latest
#	OFFICIAL_TAG=latest
# else
#	TAG=latest
#	OFFICIAL_TAG=latest
# endif

COMMAND=

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

# NAMESPACE="--all-namespaces"
# NAMESPACE="--namespace=kube-system"
NAMESPACE="--namespace=default"

DEPLOYMENT_NAME=helloworld-server
APP_NAME=helloworld-server
POD_NAME=$(shell kubectl get pods -l app=$(DOCKER_PROJECT_NAME) $(NAMESPACE) -o jsonpath='{range .items[*]}{.metadata.name}')

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
all:
	make clean

.PHONY: clean
clean:
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> ...\n"
	@echo -e "\n======================================================================\n"

.PHONY: deploy
deploy:
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> deploying...\n"
	@# kubectl create namespace logging
	kubectl create -f service-account.yaml
	kubectl create -f cluster-role.yaml
	kubectl create -f cluster-role-binding.yaml
	kubectl create -f configmap.yaml
	kubectl create -f secret.yaml
	@# kubectl create -f pod-security-policy.yaml
	kubectl create -f deployment.yaml
	kubectl create -f service.yaml
	@echo
	kubectl get crd,ns,all,statefulset,endpoints $(NAMESPACE) -o wide
	@echo -e "\n======================================================================\n"

.PHONY: undeploy
undeploy:
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> undeploying...\n"
	kubectl delete -f service.yaml; true
	kubectl delete -f deployment.yaml; true
	@# kubectl delete -f pod-security-policy.yaml; true
	kubectl delete -f secret.yaml; true
	kubectl delete -f configmap.yaml; true
	kubectl delete -f cluster-role-binding.yaml; true
	kubectl delete -f cluster-role.yaml; true
	kubectl delete -f service-account.yaml; true
	@# kubectl delete namespace logging; true
	@echo
	kubectl get crd,ns,all,statefulset,endpoints $(NAMESPACE) -o wide
	@echo -e "\n======================================================================\n"

.PHONY: bash
bash:
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> ...\n"
	bash -c "clear && kubectl exec -it $(POD_NAME) $(NAMESPACE) -- /bin/bash"
	@echo -e "\n======================================================================\n"

.PHONY: top
top:
	@echo -e "\n======================================================================\n"
	@# @echo -e "\n>>> Nodes Request/Limits...\n"
	@# kubectl get nodes --no-headers | awk '{print $1}' | xargs -I {} sh -c 'echo {}; kubectl describe node {} | grep Allocated -A 5 | grep -ve Event -ve Allocated -ve percent -ve -- ; echo'
	@echo -e "\n>>> Top Nodes...\n"
	kubectl top nodes --use-protocol-buffers
	@echo -e "\n>>> Top Pods...\n"
	kubectl top pods --use-protocol-buffers -a
	@# kubectl top pods --use-protocol-buffers $(NAMESPACE)
	@echo -e "\n======================================================================\n"

# .PHONY: version
# version:
#	@echo -e "\n======================================================================\n"
#	@echo
#	@echo -e "\n======================================================================\n"

.PHONY: stat
stat:
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> ...\n"
	kubectl exec -it $(POD_NAME) $(NAMESPACE) -- /bin/bash -c "tail -n 20 /var/log/helloworld-stats.log"
	@echo -e "\n======================================================================\n"

.PHONY: status
status:
	@echo -e "\n======================================================================\n"
	@# kubectl api-resources

	@# @echo -e "\n>>> Get k8s Cluster status...\n"
	@# caaspctl cluster status | true

	@# @echo -e "\n>>> node...\n"
	@# kubectl get nodes -o wide

	@# @echo -e "\n>>> cluster info...\n"
	@# kubectl cluster-info $(NAMESPACE)

	@# @echo -e "\n>>> all...\n"
	@# kubectl get crd,ns,all,statefulset,endpoints $(NAMESPACE) -o wide

	@# @echo -e "\n>>> Namespaces...\n"
	@# kubectl get namespaces $(NAMESPACE)

	@echo -e "\n>>> deployments...\n"
	kubectl get deployments $(NAMESPACE)

	@echo -e "\n>>> daemonsets...\n"
	kubectl get daemonsets $(NAMESPACE)

	@echo -e "\n>>> replicasets...\n"
	kubectl get replicasets $(NAMESPACE)

	@echo -e "\n>>> pods...\n"
	kubectl get pods $(NAMESPACE) -o wide

	@echo -e "\n>>> configmaps...\n"
	kubectl get configmaps $(NAMESPACE)

	@echo -e "\n>>> secrets...\n"
	kubectl get secrets $(NAMESPACE)

	@# @echo -e "\n>>> clusterroles...\n"
	@# kubectl get clusterroles $(NAMESPACE)

	@# @echo -e "\n>>> clusterrolebindings...\n"
	@# kubectl get clusterrolebindings $(NAMESPACE)

	@# @echo -e "\n>>> serviceaccounts...\n"
	@# kubectl get serviceaccounts $(NAMESPACE)

	@echo -e "\n>>> services...\n"
	kubectl get services $(NAMESPACE)

	@# @echo -e "\n>>> gateways...\n"
	@# kubectl get gateways $(NAMESPACE)

	@# @echo -e "\n>>> virtualservices...\n"
	@# kubectl get virtualservices $(NAMESPACE)

	@echo -e "\n>>> podsecuritypolicies...\n"
	kubectl get podsecuritypolicies $(NAMESPACE)

	@echo -e "\n>>> Pod/Node Table...\n"
	@# kubectl get pod -o=custom-columns=NODE:.spec.nodeName,NAME:.metadata.name $(NAMESPACE)
	@# kubectl get pod -o=custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName $(NAMESPACE)
	kubectl get pod -o=custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName $(NAMESPACE) | true
	kubectl get pod -o=custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName helloworld | true

	@echo -e "\n======================================================================\n"

.PHONY: describe
describe:
	@echo -e "\n======================================================================\n"

	@echo -e "\n>>> deployment info:"
	kubectl describe deployment $(DOCKER_PROJECT_NAME) $(NAMESPACE); true

	@echo -e "\n>>> replicaset info:"
	kubectl describe replicaset $(DOCKER_PROJECT_NAME) $(NAMESPACE); true

	@# @echo -e "\n>>> daemonset info:"
	@# kubectl describe daemonset $(DOCKER_PROJECT_NAME) $(NAMESPACE); true

	@echo -e "\n>>> pod info:"
	kubectl describe pod $(POD_NAME) $(NAMESPACE); true

	@echo -e "\n======================================================================\n"

.PHONY: log
log:
	@echo -e "\n======================================================================\n"
	@echo -e "\n>>> pod log:"
	kubectl logs $(POD_NAME) $(NAMESPACE)
	@echo -e "\n======================================================================\n"
