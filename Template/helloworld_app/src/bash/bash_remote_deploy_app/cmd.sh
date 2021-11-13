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
# shellcheck source=/dev/null
source "${HOME}/.my_libs/bash/mylib"
# shellcheck source=/dev/null
source "${HOME}/.my_libs/bash/myprojects"
# TOP_DIR=${CLOUD_MOUNT_PATH}
# TOP_DIR=${CLOUD_REPLICA_PATH}
# TOP_DIR=${DOCUMENTS_PATH}
# source "${TOP_DIR:?}/_common_lib.sh"
# source ${TOP_DIR:?}/_common_lib_debian.sh
# source ${TOP_DIR:?}/_common_lib_redhat.sh
# source ${TOP_DIR:?}/_common_lib_suse.sh
# source "${TOP_DIR:?}/setup.conf"
echo "${PASSWORD}" | sudo -S echo ""
if [ "${OPTION}" == "" ]; then
    OPTION="${1}"
fi

#******************************************************************************
# Conditions Check and Init

# check_if_root_user
detect_package_system
set_alias_by_distribution               # ${DISTRO}
PROJECT_TYPE=bash_remote_deployment_app # ansible_app bash_app bash_create_project_app bash_deployment_app bash_install_app bash_remote_deployment_app docker_app helm_app helm3_app minifest_app deployment_app terraform_app

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

function create_script_daemon_install_infrastructure_requirements() {
    if [ "$#" != "4" ]; then
        log_e "Usage: ${FUNCNAME[0]} <CONFIGURATION_MANAGEMENT_TOP_DIR> <ROLE> <RUNTIME> <SCRIPT>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        # cd "${TOP_DIR:?}" || exit 1

        mkdir -p "${1}/${2}/${3}"
        cat <<\*EOF* >"${1}/${2}/${3}/${4}"
#!/usr/bin/env bash
# set -x
echo -e "\n================================================================================\n"
echo -e "\n>>> $(basename ${BASH_SOURCE})...\n"
echo -e "\n>>> Load Configuration...\n"
BIN_DIR=$(cd "$(dirname "${0}")" && pwd)
echo ">>> BIN_DIR=${BIN_DIR}"
TOP_DIR=$(dirname ${BIN_DIR})
echo ">>> TOP_DIR=${TOP_DIR}"
ROOTFS_DIR=${TOP_DIR:?}/rootfs
echo ">>> ROOTFS_DIR=${ROOTFS_DIR}"
ROLE=$(basename ${TOP_DIR:?})
echo ">>> ROLE=${ROLE}"
# source "${HOME}/.my_libs/bash/myconfigs"
# source "${HOME}/.my_libs/bash/mylib"
# source "${HOME}/.my_libs/bash/myprojects"
# source ${TOP_DIR:?}/${ROLE}_rc.sh
# if [ "$#" != "1" ]; then
#     log_e "Usage: ${FUNCNAME[0]} <ARGS>"
#     exit 0
# fi
# sudo cp ${ROOTFS_DIR}/etc/${ROLE}/${ROLE}.conf /etc/${ROLE}/${ROLE}.conf
PACKAGE_MANAGER=$(basename $(command -v {apt-get,brew,dnf,emerge,pacman,yum,zypper,xbps-install} 2>/dev/null) 2>/dev/null || basename $(command -v apk 2>/dev/null) 2>/dev/null)
PACKAGE_SYSTEM=$(basename $(command -v {dpkg,pkgbuild,rpm} 2>/dev/null) 2>/dev/null || basename $(command -v apk 2>/dev/null) 2>/dev/null)
DISTRO=$(cat /etc/*-release 2>/dev/null | uniq -u | grep ^ID= | cut -d = -f 2 | sed s/\"//g | sed s/linux/-linux/g && sw_vers -productName 2>/dev/null | sed 's/ //g' | tr A-Z a-z)
OS=$(uname -s | tr A-Z a-z)
ARCH=$(uname -m | sed -e 's/x86_64/amd64/' -e 's/aarch64/arm64/')
echo -e "\n>>> ${PACKAGE_MANAGER} ${PACKAGE_SYSTEM} ${DISTRO} ${OS} ${ARCH}....\n"
echo -e "\n================================================================================\n"
*EOF*
    fi
}

function install_infrastructure_requirements() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR> <SSH_USER> <IPS> <CONFIGURATION_MANAGEMENT_TOP_DIR> <REMOTE_CONFIGURATION_MANAGEMENT_TOP_DIR> <ROLE> <RUNTIME> <SCRIPT> <ARGS>"
    else
        log_m "${FUNCNAME[0]}" # ${*}
        cd "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}" || exit 1
        ROLE="all" # server client master worker helloworld all
        SCRIPT=${FUNCNAME[0]}.sh

        create_script_${RUNTIME}_${FUNCNAME[0]} "${CONFIGURATION_MANAGEMENT_TOP_DIR}" "${ROLE}" "${RUNTIME}" "${SCRIPT}"
        # scp_all_scripts_to_remote "${SSH_USER}" "${IPS}"
        update_remote_script "${SSH_USER}" "${IPS}" "${CONFIGURATION_MANAGEMENT_TOP_DIR}" "${REMOTE_CONFIGURATION_MANAGEMENT_TOP_DIR}" "${ROLE}" "${RUNTIME}" "${SCRIPT}"
        run_remote_script "${SSH_USER}" "${IPS}" "${CONFIGURATION_MANAGEMENT_TOP_DIR}" "${REMOTE_CONFIGURATION_MANAGEMENT_TOP_DIR}" "${ROLE}" "${RUNTIME}" "${SCRIPT}" "${ARGS}"
    fi
}

function uninstall_infrastructure_requirements() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR> <SSH_USER> <IPS> <CONFIGURATION_MANAGEMENT_TOP_DIR> <REMOTE_CONFIGURATION_MANAGEMENT_TOP_DIR> <ROLE> <RUNTIME> <SCRIPT> <ARGS>"
    else
        log_m "${FUNCNAME[0]}" # ${*}
        cd "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}" || exit 1
        ROLE="all" # server client master worker helloworld all
        SCRIPT=${FUNCNAME[0]}.sh

        create_script_${RUNTIME}_${FUNCNAME[0]} "${CONFIGURATION_MANAGEMENT_TOP_DIR}" "${ROLE}" "${RUNTIME}" "${SCRIPT}" # scp_all_scripts_to_remote "${SSH_USER}" "${IPS}"
        # scp_all_scripts_to_remote "${SSH_USER}" "${IPS}"
        update_remote_script "${SSH_USER}" "${IPS}" "${CONFIGURATION_MANAGEMENT_TOP_DIR}" "${REMOTE_CONFIGURATION_MANAGEMENT_TOP_DIR}" "${ROLE}" "${RUNTIME}" "${SCRIPT}"
        run_remote_script "${SSH_USER}" "${IPS}" "${CONFIGURATION_MANAGEMENT_TOP_DIR}" "${REMOTE_CONFIGURATION_MANAGEMENT_TOP_DIR}" "${ROLE}" "${RUNTIME}" "${SCRIPT}" "${ARGS}"
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
        CONFIGURATION_MANAGEMENT_TOP_DIR=${TOP_DIR:?}/inventories/${PLATFORM}/${PLATFORM_DISTRO} # ${TOP_DIR:?}
        REMOTE_CONFIGURATION_MANAGEMENT_TOP_DIR=/home/${SSH_USER}/inventories/${PLATFORM}/${PLATFORM_DISTRO}
        mkdir -p "${INFRASTRUCTURE_DEPLOYMENT_PROJECT_TOP_DIR}"
        mkdir -p "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}"
        mkdir -p "${CONFIGURATION_MANAGEMENT_TOP_DIR}"
        echo ">>> INFRASTRUCTURE_DEPLOYMENT_PROJECT_TOP_DIR=${INFRASTRUCTURE_DEPLOYMENT_PROJECT_TOP_DIR}"
        echo ">>> DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR=${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}"
        echo ">>> CONFIGURATION_MANAGEMENT_TOP_DIR=${CONFIGURATION_MANAGEMENT_TOP_DIR}"
        echo ">>> REMOTE_CONFIGURATION_MANAGEMENT_TOP_DIR=${REMOTE_CONFIGURATION_MANAGEMENT_TOP_DIR}"
        # STACK_NAME= # env | mos | my-cluster
        # echo ">>> STACK_NAME=${STACK_NAME}"
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
    if [ "$#" != "1" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        cd "${TOP_DIR:?}" || exit 1

    fi
}

function undeploy() {
    if [ "$#" != "1" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        cd "${TOP_DIR:?}" || exit 1

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
        status get_version lint build"

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
        status
        ;;

    undeploy)
        undeploy
        status
        ;;

    upgrade)
        upgrade
        status
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
