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
set_alias_by_distribution     # ${DISTRO}
PROJECT_TYPE=bash_install_app # ansible_app bash_app bash_create_project_app bash_deployment_app bash_install_app bash_remote_deployment_app docker_app helm_app helm3_app minifest_app deployment_app terraform_app

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

        INSTALL_METHOD=tar # bin tar bz2 xz zstd rar zip script snap rpm go npm pip docker podman
        # https://github.com/${GITHUB_USER}/${GITHUB_PROJECT}/releases
        # https://repology.org/projects/?search=${GITHUB_PROJECT}
        PROJECT_BIN=                        #
        PROJECT_BIN_RUN_PARAMETERS=         #
        SYSTEMD_SERVICE_NAME=${PROJECT_BIN} #
        GITHUB_USER=                        #
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
        PROJECT_PYTHON_PACKAGES=${PROJECT_BIN}
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

#******************************************************************************
# Selection Parameters

if [ "${ACTION}" == "" ]; then
    MAIN_OPTIONS="install uninstall \
        configure remove_configurations \
        start stop \
        status get_version lint build"

    select_x_from_array "${MAIN_OPTIONS}" "Action" ACTION # "a"
fi

# if [ "${XXX}" == "" ]; then
#     # OPTIONS="a b c"
#     # select_x_from_array "${OPTIONS}" "XXX" XXX # "a"
#     read_and_confirm "XXX MSG" XXX # "XXX set value"
# fi

set_packages_by_distribution

#******************************************************************************
# Main Program

# update_datetime
# source_rc "${DISTRO}" "${PLATFORM}"
rm -rf "${HOME}/.ssh/known_hosts"
# https://www.ssh.com/ssh/agent
# ssh-agent bash
ssh-add "${HOME}/.ssh/id_rsa"

case ${ACTION} in

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
