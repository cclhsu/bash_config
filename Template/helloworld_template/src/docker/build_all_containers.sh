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
# detect_package_system
# set_alias_by_distribution # ${DISTRO}
PROJECT_TYPE=bash_app # ansible_app bash_app bash_create_project_app bash_deployment_app bash_install_app bash_remote_deployment_app docker_app helm_app helm3_app minifest_app deployment_app terraform_app

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

#******************************************************************************
# Main Program

# if [ "$#" != "1" ]; then
#     log_e "Usage: ${FUNCNAME[0]} <arg_01>"
#     exit 0
# fi
# ARG_01="${}"

function list_all_images() {

    IMAGES_PATH=$(find "${TOP_DIR:?}" -name Dockerfile -exec dirname "{}" \;)
    # echo ${IMAGES_PATH[*]}

    for IMAGE_PATH in ${IMAGES_PATH[*]}; do
        echo "$(basename ${IMAGE_PATH})"
    done

    # docker images
}

function build_all_images() {

    IMAGES_PATH=$(find "${TOP_DIR:?}" -name Dockerfile -exec dirname "{}" \;)
    # echo ${IMAGES_PATH[*]}

    for IMAGE_PATH in ${IMAGES_PATH[*]}; do
        echo "--------------------------------------------------------------------------------"
        echo -e "\n>>> Building Image from ${IMAGE_PATH} ...\n"
        cd "${IMAGE_PATH}" || exit 1
        time make all
        # make publish
        echo "--------------------------------------------------------------------------------"
    done

    docker images
}

function publish_all_images() {

    IMAGES_PATH=$(find "${TOP_DIR:?}" -name Dockerfile -exec dirname "{}" \;)
    # echo ${IMAGES_PATH[*]}

    for IMAGE_PATH in ${IMAGES_PATH[*]}; do
        echo "--------------------------------------------------------------------------------"
        echo -e "\n>>> Publishing Image from ${IMAGE_PATH} ...\n"
        cd "${IMAGE_PATH}" || exit 1
        time make publish
        echo "--------------------------------------------------------------------------------"
    done

    docker images
}

function remove_all_images() {

    IMAGES_PATH=$(find "${TOP_DIR:?}" -name Dockerfile -exec dirname "{}" \;)
    # echo ${IMAGES_PATH[*]}

    for IMAGE_PATH in ${IMAGES_PATH[*]}; do
        echo "--------------------------------------------------------------------------------"
        echo -e "\n>>> Deleting Image from ${IMAGE_PATH} ...\n"
        cd "${IMAGE_PATH}" || exit 1
        make untag_publish
        time make clean
        echo "--------------------------------------------------------------------------------"
    done

    docker images
}

function usage() {
    cat <<EOF

Usage: ${0} [options]

-h| --help          this is some help text.
                    this is more help text.
-l|--list           List All Images
-b|--build          Build All Images
-p|--publish        Publish All Images
-r|--remove         Delete All Images

EOF
}

if [ "${1}" == "-l" ] || [ "${1}" == "--list" ]; then
    list_all_images
elif [ "${1}" == "-b" ] || [ "${1}" == "--build" ]; then
    build_all_images
elif [ "${1}" == "-p" ] || [ "${1}" == "--publish" ]; then
    publish_all_images
elif [ "${1}" == "-r" ] || [ "${1}" == "--remove" ]; then
    remove_all_images
elif [ "${1}" == "-h" ] || [ "${1}" == "--help" ]; then
    usage
else
    echo "Invalid Parameter!"
    usage
fi

#******************************************************************************
#set +e # Exit on error Off
#set +x # Trace Off
#echo "End: $(basename "${0}")"
echo -e "\n================================================================================\n"
exit 0
#******************************************************************************
