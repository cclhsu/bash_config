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

OBS_USER=${IBS_USERNAME}
OBS_ALIAS=ibs

#******************************************************************************
# Conditions Check and Init

# check_if_root_user
detect_package_system
set_alias_by_distribution # ${DISTRO}
PROJECT_TYPE=bash_app     # ansible_app bash_app bash_create_project_app bash_deployment_app bash_install_app bash_remote_deployment_app docker_app helm_app helm3_app minifest_app deployment_app terraform_app

#******************************************************************************
# Usage & Version

usage() {
    cat <<EOF

Usage: ${0} -a <ACTION> [-o <OPTION>]

This script is to <DO ACTION>.

OPTIONS:
    -h | --help             Usage
    -v | --version          Version
    -a | --action           Action [a|b|c]

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

function install_rpm_build() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        # log_m "${FUNCNAME[0]} $# ${*}"
        # cd "${TOP_DIR:?}" || exit 1

        if [ -e "${USER_BIN}/zypper" ]; then
            ${INSTALL_PACKAGE} gcc rpm-build rpm-devel rpmlint make python3 bash coreutils diffutils patch rpmdevtools

            ${ADD_REPO} http://download.opensuse.org/repositories/openSUSE:/Tools/openSUSE_Factory/openSUSE:Tools.repo
            ${REPO_UPDATE}
            ${INSTALL_PACKAGE} osc
        else
            ${INSTALL_PACKAGE} gcc rpm-build rpm-devel rpmlint make python3 bash coreutils diffutils patch rpmdevtools
        fi
        rm -rf "${HOME}/rpmbuild/"
        ${USER_BIN}/rpmdev-setuptree
        ls "${HOME}/rpmbuild/"
    fi
}

function search_package() {
    if [ "$#" != "1" ]; then
        log_e "Usage: ${FUNCNAME[0]} <PACKAGE_NAME>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        # cd "${TOP_DIR:?}" || exit 1

        if [ -e "${USER_BIN}/zypper" ]; then
            {SEARCH_PACKAGE} "${1}"
            osc -A "${OBS_ALIAS}" se "${1}"
            # osc -A "${OBS_ALIAS}" sm "${1}"
        else
            ${SEARCH_PACKAGE} "${1}"
        fi
    fi
}

function download_package() {
    if [ "$#" != "3" ]; then
        log_e "Usage: ${FUNCNAME[0]} <PACKAGE_NAME> <TAG_RELEASE_VERSION> <RELEASE_URL>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        curl -L "${3}/download/v${2}/${1}-${2}.tar.gz" -o "${TOP_DIR:?}/package/${1}-${2}.tar.gz"
        # curl -L "${3}/download/v${2}/${1}-${2}.tar.gz.asc" -o "${TOP_DIR:?}/package/${1}-${2}.tar.gz.asc"
    fi
}

function build() {
    if [ "$#" != "2" ]; then
        log_e "Usage: ${FUNCNAME[0]} <PACKAGE_NAME> <TAG_RELEASE_VERSION>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"

        cd "${TOP_DIR:?}/package/" || exit 1
        echo cp "${TOP_DIR:?}/package/${1}-${2}.tar.gz" "${HOME}/rpmbuild/SOURCES/"
        cp "${TOP_DIR:?}/package/${1}-${2}.tar.gz" "${HOME}/rpmbuild/SOURCES/"
        # cp "${TOP_DIR:?}/package/${1}-${2}.tar.gz.asc" "${HOME}/rpmbuild/SOURCES/"
        rpmbuild -ba "rpmbuild/${1}/${1}-golang.spec" # ${1}.spec | ${1}-golang.spec
        ls -alh "${HOME}/rpmbuild/SRPMS/"
        ls -alh "${HOME}/rpmbuild/RPMS/x86_64/"
        ls -alh "${HOME}/rpmbuild/RPMS/noarch/"
    fi
}

function install_rpm() {
    if [ "$#" != "3" ]; then
        log_e "Usage: ${FUNCNAME[0]} <PACKAGE_NAME> <TAG_RELEASE_VERSION> <BUILD_RELEASE_VERSION>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        # cd "${TOP_DIR:?}" || exit 1

        cd "${HOME}/rpmbuild/RPMS/x86_64/" || exit 1
        if [ -e "${USER_BIN}/zypper" ]; then
            ${INSTALL_PACKAGE} "${1}-${2}-${3}.x86_64.rpm"
        else
            ${INSTALL_PACKAGE} "${1}-${2}-${3}.x86_64.rpm"
        fi
    fi
}

function uninstall_rpm() {
    if [ "$#" != "3" ]; then
        log_e "Usage: ${FUNCNAME[0]} <PACKAGE_NAME> <TAG_RELEASE_VERSION> <BUILD_RELEASE_VERSION>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        # cd "${TOP_DIR:?}" || exit 1

        cd "${HOME}/rpmbuild/RPMS/x86_64/" || exit 1
        if [ -e "${USER_BIN}/zypper" ]; then
            ${UNINSTALL_PACKAGE} "${1}-${2}-${3}"
        else
            ${UNINSTALL_PACKAGE} "${1}-${2}-${3}"
        fi
    fi
}

function list_rpm() {
    if [ "$#" != "3" ]; then
        log_e "Usage: ${FUNCNAME[0]} <PACKAGE_NAME> <TAG_RELEASE_VERSION> <BUILD_RELEASE_VERSION>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        # cd "${TOP_DIR:?}" || exit 1

        cd "${HOME}/rpmbuild/RPMS/x86_64/" || exit 1
        echo -e "\n"
        rpm -ql "${1}-${2}-${3}.x86_64.rpm" | grep bin
        rpm -ql "${1}-${2}-${3}.x86_64.rpm" | grep "${1}"
        echo -e "\n"
        if [ -e "${USER_BIN}/zypper" ]; then
            ${SHOW_PACKAGE_INFORMATION} "${1}-${2}-${3}"
        else
            ${SHOW_PACKAGE_INFORMATION} "${1}-${2}-${3}"
        fi
    fi
}

function list_rpm_installed() {
    if [ "$#" != "3" ]; then
        log_e "Usage: ${FUNCNAME[0]} <PACKAGE_NAME> <TAG_RELEASE_VERSION> <BUILD_RELEASE_VERSION>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        # cd "${TOP_DIR:?}" || exit 1

        cd "${HOME}/rpmbuild/RPMS/x86_64/" || exit 1
        if [ -e "${USER_BIN}/zypper" ]; then
            ${LIST_INSTALL_PACKAGES} "${1}-${2}-${3}"
        else
            ${LIST_INSTALL_PACKAGES} "${1}-${2}-${3}"
        fi
    fi
}

function run() {
    if [ "$#" != "3" ]; then
        log_e "Usage: ${FUNCNAME[0]} <PACKAGE_NAME> <TAG_RELEASE_VERSION> <BUILD_RELEASE_VERSION>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        # cd "${TOP_DIR:?}" || exit 1

        cd "${HOME}/rpmbuild/RPMS/x86_64/" || exit 1
        $(rpm -ql "${1}-${2}-${3}.x86_64.rpm")
    fi
}

function clean_build() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        # log_m "${FUNCNAME[0]} $# ${*}"
        # cd "${TOP_DIR:?}" || exit 1

        rm -rf "${HOME}/rpmbuild/"
        ${USER_BIN}/rpmdev-setuptree
        ls "${HOME}/rpmbuild/"
    fi
}

#******************************************************************************
# Selection Parameters

if [ "${ACTION}" == "" ]; then
    MAIN_OPTIONS="install_rpm_build search_package download_package build install_rpm uninstall_rpm list_rpm list_rpm_installed run clean_build"

    select_x_from_array "${MAIN_OPTIONS}" "Action" ACTION # "a"
fi

# if [ "${XXX}" == "" ]; then
#     # OPTIONS="a b c"
#     # select_x_from_array "${OPTIONS}" "XXX" XXX # "a"
#     read_and_confirm "XXX MSG" XXX # "XXX set value"
# fi

set_packages_by_distribution

if [ "${BUILD_TYPE}" == "" ]; then
    read_and_confirm "BUILD_TYPE" BUILD_TYPE "package" # package | image
fi

if [ "${PACKAGE_NAME}" == "" ]; then
    read_and_confirm "PACKAGE_NAME" PACKAGE_NAME "<PACKAGE_NAME>"
fi

if [ "${IMAGE_NAME}" == "" ]; then
    read_and_confirm "IMAGE_NAME" IMAGE_NAME "caasp-${PACKAGE_NAME}-image"
fi

if [ "${RELEASE_URL}" == "" ]; then
    read_and_confirm "RELEASE_URL" RELEASE_URL "https://github.com/<REPO_NAME>/<PACKAGE_NAME>/releases"
fi

if [ "${TAG_RELEASE_VERSION}" == "" ]; then
    # https://github.com/<REPO_NAME>/<PACKAGE_NAME>/releases
    read_and_confirm "TAG_RELEASE_VERSION" TAG_RELEASE_VERSION "0.0.1"
fi

if [ "${BUILD_RELEASE_VERSION}" == "" ]; then
    # https://github.com/<REPO_NAME>/<PACKAGE_NAME>/releases
    read_and_confirm "BUILD_RELEASE_VERSION" BUILD_RELEASE_VERSION "0"
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
    install_rpm_build)
        install_rpm_build
        ;;

    search_package)
        search_package "${PACKAGE_NAME}"
        ;;
    download_package)
        download_package "${PACKAGE_NAME}" "${TAG_RELEASE_VERSION}" "${RELEASE_URL}"
        ;;

    build)
        build "${PACKAGE_NAME}" "${TAG_RELEASE_VERSION}"
        ;;
    install_rpm)
        install_rpm "${PACKAGE_NAME}" "${TAG_RELEASE_VERSION}" "${BUILD_RELEASE_VERSION}"
        ;;
    uninstall_rpm)
        uninstall_rpm "${PACKAGE_NAME}" "${TAG_RELEASE_VERSION}" "${BUILD_RELEASE_VERSION}"
        ;;
    list_rpm)
        list_rpm "${PACKAGE_NAME}" "${TAG_RELEASE_VERSION}" "${BUILD_RELEASE_VERSION}"
        ;;
    list_rpm_installed)
        list_rpm_installed "${PACKAGE_NAME}" "${TAG_RELEASE_VERSION}" "${BUILD_RELEASE_VERSION}"
        ;;
    run)
        run "${PACKAGE_NAME}" "${TAG_RELEASE_VERSION}" "${BUILD_RELEASE_VERSION}"
        ;;
    clean_build)
        clean_build
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
