#!/usr/bin/env bash
#******************************************************************************
# Copyright 2020 Clark Hsu
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#******************************************************************************
# How To
# https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#
# https://ansible-tips-and-tricks.readthedocs.io/en/latest/ansible/install/
# https://medium.com/@jackprice/low-risk-package-updates-with-ansible-and-vsphere-63f758c6b76a
# https://software.opensuse.org/download.html?project=systemsmanagement&package=ansible
# https://snapcraft.io/install/ansible-ryanjyoder/opensuse
# 'ansible all -m package -a 'name=* state=latest'`

#******************************************************************************
# Mark Off this section if use as lib

PROGRAM_NAME=$(basename "${0}")
AUTHOR=clark_hsu
VERSION=0.0.1

#******************************************************************************
echo -e "\n================================================================================\n"
#echo "Begin: $(basename "${0}")"
#set -e # Exit on error On
#set -x # Trace On
#******************************************************************************
# Load Configuration

echo -e "\n>>> Load Configuration...\n"
TOP_DIR=$(cd "$(dirname "${0}")" && pwd)
# shellcheck source=/dev/null
source "${HOME}/.my_libs/bash/mysecrets"
# shellcheck source=/dev/null
source "${HOME}/.my_libs/bash/myconfigs"
# source "${HOME}/.my_libs/bash/repo/source_basic.sh"
# shellcheck source=/dev/null
source "${HOME}/.my_libs/bash/repo/source.sh"
# TOP_DIR=${CLOUD_MOUNT_PATH}
# TOP_DIR=${CLOUD_REPLICA_PATH}
# TOP_DIR=${DOCUMENTS_PATH}
# source "${TOP_DIR:?}/_common_lib.sh"
# source "${TOP_DIR:?}/setup.conf"
echo "${PASSWORD}" | sudo -S echo ""
if [ "${OPTION}" == "" ]; then
    OPTION="${1}"
fi

#******************************************************************************
# Conditions Check and Init

# check_if_root_user
detect_package_system
set_alias_by_distribution # ${DISTRO}
PROJECT_TYPE=ansible_app  # ansible_app bash_app bash_create_project_app bash_deployment_app bash_install_app bash_remote_deployment_app docker_app helm_app helm3_app minifest_app deployment_app terraform_app

#******************************************************************************
# Usage & Version

usage() {
    cat <<EOF

Usage: ${0} -a <ACTION> [-o <OPTION>]

This script is to <DO ACTION>.

OPTIONS:
    -h | --help             Usage
    -v | --version          Version
    -a | --action           Action [create_project_skeleton | clean_project |
                                    start_runtime | stop_runtime |
                                    deploy_infrastructure | undeploy_infrastructure | install_infrastructure_requirements | uninstall_infrastructure_requirements |
                                    install | update | upgrade | dist-upgrade | uninstall |
                                    configure | remove_configurations |
                                    enable | start | stop | disable |
                                    deploy | undeploy | upgrade | backup | restore |
                                    show_infrastructure_status | show_k8s_status | show_app_status |
                                    access_service | access_service_by_proxy | ssh_to_node |
                                    status | get_version | lint | build]

EOF
    exit 1
}

version() {
    cat <<EOF

Program: ${PROGRAM_NAME}
Author: ${AUTHOR}
Version: ${VERSION}

EOF
    exit 1
}

#******************************************************************************
# Command Line Parameters

while [[ "$#" -gt 0 ]]; do
    OPTION="${1}"
    case ${OPTION} in
        -h | --help)
            usage
            ;;
        -v | --version)
            version
            ;;
        -a | --action)
            ACTION="${2}"
            shift
            ;;
        -hd | --distro)
            DISTRO="${2}"
            shift
            ;;
        -o | --os)
            OS="${2}"
            shift
            ;;
        -a | --arch)
            ARCH="${2}"
            shift
            ;;
        -p | --platform)
            PLATFORM="${2}"
            shift
            ;;
        -pd | --platform_distro)
            PLATFORM_DISTRO="${2}"
            shift
            ;;
        -m | --install_method)
            INSTALL_METHOD="${2}"
            shift
            ;;
        -s | --source_directory)
            SRC_DIR="${2}"
            shift
            ;;
        -d | --destination_directory)
            DEST_DIR="${2}"
            shift
            ;;
        *)
            # Others / Unknown Option
            #usage
            ;;
    esac
    shift # past argument or value
done

if [ "${ACTION}" != "" ]; then
    case ${ACTION} in
        a | b | c) ;;
        create_project_skeleton | clean_project) ;;
        start_runtime | stop_runtime) ;;
        deploy_infrastructure | undeploy_infrastructure | install_infrastructure_requirements | uninstall_infrastructure_requirements) ;;
        install | update | upgrade | dist-upgrade | uninstall) ;;
        configure | remove_configurations) ;;
        enable | start | stop | disable) ;;
        deploy | undeploy | upgrade | backup | restore) ;;
        show_infrastructure_status | show_k8s_status | show_app_status) ;;
        access_service | access_service_by_proxy | ssh_to_node) ;;
        status | get_version | lint | build) ;;

        *)
            usage
            ;;
    esac
#else
#    usage
fi

#******************************************************************************
# Functions

# function function_01() {
#     if [ "$#" != "1" ]; then
#         log_e "Usage: ${FUNCNAME[0]} <ARGS>"
#         log_e "${FUNCNAME[0]} $# ${*}"
#     else
#         log_m "${FUNCNAME[0]} $# ${*}"
#         # cd "${TOP_DIR:?}" || exit 1
#     fi
# }

function deploy_infrastructure() {
    if [ "$#" != "3" ]; then
        log_e "Usage: ${FUNCNAME[0]} <INFRASTRUCTURE_DEPLOYMENT_PROJECT_TOP_DIR> <PLATFORM> <PLATFORM_DISTRO>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        cd "${INFRASTRUCTURE_DEPLOYMENT_PROJECT_TOP_DIR}" || exit 1
        # make install
        # make deploy
        # PLATFORM=libvirt
        # OS=sles
        ./cmd.sh -a install ---platform ${PLATFORM} --platform_distro ${PLATFORM_DISTRO}
        ./cmd.sh -a deploy_infrastructure ---platform ${PLATFORM} --platform_distro ${PLATFORM_DISTRO}
    fi
}

function undeploy_infrastructure() {
    if [ "$#" != "3" ]; then
        log_e "Usage: ${FUNCNAME[0]} <INFRASTRUCTURE_DEPLOYMENT_PROJECT_TOP_DIR> <PLATFORM> <PLATFORM_DISTRO>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        cd "${INFRASTRUCTURE_DEPLOYMENT_PROJECT_TOP_DIR}" || exit 1
        # make undeploy
        # make uninstall
        # PLATFORM=libvirt
        # OS=sles
        ./cmd.sh -a undeploy_infrastructure ---platform ${PLATFORM} --platform_distro ${PLATFORM_DISTRO}
        ./cmd.sh -a uninstall ---platform ${PLATFORM} --platform_distro ${PLATFORM_DISTRO}
        ./cmd.sh -a clean_project ---platform ${PLATFORM} --platform_distro ${PLATFORM_DISTRO}
    fi
}

function set_packages_by_distribution() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        # cd "${TOP_DIR:?}" || exit 1

        if [ "${SRC_DIR}" == "" ]; then
            # SRC_DIR=${HOME}/Documents/myProject
            SRC_DIR=${HOME}/Documents/myProject/Template/helloworld_app
            # SRC_DIR=${HOME}/Documents/myProject/Template/helloworld_template
        fi

        INSTALL_METHOD=pip # bin tar bz2 xz zstd rar zip script snap rpm go npm pip docker podman
        # https://github.com/${GITHUB_USER}/${GITHUB_PROJECT}/releases
        # https://repology.org/projects/?search=${GITHUB_PROJECT}
        PROJECT_BIN=ansible                 # ansible | ansible-ryanjyoder
        PROJECT_BIN_RUN_PARAMETERS=         #
        SYSTEMD_SERVICE_NAME=${PROJECT_BIN} #
        GITHUB_USER=ansible                 #
        GITHUB_FORK_USER=                   #
        GITHUB_PROJECT=${PROJECT_BIN}       #
        # https://github.com/${GITHUB_USER}/${GITHUB_PROJECT}/releases
        PACKAGE_VERSION=$(curl -s "https://api.github.com/repos/${GITHUB_USER}/${GITHUB_PROJECT}/releases/latest" | jq --raw-output .tag_name)
        echo ">>> Package: ${DISTRO}/${GITHUB_USER}/${GITHUB_PROJECT}/${PACKAGE_VERSION}/${PROJECT_BIN}-${OS}-${ARCH}"

        case ${DISTRO} in
            alpine)
                # https://pkgs.alpinelinux.org/packages
                PACKAGES_KEY_URL=
                PACKAGES_REPO_NAME=
                PACKAGES_REPO_URL=
                PACKAGES="${PROJECT_BIN}"
                REQUIRED_PACKAGES_KEY_URL=
                REQUIRED_PACKAGES_REPO_NAME=
                REQUIRED_PACKAGES_REPO_URL=
                REQUIRED_PACKAGES=
                PLUGIN_PACKAGES_KEY_URL=
                PLUGIN_PACKAGES_REPO_NAME=
                PLUGIN_PACKAGES_REPO_URL=
                PLUGIN_PACKAGES=
                ;;
            centos | fedora | rhel | oracle-linux | alma-linux | rocky-linux)
                # https://pkgs.org/
                # https://rpmfind.net/linux/RPM/index.html
                PACKAGES_KEY_URL=
                PACKAGES_REPO_NAME=
                PACKAGES_REPO_URL=
                PACKAGES="${PROJECT_BIN}"
                REQUIRED_PACKAGES_KEY_URL=
                REQUIRED_PACKAGES_REPO_NAME=
                REQUIRED_PACKAGES_REPO_URL=
                REQUIRED_PACKAGES=
                PLUGIN_PACKAGES_KEY_URL=
                PLUGIN_PACKAGES_REPO_NAME=
                PLUGIN_PACKAGES_REPO_URL=
                PLUGIN_PACKAGES=
                ;;
            cirros)
                PACKAGES_KEY_URL=
                PACKAGES_REPO_NAME=
                PACKAGES_REPO_URL=
                PACKAGES="${PROJECT_BIN}"
                REQUIRED_PACKAGES_KEY_URL=
                REQUIRED_PACKAGES_REPO_NAME=
                REQUIRED_PACKAGES_REPO_URL=
                REQUIRED_PACKAGES=
                PLUGIN_PACKAGES_KEY_URL=
                PLUGIN_PACKAGES_REPO_NAME=
                PLUGIN_PACKAGES_REPO_URL=
                PLUGIN_PACKAGES=
                ;;
            debian | raspios | ubuntu)
                # https://www.debian.org/distrib/packages
                # https://packages.ubuntu.com/
                PACKAGES_KEY_URL=
                PACKAGES_REPO_NAME=
                PACKAGES_REPO_URL=
                PACKAGES="${PROJECT_BIN}"
                REQUIRED_PACKAGES_KEY_URL=
                REQUIRED_PACKAGES_REPO_NAME=
                REQUIRED_PACKAGES_REPO_URL=
                REQUIRED_PACKAGES=
                PLUGIN_PACKAGES_KEY_URL=
                PLUGIN_PACKAGES_REPO_NAME=
                PLUGIN_PACKAGES_REPO_URL=
                PLUGIN_PACKAGES=
                ;;
            opensuse-leap | opensuse-tumbleweed | sles)
                # https://software.opensuse.org/find
                PACKAGES_KEY_URL=
                PACKAGES_REPO_NAME="systemsmanagement"
                PACKAGES_REPO_URL="https://download.opensuse.org/repositories/systemsmanagement/SLE_15_SP3/systemsmanagement.repo"
                PACKAGES="${PROJECT_BIN}"
                REQUIRED_PACKAGES_KEY_URL=
                REQUIRED_PACKAGES_REPO_NAME=
                REQUIRED_PACKAGES_REPO_URL=
                REQUIRED_PACKAGES=
                PLUGIN_PACKAGES_KEY_URL=
                PLUGIN_PACKAGES_REPO_NAME=
                PLUGIN_PACKAGES_REPO_URL=
                PLUGIN_PACKAGES=
                ;;
            macos | macosx)
                # https://formulae.brew.sh/
                # https://formulae.brew.sh/cask/
                CASK=false
                [[ ${CASK} == true ]] && set_alias_by_distribution
                PACKAGES_KEY_URL=
                PACKAGES_REPO_NAME=
                PACKAGES_REPO_URL=
                PACKAGES="${PROJECT_BIN}"
                REQUIRED_PACKAGES_KEY_URL=
                REQUIRED_PACKAGES_REPO_NAME=
                REQUIRED_PACKAGES_REPO_URL=
                REQUIRED_PACKAGES=
                PLUGIN_PACKAGES_KEY_URL=
                PLUGIN_PACKAGES_REPO_NAME=
                PLUGIN_PACKAGES_REPO_URL=
                PLUGIN_PACKAGES=
                ;;
            microsoft)
                PACKAGES_KEY_URL=
                PACKAGES_REPO_NAME=
                PACKAGES_REPO_URL=
                PACKAGES="${PROJECT_BIN}"
                REQUIRED_PACKAGES_KEY_URL=
                REQUIRED_PACKAGES_REPO_NAME=
                REQUIRED_PACKAGES_REPO_URL=
                REQUIRED_PACKAGES=
                PLUGIN_PACKAGES_KEY_URL=
                PLUGIN_PACKAGES_REPO_NAME=
                PLUGIN_PACKAGES_REPO_URL=
                PLUGIN_PACKAGES=
                ;;
            *) ;;
        esac

        PROJECT_BIN_URL=      # "https://github.com/${GITHUB_USER}/${GITHUB_PROJECT}/releases/download/${PACKAGE_VERSION}/${PROJECT_BIN}_${OS}-${ARCH}"
        PROJECT_TAR_URL=      # "https://github.com/${GITHUB_USER}/${GITHUB_PROJECT}/releases/download/${PACKAGE_VERSION}/${PROJECT_BIN}-${PACKAGE_VERSION}-${OS}-${ARCH}.tar.gz"
        PROJECT_BZ2_URL=      # "https://github.com/${GITHUB_USER}/${GITHUB_PROJECT}/releases/download/${PACKAGE_VERSION}/${PROJECT_BIN}-${PACKAGE_VERSION}-${OS}-${ARCH}.bz2"
        PROJECT_XZ_URL=       # "https://github.com/${GITHUB_USER}/${GITHUB_PROJECT}/releases/download/${PACKAGE_VERSION}/${PROJECT_BIN}-${PACKAGE_VERSION}-${OS}-${ARCH}.xz"
        PROJECT_ZSTD_URL=     # "https://github.com/${GITHUB_USER}/${GITHUB_PROJECT}/releases/download/${PACKAGE_VERSION}/${PROJECT_BIN}-${PACKAGE_VERSION}-${OS}-${ARCH}.zst"
        PROJECT_RAR_URL=      # "https://github.com/${GITHUB_USER}/${GITHUB_PROJECT}/releases/download/${PACKAGE_VERSION}/${PROJECT_BIN}-${PACKAGE_VERSION}-${OS}-${ARCH}.rar"
        PROJECT_ZIP_URL=      # "https://github.com/${GITHUB_USER}/${GITHUB_PROJECT}/releases/download/${PACKAGE_VERSION}/${PROJECT_BIN}-${PACKAGE_VERSION}-${OS}-${ARCH}.zip"
        INSTALL_SCRIPT_URL=   # "https://get.${GITHUB_PROJECT}.io" | "https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_PROJECT}/master/bin/install.sh"
        PKILL_SCRIPT_URL=     # "https://get.${GITHUB_PROJECT}.io" | "https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_PROJECT}/master/bin/pkillall.sh"
        UNINSTALL_SCRIPT_URL= # "https://get.${GITHUB_PROJECT}.io" | "https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_PROJECT}/master/bin/uninstall.sh"
        INSTALL_SCRIPT_RUN_PARAMETERS=
        UNINSTALL_SCRIPT_RUN_PARAMETERS=
        # https://github.com/${GITHUB_USER}/${GITHUB_PROJECT}/releases
        PROJECT_GO_URL="github.com/${GITHUB_USER}/${GITHUB_PROJECT}/cmd/${PROJECT_BIN}"
        PROJECT_GO_BIN=${PROJECT_BIN}
        PROJECT_GO_BIN_RUN_PARAMETERS=
        # https://github.com/${GITHUB_USER}/${GITHUB_PROJECT}/releases
        PROJECT_NPM_BIN=${PROJECT_BIN} # @types/${PROJECT_BIN} ${PROJECT_BIN}-cli
        PROJECT_NPM_GLOBAL=true
        PROJECT_NPM_CUSTOMIZE=false
        PROJECT_NPM_BIN_RUN_PARAMETERS_RUN_PARAMETERS=
        # https://github.com/${GITHUB_USER}/${GITHUB_PROJECT}/releases
        PROJECT_PYTHON_PACKAGES="ansible ansible-base ansible-lint pytest pytest-cov pexpect PyYAML molecule molecule[docker] molecule[lint] paramiko argcomplete jinja2 netaddr"
        PROJECT_PYTHON_BIN=${PROJECT_BIN}
        PROJECT_PYTHON_BIN_RUN_PARAMETERS_RUN_PARAMETERS=
        # https://github.com/${GITHUB_USER}/${GITHUB_PROJECT}/releases
        DOCKER_REGISTRY=
        DOCKER_USER=${GITHUB_USER}
        DOCKER_PROJECT=${GITHUB_PROJECT}
        DOCKER_TAG=latest # latest | latest-alpine | v0.0.1 | $(cd ${HOME}/src/github.com/${GITHUB_USER}/${GITHUB_PROJECT}; git log --pretty=format:'%h' -n 1 | cat) | $(cd ${HOME}/src/github.com/${GITHUB_USER}/${GITHUB_PROJECT}; git describe --match 'v[0-9]*' --dirty='-dirty' --always | cat)
        OFFICIAL_DOCKER_REGISTRY=
        OFFICIAL_DOCKER_USER=
        OFFICIAL_DOCKER_PROJECT=
        OFFICIAL_DOCKER_TAG=latest
        DOCKER_PARAMETERS=
        DOCKER_COMMAND=${PROJECT_BIN}
        DOCKER_DETACHED=false

        EXTENSION= # a | b
    fi
}

function set_deployment_settings() {
    if [ "$#" != "0" ] && [ "$#" != "7" ]; then
        log_e "Usage: ${FUNCNAME[0]} [<LOCATION> <PLATFORM> <PLATFORM_DISTRO>  <KUBERNETES_DISTRO> <RUNTIME> <SSH_USER> <SSH_GROUP>]"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        # cd "${TOP_DIR:?}" || exit 1

        if [ "$#" == "7" ]; then
            LOCATION="${1}"
            PLATFORM="${2}"
            PLATFORM_DISTRO="${3}"
            KUBERNETES_DISTRO="${4}"
            RUNTIME="${5}"
            SSH_USER="${6}"
            SSH_GROUP="${7}"
            SSH_USER_PASSWORD= # linux
            SSH_USER_PEM=
        else
            LOCATION=${LOCATION:-remote}
            PLATFORM=${PLATFORM:-libvirt}
            PLATFORM_DISTRO=${PLATFORM_DISTRO:-centos}  # centos | ubuntu | mos
            KUBERNETES_DISTRO=${KUBERNETES_DISTRO:-k3s} # k3s | rke2
            RUNTIME=${RUNTIME:-daemon}
            SSH_USER=${PLATFORM_DISTRO}         # centos | ubuntu | mos
            SSH_GROUP=${SSH_GROUP:-remotes_env} # remotes | remotes_env | remotes_mos
            SSH_USER_PASSWORD=                  # linux
            SSH_USER_PEM=
        fi
        echo ">>> SSH_USER/SSH_PASSWORD/SSH_USER_PEM: ${SSH_USER}/${SSH_PASSWORD}/${SSH_USER_PEM}"
        echo ">>> Location/Platform/Distribution/Runtime: ${LOCATION}/${PLATFORM}/${PLATFORM_DISTRO}/${RUNTIME}"

        INFRASTRUCTURE_DEPLOYMENT_PROJECT=terraform_env                                                                                                  # terraform_env | terraform_mos
        INFRASTRUCTURE_DEPLOYMENT_PROJECT_TOP_DIR="${HOME}/Documents/myProject/Development/terraform/src/terraform/${INFRASTRUCTURE_DEPLOYMENT_PROJECT}" # ${TOP_DIR:?} | ${HOME}/Documents/myProject/Development/terraform/src/terraform/${INFRASTRUCTURE_DEPLOYMENT_PROJECT}
        DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR=${INFRASTRUCTURE_DEPLOYMENT_PROJECT_TOP_DIR}/providers/${PLATFORM}/${PLATFORM_DISTRO}
        CONFIGURATION_MANAGEMENT_TOP_DIR=${TOP_DIR:?} # ${TOP_DIR:?}/inventories/${PLATFORM}/${PLATFORM_DISTRO}
        REMOTE_CONFIGURATION_MANAGEMENT_TOP_DIR=/home/${SSH_USER}/inventories/${PLATFORM}/${PLATFORM_DISTRO}
        mkdir -p "${INFRASTRUCTURE_DEPLOYMENT_PROJECT_TOP_DIR}"
        mkdir -p "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}"
        mkdir -p "${CONFIGURATION_MANAGEMENT_TOP_DIR}"
        echo ">>> INFRASTRUCTURE_DEPLOYMENT_PROJECT_TOP_DIR=${INFRASTRUCTURE_DEPLOYMENT_PROJECT_TOP_DIR}"
        echo ">>> DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR=${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}"
        echo ">>> CONFIGURATION_MANAGEMENT_TOP_DIR=${CONFIGURATION_MANAGEMENT_TOP_DIR}"
        echo ">>> REMOTE_CONFIGURATION_MANAGEMENT_TOP_DIR=${REMOTE_CONFIGURATION_MANAGEMENT_TOP_DIR}"
        STACK_NAME=mos # env | mos | my-cluster
        echo ">>> STACK_NAME=${STACK_NAME}"
        # NEW_ROLE=
        # echo ">>> NEW_ROLE=${NEW_ROLE}"
        # CRI= # crio docker containerd
        # CNI= # calico cilium contiv-vpp flannel kube-router weave-net
        # CSI= # daemon container kubernetes
        # echo ">>> CRI=${CRI}"
        # echo ">>> CNI=${CNI}"
        # echo ">>> CSI=${CSI}"

        RESET_CONFIG=false
        RESET_SCRIPT=true
    fi
}

function configure() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        cd "${TOP_DIR:?}" || exit 1

        case ${PLATFORM} in
            aws | azure | gcp) ;;
            libvirt) ;;
            openstack) ;;
            vmware | vsphere) ;;
            *) ;;
        esac

        case ${DISTRO} in
            alpine) ;;
            alma-linux | arch-linux | chromeos | coreos | gentoo | hyperiotos | oracle-linux | photonos | rocky-linux) ;;
            centos | fedora | rhel | debian | raspios | ubuntu | opensuse-leap | opensuse-tumbleweed | sles) ;;
            rancher-harvester | rancher-k3os | rancher-os) ;;
            cirros) ;;
            macos | macosx) ;;
            microsoft) ;;
            *) ;;
        esac

        case ${PROJECT_TYPE} in
            *) ;;
        esac

        case ${DEPLOYMENT_TYPE} in
            *) ;;
        esac
    fi
}

function remove_configurations() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        cd "${TOP_DIR:?}" || exit 1

        case ${PLATFORM} in
            aws | azure | gcp) ;;
            libvirt) ;;
            openstack) ;;
            vmware | vsphere) ;;
            *) ;;
        esac

        case ${DISTRO} in
            alpine) ;;
            alma-linux | arch-linux | chromeos | coreos | gentoo | hyperiotos | oracle-linux | photonos | rocky-linux) ;;
            centos | fedora | rhel | debian | raspios | ubuntu | opensuse-leap | opensuse-tumbleweed | sles) ;;
            rancher-harvester | rancher-k3os | rancher-os) ;;
            cirros) ;;
            macos | macosx) ;;
            microsoft) ;;
            *) ;;
        esac

        case ${PROJECT_TYPE} in
            *) ;;
        esac

        case ${DEPLOYMENT_TYPE} in
            *) ;;
        esac
    fi
}

function deploy() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        cd "${TOP_DIR:?}" || exit 1

        # ${NEW_ROLE}_install | ${NEW_ROLE}_uninstall | ${NEW_ROLE}_server_install | ${NEW_ROLE}_agent_install | ${NEW_ROLE}_plugins_install
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_install" '{ "hosts": [ "local" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_install" '{ "hosts": [ "remotes" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_install" '{ "hosts": [ "remotes_mos" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_install" '{ "hosts": [ "remotes_env" ] }'
        ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_install" '{ "hosts": [ "centos" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_install" '{ "hosts": [ "debian" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_install" '{ "hosts": [ "fedora" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_install" '{ "hosts": [ "rancher-k3os" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_install" '{ "hosts": [ "rancher-os" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_install" '{ "hosts": [ "opensuse-leap" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_install" '{ "hosts": [ "sles" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_install" '{ "hosts": [ "ubuntu" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_install" '{ "hosts": [ "centos-masters" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_install" '{ "hosts": [ "centos-workers" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_install" '{ "hosts": [ "ubuntu-masters" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_install" '{ "hosts": [ "ubuntu-workers" ] }'
    fi
}

function undeploy() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        cd "${TOP_DIR:?}" || exit 1

        # ${NEW_ROLE}_install | ${NEW_ROLE}_uninstall | ${NEW_ROLE}_server_install | ${NEW_ROLE}_agent_install | ${NEW_ROLE}_plugins_install
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_uninstall" '{ "hosts": [ "local" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_uninstall" '{ "hosts": [ "remotes" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_uninstall" '{ "hosts": [ "remotes_mos" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_uninstall" '{ "hosts": [ "remotes_env" ] }'
        ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_uninstall" '{ "hosts": [ "centos" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_uninstall" '{ "hosts": [ "debian" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_uninstall" '{ "hosts": [ "fedora" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_uninstall" '{ "hosts": [ "rancher-k3os" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_uninstall" '{ "hosts": [ "rancher-os" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_uninstall" '{ "hosts": [ "opensuse-leap" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_uninstall" '{ "hosts": [ "sles" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_uninstall" '{ "hosts": [ "ubuntu" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_uninstall" '{ "hosts": [ "centos-masters" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_uninstall" '{ "hosts": [ "centos-workers" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_uninstall" '{ "hosts": [ "ubuntu-masters" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "${NEW_ROLE}_uninstall" '{ "hosts": [ "ubuntu-workers" ] }'
    fi
}

# https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/
# https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/
function access_service() {
    if [ "$#" != "1" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        cd "${TOP_DIR:?}" || exit 1

    fi
}

function ssh_to() {
    if [ "$#" != "1" ] && [ "$#" != "2" ]; then
        log_e "Usage: ${FUNCNAME[0]} <DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR> [<INSTANCES_TYPE>]"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        # cd "${TOP_DIR:?}" || exit 1

        clear
        cd "${1}" || exit 1
        SSH_USER=$(terraform output username | sed 's/"//g')
        if [ "${SSH_USER}" == "" ]; then
            select_x_from_array "${DISTROS} rancher root ec2-user" "SSH_USER" SSH_USER # mos
        fi

        if [ "$#" == "2" ]; then
            IP_INSTANCES=$(terraform output ${2} | cut -d "=" -f 2 | sed 's/^[ \t]*//' | sed 's/[ \t]*$//' | sed ':a;N;$!ba;s/\n/ /g' | tr -d 'tomap(' | tr -d ')' | tr -d '{' | tr -d '}' | sed 's/^[ \t]*//' | sed 's/[ \t]*$//' | tr -d '"')
            select_x_from_array "${IP_INSTANCES}" "IP" IP
        else
            get_terraform_ips ${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR} ${INFRASTRUCTURE_DEPLOYMENT_PROJECT}
            select_x_from_array "${IPS}" "IP" IP
        fi

        echo "${SSH_USER}" "${IP}"
        ssh_cmd "${SSH_USER}" "${IP}"
    fi
}

function ssh_command() {
    if [ "$#" != "1" ] && [ "$#" != "2" ]; then
        log_e "Usage: ${FUNCNAME[0]} <DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR> [<INSTANCES_TYPE>]"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        # cd "${TOP_DIR:?}" || exit 1

        clear
        cd "${1}" || exit 1
        SSH_USER=$(terraform output username | sed 's/"//g')
        if [ "${SSH_USER}" == "" ]; then
            select_x_from_array "${DISTROS} rancher root ec2-user" "SSH_USER" SSH_USER # "mos"
        fi

        if [ "$#" == "2" ]; then
            IPS=$(terraform output ${2} | cut -d "=" -f 2 | sed 's/^[ \t]*//' | sed 's/[ \t]*$//' | sed ':a;N;$!ba;s/\n/ /g' | tr -d '{' | tr -d '}' | sed 's/^[ \t]*//' | sed 's/[ \t]*$//' | tr -d '"')
        else
            get_terraform_ips ${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR} ${INFRASTRUCTURE_DEPLOYMENT_PROJECT}
        fi

        echo "${SSH_USER}" "${IPS}"
        # local COMMANDS='uname -s; uname -m; echo; cat /etc/*-release | uniq -u; echo; hostnamectl'
        # local COMMANDS='uname -s | tr A-Z a-z;'
        # local COMMANDS='uname -m | sed s/x86_64/amd64/;'
        # local COMMANDS='cat /etc/*-release 2>/dev/null | uniq -u | grep ^ID= | cut -d = -f 2 | sed s/\"//g | sed s/linux/-linux/g;'
        # local COMMANDS='command -v {apk,apt-get,brew,dnf,emerge,pacman,yum,zypper,xbps-install} 2>/dev/null;'
        # local COMMANDS='command -v {apk,dpkg,pkgbuild,rpm} 2>/dev/null;'
        # local COMMANDS='command -v {curl,wget} 2>/dev/null;'
        # local COMMANDS='command -v {tar,unzip} 2>/dev/null;'
        # local COMMANDS='OS=$(uname -s | tr A-Z a-z);ARCH=$(uname -m | sed -e s/x86_64/amd64/ -e s/aarch64/arm64/);DISTRO=$(cat /etc/*-release 2>/dev/null | uniq -u | grep ^ID= | cut -d = -f 2 | sed s/\"//g | sed s/linux/-linux/g);PACKAGE_MANAGER=$(basename $(command -v {apk,apt-get,brew,dnf,emerge,pacman,yum,zypper,xbps-install} 2>/dev/null));PACKAGE_SYSTEM=$(basename $(command -v {apk,dpkg,pkgbuild,rpm} 2>/dev/null));echo "${OS} ${ARCH} ${DISTRO} ${PACKAGE_MANAGER} ${PACKAGE_SYSTEM}"'
        local COMMANDS='. /etc/os-release && echo "${ID} ${VERSION_ID} ${VERSION}"'
        for IP in ${IPS[*]}; do
            # echo -e "\n>>> ${IP}...\n"
            ssh_cmd "${SSH_USER}" "${IP}" "${COMMANDS}"
        done
    fi
}

#******************************************************************************
# Selection Parameters

if [ "${ACTION}" == "" ]; then
    MAIN_OPTIONS="create_project_skeleton clean_project \
        start_runtime stop_runtime \
        deploy_infrastructure undeploy_infrastructure install_infrastructure_requirements uninstall_infrastructure_requirements \
        install update upgrade uninstall \
        configure remove_configurations \
        start stop \
        deploy undeploy upgrade backup restore \
        show_infrastructure_status show_k8s_status show_app_status \
        access_service access_service_by_proxy ssh_to_node \
        status get_version lint build \
        create_role \
        ping facts ansible_distribution ansible_distribution_release ansible_os_family ansible_pkg_mgr \
        ansible_distribution_version ansible_distribution_major_version ansible_update_packages \
        playbook_helloworld playbook_hellorole \
        is_packages_installed \
        ssh_to ssh_to_command \
        ssh_to_alpine ssh_to_centos ssh_to_cirros ssh_to_debian ssh_to_fedora ssh_to_opensuse_leap ssh_to_opensuse_tumbleweed ssh_to_oracle_linux ssh_to_rancher_k3os ssh_to_rancher_os ssh_to_raspios ssh_to_sles ssh_to_ubuntu"

    select_x_from_array "${MAIN_OPTIONS}" "Action" ACTION # "a"
fi

# if [ "${XXX}" == "" ]; then
#     # OPTIONS="a b c"
#     # select_x_from_array "${OPTIONS}" "XXX" XXX # "a"
#     read_and_confirm "XXX MSG" XXX # "XXX set value"
# fi

set_packages_by_distribution
set_deployment_settings # "${LOCATION}" "${PLATFORM}" "${PLATFORM_DISTRO}" "${RUNTIME}" "${SSH_USER}"

if [ "${LOCATION}" == "remote" ]; then
    cd "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}" || exit 1
    case ${ACTION} in
        create_project_skeleton | clean_project) ;;
        start_runtime | stop_runtime) ;;
        deploy_infrastructure | undeploy_infrastructure) ;;
        install | update | upgrade | dist-upgrade | uninstall | enable | start | stop | disable) ;;
        configure | remove_configurations) ;;
        install_infrastructure_requirements | uninstall_infrastructure_requirements | deploy | undeploy | upgrade | backup | restore | status | ssh_to_node)
            get_terraform_ips ${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR} ${INFRASTRUCTURE_DEPLOYMENT_PROJECT}
            ;;
        show_infrastructure_status | show_k8s_status | show_app_status) ;;
        access_service) ;;
        get_version) ;;
        *) ;;
    esac
fi

#******************************************************************************
# Main Program

# update_datetime
# source_rc "${DISTRO}" "${PLATFORM}"
rm -rf "${HOME}/.ssh/known_hosts"
# https://www.ssh.com/ssh/agent
# ssh-agent bash
ssh-add "${HOME}/.ssh/id_rsa"

case ${ACTION} in

    create_project_skeleton)
        create_project_skeleton
        ;;

    clean_project)
        clean_project
        ;;

    deploy_infrastructure)
        deploy_infrastructure "${INFRASTRUCTURE_DEPLOYMENT_PROJECT_TOP_DIR}" "${PLATFORM}" "${PLATFORM_DISTRO}"
        ;;

    undeploy_infrastructure)
        undeploy_infrastructure "${INFRASTRUCTURE_DEPLOYMENT_PROJECT_TOP_DIR}" "${PLATFORM}" "${PLATFORM_DISTRO}"
        ;;

    install_infrastructure_requirements)
        install_infrastructure_requirements # "${PLATFORM}" "${PLATFORM_DISTRO}"
        ;;

    uninstall_infrastructure_requirements)
        uninstall_infrastructure_requirements # "${PLATFORM}" "${PLATFORM_DISTRO}"
        ;;

    install)
        # install_requirements # ${GITHUB_USER} ${GITHUB_PROJECT} ${PACKAGE_VERSION} ${OS} ${ARCH} ${PROJECT_BIN}
        install # ${GITHUB_USER} ${GITHUB_PROJECT} ${PACKAGE_VERSION} ${OS} ${ARCH} ${PROJECT_BIN}
        # install_plugins # ${GITHUB_USER} ${GITHUB_PROJECT} ${PACKAGE_VERSION} ${OS} ${ARCH} ${PROJECT_BIN}
        ;;

    uninstall)
        # uninstall_plugins # ${GITHUB_USER} ${GITHUB_PROJECT} ${PACKAGE_VERSION} ${OS} ${ARCH} ${PROJECT_BIN}
        uninstall # ${GITHUB_USER} ${GITHUB_PROJECT} ${PACKAGE_VERSION} ${OS} ${ARCH} ${PROJECT_BIN}
        # uninstall_requirements # ${GITHUB_USER} ${GITHUB_PROJECT} ${PACKAGE_VERSION} ${OS} ${ARCH} ${PROJECT_BIN}
        ;;

    configure)
        configure
        ;;

    remove_configurations)
        remove_configurations
        ;;

    start)
        start # ${PROJECT_BIN}
        ;;

    stop)
        stop # ${PROJECT_BIN}
        ;;

    deploy)
        deploy
        # status
        ;;

    undeploy)
        undeploy
        # status
        ;;

    upgrade)
        upgrade
        # status
        ;;

    access_service)
        access_service
        ;;

    ssh_to_node)
        select_x_from_array "${IP_MASTERS} ${IP_WORKERS}" "NODE_IP" IP
        ssh_cmd "${SSH_USER}" "${IP}"
        ;;

    status)
        status
        ;;

    get_version)
        get_version # ${PROJECT_BIN}
        ;;

    lint)
        lint # ${PROJECT_BIN}
        ;;

    build)
        build
        ;;

    create_role)
        NEW_ROLE="test" # ${NEW_ROLE} | ${NEW_ROLE}-server | ${NEW_ROLE}-agent
        ROLES="${NEW_ROLE} ${NEW_ROLE}-server ${NEW_ROLE}-agent"
        for ROLE in ${ROLES[*]}; do
            ansible_create_roles "${ROLE}"
            ansible_create_role_tasks_for_main "${ROLE}"
            ansible_create_role_tasks_for_alpine "${ROLE}"
            ansible_create_role_tasks_for_darwin "${ROLE}"
            ansible_create_role_tasks_for_debian "${ROLE}"
            ansible_create_role_tasks_for_redhat "${ROLE}"
            ansible_create_role_tasks_for_suse "${ROLE}"
            ansible_create_role_vars_for_alpines "${ROLE}"
            ansible_create_role_vars_for_darwins "${ROLE}"
            ansible_create_role_vars_for_redhats "${ROLE}"
            ansible_create_role_vars_for_debians "${ROLE}"
            ansible_create_role_vars_for_suses "${ROLE}"
        done
        ;;

    ping)
        ansible_remote_module_action "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "ping"
        ;;

    facts)
        ansible_remote_module_action "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "ansible.builtin.setup"
        ;;

    ansible_distribution)
        # ansible all -m setup -a 'filter=ansible_distribution'
        ansible_remote_module_action "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "setup" 'filter=ansible_distribution'
        ;;

    ansible_distribution_release)
        # ansible all -m setup -a 'filter=ansible_distribution_release'
        ansible_remote_module_action "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "setup" 'filter=ansible_distribution_release'
        ;;

    ansible_os_family)
        # https://docs.ansible.com/ansible/latest/user_guide/playbooks_conditionals.html#ansible-facts-os-family
        # ansible all -m setup -a 'filter=ansible_os_family'
        ansible_remote_module_action "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "setup" 'filter=ansible_os_family'
        ;;

    ansible_pkg_mgr)
        # https://docs.ansible.com/ansible/latest/modules/list_of_packaging_modules.html
        # ansible all -m setup -a 'filter=ansible_pkg_mgr'
        ansible_remote_module_action "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "setup" 'filter=ansible_pkg_mgr'
        ;;

    ansible_distribution_version)
        # ansible all -m setup -a 'filter=ansible_distribution_version'
        ansible_remote_module_action "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "setup" 'filter=ansible_distribution_version'
        ;;

    ansible_distribution_major_version)
        # ansible all -m setup -a 'filter=ansible_distribution_major_version'
        ansible_remote_module_action "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "setup" 'filter=ansible_distribution_major_version'
        ;;

    ansible_update_packages)
        # ansible all -m package -a 'name=* state=latest'
        ansible_remote_module_action "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "package" 'name=* state=latest'
        # ansible_remote_module_action "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "apt" 'name=* state=latest'
        # ansible_remote_module_action "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "yum" 'name=* state=latest'
        # ansible_remote_module_action "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "zypper" 'name=* state=latest'
        ;;

    playbook_helloworld)
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_world" '{ "hosts": [ "local" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_world" '{ "hosts": [ "remotes" ] }'
        ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_world" '{ "hosts": [ "remotes_mos" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_world" '{ "hosts": [ "remotes_env" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_world" '{ "hosts": [ "centos" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_world" '{ "hosts": [ "debian" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_world" '{ "hosts": [ "fedora" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_world" '{ "hosts": [ "rancher-k3os" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_world" '{ "hosts": [ "rancher-os" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_world" '{ "hosts": [ "opensuse-leap" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_world" '{ "hosts": [ "sles" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_world" '{ "hosts": [ "ubuntu" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_world" '{ "hosts": [ "centos-masters" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_world" '{ "hosts": [ "centos-workers" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_world" '{ "hosts": [ "ubuntu-masters" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_world" '{ "hosts": [ "ubuntu-workers" ] }'
        ;;

    playbook_hellorole)
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_role" '{ "hosts": [ "local" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_role" '{ "hosts": [ "remotes" ] }'
        ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_role" '{ "hosts": [ "remotes_mos" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_role" '{ "hosts": [ "remotes_env" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_role" '{ "hosts": [ "centos" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_role" '{ "hosts": [ "debian" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_role" '{ "hosts": [ "fedora" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_role" '{ "hosts": [ "rancher-k3os" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_role" '{ "hosts": [ "rancher-os" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_role" '{ "hosts": [ "opensuse-leap" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_role" '{ "hosts": [ "sles" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_role" '{ "hosts": [ "ubuntu" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_role" '{ "hosts": [ "centos-masters" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_role" '{ "hosts": [ "centos-workers" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_role" '{ "hosts": [ "ubuntu-masters" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "hello_role" '{ "hosts": [ "ubuntu-workers" ] }'
        ;;

    is_packages_installed)
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "is_packages_installed" '{ "hosts": [ "local" ], "pkgs": [ "foo", "bash-completion", "zip", "openssl", "python", "docker" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "is_packages_installed" '{ "hosts": [ "remotes" ], "pkgs": [ "foo", "bash-completion", "zip", "openssl", "python", "docker" ] }'
        ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "is_packages_installed" '{ "hosts": [ "remotes_mos" ], "pkgs": [ "foo", "bash-completion", "zip", "openssl", "python", "docker" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "is_packages_installed" '{ "hosts": [ "remotes_env" ], "pkgs": [ "foo", "bash-completion", "zip", "openssl", "python", "docker" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "is_packages_installed" '{ "hosts": [ "centos" ], "pkgs": [ "foo", "bash-completion", "zip", "openssl", "python", "docker" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "is_packages_installed" '{ "hosts": [ "debian" ], "pkgs": [ "foo", "bash-completion", "zip", "openssl", "python", "docker" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "is_packages_installed" '{ "hosts": [ "fedora" ], "pkgs": [ "foo", "bash-completion", "zip", "openssl", "python", "docker" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "is_packages_installed" '{ "hosts": [ "rancher-k3os" ], "pkgs": [ "foo", "bash-completion", "zip", "openssl", "python", "docker" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "is_packages_installed" '{ "hosts": [ "rancher-os" ], "pkgs": [ "foo", "bash-completion", "zip", "openssl", "python", "docker" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "is_packages_installed" '{ "hosts": [ "opensuse-leap" ], "pkgs": [ "foo", "bash-completion", "zip", "openssl", "python", "docker" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "is_packages_installed" '{ "hosts": [ "sles" ], "pkgs": [ "foo", "bash-completion", "zip", "openssl", "python", "docker" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "is_packages_installed" '{ "hosts": [ "ubuntu" ], "pkgs": [ "foo", "bash-completion", "zip", "openssl", "python", "docker" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "is_packages_installed" '{ "hosts": [ "centos-masters" ], "pkgs": [ "foo", "bash-completion", "zip", "openssl", "python", "docker" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "is_packages_installed" '{ "hosts": [ "centos-workers" ], "pkgs": [ "foo", "bash-completion", "zip", "openssl", "python", "docker" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "is_packages_installed" '{ "hosts": [ "ubuntu-masters" ], "pkgs": [ "foo", "bash-completion", "zip", "openssl", "python", "docker" ] }'
        # ansible_playbook "${PLATFORM}" "${SSH_USER}" "${SSH_GROUP}" "${SSH_PASSWORD}" "is_packages_installed" '{ "hosts": [ "ubuntu-workers" ], "pkgs": [ "foo", "bash-completion", "zip", "openssl", "python", "docker" ] }'
        ;;

    ssh_to)
        ssh_to "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}" # "ip_instances"
        ;;
    ssh_command)
        ssh_command "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}" # "ip_instances"
        ;;

    ssh_to_lb)
        ssh_to "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}" "ip_load_balancer"
        ;;

    ssh_to_etcd)
        ssh_to "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}" "ip_etcds"
        # ssh_to "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}" "etcds_public_ip"
        ;;
    ssh_to_storage)
        ssh_to "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}" "ip_storages"
        # ssh_to "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}" "storages_public_ip"
        ;;
    ssh_to_master)
        ssh_to "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}" "ip_masters"
        # ssh_to "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}" "masters_public_ip"
        ;;
    ssh_to_worker)
        ssh_to "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}" "ip_workers"
        # ssh_to "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}" "workers_public_ip"
        ;;

    ssh_to_alpine)
        ssh_to "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}" "ip_alpines"
        ;;
    ssh_to_centos)
        ssh_to "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}" "ip_centoss"
        ;;
    ssh_to_cirros)
        ssh_to "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}" "ip_cirross"
        ;;
    ssh_to_debian)
        ssh_to "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}" "ip_debians"
        ;;
    ssh_to_fedora)
        ssh_to "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}" "ip_fedoras"
        ;;
    ssh_to_opensuse_leap)
        ssh_to "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}" "ip_opensuse_leaps"
        ;;
    ssh_to_opensuse_tumbleweed)
        ssh_to "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}" "ip_opensuse_tumbleweeds"
        ;;
    ssh_to_oracle_linux)
        ssh_to "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}" "ip_oracle_linuxes"
        ;;
    ssh_to_rancher_k3os)
        ssh_to "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}" "ip_rancher_k3oss"
        ;;
    ssh_to_rancher_os)
        ssh_to "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}" "ip_rancher_oss"
        ;;
    ssh_to_raspios)
        ssh_to "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}" "ip_raspioss"
        ;;
    ssh_to_sles)
        ssh_to "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}" "ip_sless"
        ;;
    ssh_to_ubuntu)
        ssh_to "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}" "ip_ubuntus"
        ;;

    *)
        # Others / Unknown Option
        usage
        ;;
esac

# find "${TOP_DIR:?}" -type d -name bin -exec sh -c "rm -rf {}" {} \;

#******************************************************************************
#set +e # Exit on error Off
#set +x # Trace Off
#echo "End: $(basename "${0}")"
echo -e "\n================================================================================\n"
exit 0
#******************************************************************************
