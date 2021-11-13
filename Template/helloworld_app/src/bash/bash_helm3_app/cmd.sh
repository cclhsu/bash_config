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
set_alias_by_distribution # ${DISTRO}
PROJECT_TYPE=helm3_app    # ansible_app bash_app bash_create_project_app bash_deployment_app bash_install_app bash_remote_deployment_app docker_app helm_app helm3_app minifest_app deployment_app terraform_app

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
                                    status | get_version | lint | build |
                                    deploy_with_manifest | deploy_with_project_template | deploy_with_project | deploy_with_package | deploy_with_helmhub |
                                    undeploy_with_manifest | undeploy_with_project_template]
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
        create_package | delete_package) ;;
        deploy_with_manifest | deploy_with_project_template | deploy_with_project | deploy_with_package | deploy_with_helmhub) ;;
        undeploy_with_manifest | undeploy_with_project_template) ;;

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

function create_script_daemon_install_requirements() {
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

function install_requirements() {
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

function deploy_with_manifest() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        cd "${TOP_DIR:?}" || exit 1

        if [ "${MANIFEST_URLS}" != "" ]; then
            for MANIFEST_URL in ${MANIFEST_URLS[*]}; do
                local MANIFEST=${TOP_DIR:?}/data/${PROJECT_NAME}/${MANIFEST_DEPLOYMENT_TYPE}/$(basename ${MANIFEST_URL})
                # rm -f "${MANIFEST}"
                if [ ! -e "${MANIFEST}" ]; then
                    mkdir -p $(dirname ${MANIFEST})
                    curl -L "${MANIFEST_URL}" -o "${MANIFEST}"
                fi
                kubectl apply -f "${MANIFEST}" # --namespace=${NAMESPACE}
            done
        else
            # rm -f "${MANIFEST}"
            if [ ! -e "${MANIFEST}" ]; then
                mkdir -p $(dirname ${MANIFEST})
                curl -L "${MANIFEST_URL}" -o "${MANIFEST}"
            fi
            if [ ! -e "${MANIFEST_CRD}" ]; then
                curl -L "${MANIFEST_CRD_URL}" -o "${MANIFEST_CRD}"
            fi

            # echo -e "\n>>> Deploy the ${NAMESPACE} namespace...\n"
            # kubectl create namespace ${NAMESPACE}

            # local LABEL=""

            if [ $(kubectl get pods --namespace=${NAMESPACE} -l ${LABEL} | grep Running | wc -l) == 0 ]; then
                kubectl apply -f "${MANIFEST}" # --namespace=${NAMESPACE}
            fi

            if [ $(kubectl get pods --namespace=${NAMESPACE} -l ${LABEL} | grep Running | wc -l) == 0 ]; then
                kubectl apply -f "${MANIFEST_CRD}" # --namespace=${NAMESPACE}
            fi

            # while [ $(kubectl get pods --namespace=${NAMESPACE} -l ${LABEL} | grep Running | wc -l) == 0 ]; do
            #     sleep 1
            # done
            # sleep 1

            # local DEPLOYMENTS="${DEPLOYMENT}"
            # for DEPLOYMENT in ${DEPLOYMENTS[*]}; do
            #     echo -e "\n>>> Wait until all deployment ${DEPLOYMENT} components is up...\n"
            #     while ! kubectl get deployment ${DEPLOYMENT} --namespace=${NAMESPACE} --no-headers; do
            #         echo 'Looping...'
            #         sleep 5
            #     done
            #     kubectl wait --timeout=10m deployment ${DEPLOYMENT} --for=condition=Available --namespace=${NAMESPACE}
            #     kubectl rollout status deployment ${DEPLOYMENT} --namespace=${NAMESPACE}
            # done
        fi
    fi
}

function undeploy_with_manifest() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        cd "${TOP_DIR:?}" || exit 1

        if [ "${MANIFEST_URLS}" != "" ]; then
            local MANIFEST_URLS="$(echo ${MANIFEST_URLS} | sort -r)"
            for MANIFEST_URL in ${MANIFEST_URLS[*]}; do
                local MANIFEST=${TOP_DIR:?}/data/${PROJECT_NAME}/${MANIFEST_DEPLOYMENT_TYPE}/$(basename ${MANIFEST_URL})
                # rm -f "${MANIFEST}"
                if [ ! -e "${MANIFEST}" ]; then
                    mkdir -p $(dirname ${MANIFEST})
                    curl -L "${MANIFEST_URL}" -o "${MANIFEST}"
                fi
                kubectl delete -f "${MANIFEST}" # --namespace=${NAMESPACE}
            done
        else
            # rm -f "${MANIFEST}"
            if [ ! -e "${MANIFEST}" ]; then
                mkdir -p $(dirname ${MANIFEST})
                curl -L "${MANIFEST_URL}" -o "${MANIFEST}"
            fi
            if [ ! -e "${MANIFEST_CRD}" ]; then
                curl -L "${MANIFEST_CRD_URL}" -o "${MANIFEST_CRD}"
            fi

            kubectl delete -f "${MANIFEST}"     # --namespace=${NAMESPACE}
            kubectl delete -f "${MANIFEST_CRD}" # --namespace=${NAMESPACE}

            # local DEPLOYMENTS="${DEPLOYMENT}"
            # for DEPLOYMENT in ${DEPLOYMENTS[*]}; do
            #     echo -e "\n>>> Wait until all deployment ${DEPLOYMENT} components is deleted...\n"
            #     while kubectl get deployment ${DEPLOYMENT} --namespace=${NAMESPACE} --no-headers; do
            #         echo 'Looping...'
            #         sleep 5
            #     done
            # done

            # echo -e "\n>>> Undeploy the ${NAMESPACE} namespace...\n"
            # kubectl delete namespace ${NAMESPACE} # --timeout=10m
        fi
    fi
}

function create_package() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        cd "${CHART_PATH:?}" || exit 1

        helm package ${CHART_PATH}/${CHART_NAME} --debug
        ls "${CHART_PATH}"
        tar -tvf "${CHART_PATH}/${CHART_NAME}-${CHART_VERSION}.tgz"
    fi
}

function delete_package() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        cd "${CHART_PATH:?}" || exit 1

        rm -f "${CHART_PATH}/${CHART_NAME}-${CHART_VERSION}.tgz" "${HOME}/.helm/repository/local/${CHART_NAME}-${CHART_VERSION}.tgz"
    fi
}

function deploy_with_project_template() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        cd "${CHART_PATH:?}" || exit 1

        # kubectl_create_storage_class
        # kubectl_create_persistent_volume
        # kubectl_create_persistent_volume_claim

        echo -e "\n>>> Deploy the ${NAMESPACE} namespace...\n"
        kubectl create namespace ${NAMESPACE}

        echo -e "\n>>> Deploy the ${RELEASE} in ${NAMESPACE}...\n"
        helm template "${CHART_PATH}/${CHART_NAME}" --namespace=${NAMESPACE} -f "${CHART_PATH}/${CHART_NAME}/values.yaml" | kubectl apply --namespace=${NAMESPACE} -f -

        # local DEPLOYMENTS="${DEPLOYMENT}"
        # for DEPLOYMENT in ${DEPLOYMENTS[*]}; do
        #     echo -e "\n>>> Wait until all deployment ${DEPLOYMENT} components is up...\n"
        #     while ! kubectl get deployment ${DEPLOYMENT} --namespace=${NAMESPACE} --no-headers; do
        #         echo 'Looping...'
        #         sleep 5
        #     done
        #     kubectl wait --timeout=10m deployment ${DEPLOYMENT} --for=condition=Available --namespace=${NAMESPACE}
        #     kubectl rollout status deployment ${DEPLOYMENT} --namespace=${NAMESPACE}
        # done
    fi
}

function deploy_with_project() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        cd "${CHART_PATH:?}" || exit 1

        # kubectl_create_storage_class
        # kubectl_create_persistent_volume
        # kubectl_create_persistent_volume_claim

        # echo -e "\n>>> Deploy the ${NAMESPACE} namespace...\n"
        # kubectl create namespace ${NAMESPACE}

        echo -e "\n>>> Deploy the ${RELEASE} in ${NAMESPACE}...\n"
        helm install ${RELEASE} "${CHART_PATH}/${CHART_NAME}" \
            --create-namespace \
            --namespace=${NAMESPACE} \
            --wait \
            --timeout=10m \
            -f "${CHART_PATH}/${CHART_NAME}/values.yaml"

        # local DEPLOYMENTS="${DEPLOYMENT}"
        # for DEPLOYMENT in ${DEPLOYMENTS[*]}; do
        #     echo -e "\n>>> Wait until all deployment ${DEPLOYMENT} components is up...\n"
        #     while ! kubectl get deployment ${DEPLOYMENT} --namespace=${NAMESPACE} --no-headers; do
        #         echo 'Looping...'
        #         sleep 5
        #     done
        #     kubectl wait --timeout=10m deployment ${DEPLOYMENT} --for=condition=Available --namespace=${NAMESPACE}
        #     kubectl rollout status deployment ${DEPLOYMENT} --namespace=${NAMESPACE}
        # done

        # kubectl get svc --namespace=${NAMESPACE} --watch # wait for a IP
        helm list --all-namespaces
    fi
}

function upgrade_with_project() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        cd "${CHART_PATH:?}" || exit 1

        # kubectl_create_storage_class
        # kubectl_create_persistent_volume
        # kubectl_create_persistent_volume_claim

        # echo -e "\n>>> Deploy the ${NAMESPACE} namespace...\n"
        # kubectl create namespace ${NAMESPACE}

        echo -e "\n>>> Deploy the ${RELEASE} in ${NAMESPACE}...\n"
        helm upgrade ${RELEASE} "${CHART_PATH}/${CHART_NAME}" \
            --create-namespace \
            --namespace=${NAMESPACE} \
            --wait --timeout=10m \
            -f "${CHART_PATH}/${CHART_NAME}/values.yaml"

        # local DEPLOYMENTS="${DEPLOYMENT}"
        # for DEPLOYMENT in ${DEPLOYMENTS[*]}; do
        #     echo -e "\n>>> Wait until all deployment ${DEPLOYMENT} components is up...\n"
        #     while ! kubectl get deployment ${DEPLOYMENT} --namespace=${NAMESPACE} --no-headers; do
        #         echo 'Looping...'
        #         sleep 5
        #     done
        #     kubectl wait --timeout=10m deployment ${DEPLOYMENT} --for=condition=Available --namespace=${NAMESPACE}
        #     kubectl rollout status deployment ${DEPLOYMENT} --namespace=${NAMESPACE}
        # done

        # kubectl get svc --namespace=${NAMESPACE} --watch # wait for a IP
        helm list --all-namespaces
    fi
}

function deploy_with_package() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        cd "${CHART_PATH:?}" || exit 1

        # kubectl_create_storage_class
        # kubectl_create_persistent_volume
        # kubectl_create_persistent_volume_claim

        # echo -e "\n>>> Deploy the ${NAMESPACE} namespace...\n"
        # kubectl create namespace ${NAMESPACE}

        echo -e "\n>>> Deploy the ${RELEASE} in ${NAMESPACE}...\n"
        helm install ${RELEASE} ${CHART_NAME}-${CHART_VERSION}.tgz \
            --create-namespace \
            --namespace=${NAMESPACE} \
            --wait \
            --timeout=10m
        # --version=${CHART_VERSION}
        # --dry-run
        # --debug

        # local DEPLOYMENTS="${DEPLOYMENT}"
        # for DEPLOYMENT in ${DEPLOYMENTS[*]}; do
        #     echo -e "\n>>> Wait until all deployment ${DEPLOYMENT} components is up...\n"
        #     while ! kubectl get deployment ${DEPLOYMENT} --namespace=${NAMESPACE} --no-headers; do
        #         echo 'Looping...'
        #         sleep 5
        #     done
        #     kubectl wait --timeout=10m deployment ${DEPLOYMENT} --for=condition=Available --namespace=${NAMESPACE}
        #     kubectl rollout status deployment ${DEPLOYMENT} --namespace=${NAMESPACE}
        # done

        # kubectl get svc --namespace=${NAMESPACE} --watch # wait for a IP
        helm list --all-namespaces
    fi
}

function deploy_with_helmhub() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        cd "${CHART_PATH:?}" || exit 1

        if [ "$(helm repo list | grep ${HELMHUB_NAME} | wc -l)" == 0 ]; then
            helm repo add ${HELMHUB_NAME} ${HELMHUB_URL}
        fi
        helm repo update
        # helm repo list
        helm search repo # ${HELMHUB_NAME}
        # helm search repo --versions
        # helm fetch ${HELMHUB_NAME} --version=${CHART_VERSION}
        # helm search hub
        # helm list --all --all-namespaces

        # kubectl_create_storage_class
        # kubectl_create_persistent_volume
        # kubectl_create_persistent_volume_claim

        # echo -e "\n>>> Deploy the ${NAMESPACE} namespace...\n"
        # kubectl create namespace ${NAMESPACE}

        echo -e "\n>>> Deploy the ${RELEASE} in ${NAMESPACE}...\n"
        helm install ${RELEASE} ${CHART} \
            --create-namespace \
            --namespace=${NAMESPACE} \
            --wait \
            --timeout=10m
        # --version=${CHART_VERSION}
        # --dry-run
        # --debug

        # local DEPLOYMENTS="${DEPLOYMENT}"
        # for DEPLOYMENT in ${DEPLOYMENTS[*]}; do
        #     echo -e "\n>>> Wait until all deployment ${DEPLOYMENT} components is up...\n"
        #     while ! kubectl get deployment ${DEPLOYMENT} --namespace=${NAMESPACE} --no-headers; do
        #         echo 'Looping...'
        #         sleep 5
        #     done
        #     kubectl wait --timeout=10m deployment ${DEPLOYMENT} --for=condition=Available --namespace=${NAMESPACE}
        #     kubectl rollout status deployment ${DEPLOYMENT} --namespace=${NAMESPACE}
        # done

        # kubectl get svc --namespace=${NAMESPACE} --watch # wait for a IP
        helm list --all-namespaces
    fi
}

function upgrade_with_helmhub() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        cd "${CHART_PATH:?}" || exit 1

        if [ "$(helm repo list | grep ${HELMHUB_NAME} | wc -l)" == 0 ]; then
            helm repo add ${HELMHUB_NAME} ${HELMHUB_URL}
        fi
        helm repo update
        # helm repo list
        helm search repo # ${HELMHUB_NAME}
        # helm search repo --versions
        # helm fetch ${HELMHUB_NAME} --version=${CHART_VERSION}
        # helm search hub
        # helm list --all --all-namespaces

        # kubectl_create_storage_class
        # kubectl_create_persistent_volume
        # kubectl_create_persistent_volume_claim

        echo -e "\n>>> Upgrade the ${RELEASE} in ${NAMESPACE}...\n"
        helm upgrade ${RELEASE} ${CHART} \
            --create-namespace \
            --namespace=${NAMESPACE} \
            --wait \
            --timeout=10m
        # --version=${CHART_VERSION}
        # --dry-run
        # --debug

        # local DEPLOYMENTS="${DEPLOYMENT}"
        # for DEPLOYMENT in ${DEPLOYMENTS[*]}; do
        #     echo -e "\n>>> Wait until all deployment ${DEPLOYMENT} components is up...\n"
        #     while ! kubectl get deployment ${DEPLOYMENT} --namespace=${NAMESPACE} --no-headers; do
        #         echo 'Looping...'
        #         sleep 5
        #     done
        #     kubectl wait --timeout=10m deployment ${DEPLOYMENT} --for=condition=Available --namespace=${NAMESPACE}
        #     kubectl rollout status deployment ${DEPLOYMENT} --namespace=${NAMESPACE}
        # done

        # kubectl get svc --namespace=${NAMESPACE} --watch # wait for a IP
        helm list --all-namespaces
    fi
}

function undeploy_with_project_template() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        cd "${CHART_PATH:?}" || exit 1

        echo -e "\n>>> Undeploy the ${RELEASE} in ${NAMESPACE}...\n"
        helm template "${CHART_PATH}/${CHART_NAME}" | kubectl delete --namespace=${NAMESPACE} -f -

        # local DEPLOYMENTS="${DEPLOYMENT}"
        # for DEPLOYMENT in ${DEPLOYMENTS[*]}; do
        #     echo -e "\n>>> Wait until all deployment ${DEPLOYMENT} components is deleted...\n"
        #     while kubectl get deployment ${DEPLOYMENT} --namespace=${NAMESPACE} --no-headers; do
        #         echo 'Looping...'
        #         sleep 5
        #     done
        # done

        # kubectl_delete_persistent_volume_claim
        # kubectl_delete_persistent_volume
        # kubectl_delete_storage_class

        echo -e "\n>>> Undeploy the ${NAMESPACE} namespace...\n"
        kubectl delete namespace ${NAMESPACE} # --timeout=10m
    fi
}

function undeploy() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        cd "${CHART_PATH:?}" || exit 1

        echo -e "\n>>> Undeploy the ${RELEASE} in ${NAMESPACE}...\n"
        helm uninstall ${RELEASE} --namespace=${NAMESPACE} # --timeout=10m

        # local DEPLOYMENTS="${DEPLOYMENT}"
        # for DEPLOYMENT in ${DEPLOYMENTS[*]}; do
        #     echo -e "\n>>> Wait until all deployment ${DEPLOYMENT} components is deleted...\n"
        #     while kubectl get deployment ${DEPLOYMENT} --namespace=${NAMESPACE} --no-headers; do
        #         echo 'Looping...'
        #         sleep 5
        #     done
        # done

        # kubectl get svc --namespace=${NAMESPACE} --watch # wait for a IP
        helm list --all-namespaces

        # kubectl_delete_persistent_volume_claim
        # kubectl_delete_persistent_volume
        # kubectl_delete_storage_class

        echo -e "\n>>> Undeploy the ${NAMESPACE} namespace...\n"
        kubectl delete namespace ${NAMESPACE} # --timeout=10m

        if [ "$(helm repo list | grep ${HELMHUB_NAME} | wc -l)" == 1 ]; then
            echo -e "\n>>> Delete the ${HELMHUB_NAME}...\n"
            helm repo remove ${HELMHUB_NAME}
            # helm list --all --all-namespaces
        fi
    fi
}

function manifest() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        cd "${CHART_PATH}/${CHART_NAME}" || exit 1

        echo -e "\n>>> Create manifest from ${PWD}...\n"
        helm dependency update
        helm template "${CHART_PATH}/${CHART_NAME}" --namespace=${NAMESPACE} -f "${CHART_PATH}/${CHART_NAME}/values.yaml" # --debug
        git clean -fdx
        # NOTE: search in manifest under `kind: Deployment` for `containers: - name:`
    fi
}

function helm_chart_images() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"

        echo -e "\n>>> Get Images for ${CHART_NAME}...\n"
        if [ -e "${CHART_PATH:?}" ]; then
            cd "${CHART_PATH:?}" || exit 1
            helm template . --namespace=${NAMESPACE} -f "./values.yaml" | yq -r '..|.image? | select(.)' | sort -u # >> ./${CHART_NAME}-images.txt
        else
            if [ "$(helm repo list | grep ${HELMHUB_NAME} | wc -l)" == 0 ]; then
                helm repo add ${HELMHUB_NAME} ${HELMHUB_URL}
            fi
            helm repo update
            # helm search repo --versions

            helm fetch ${CHART} --version=${CHART_VERSION}
            helm template ${CHART_NAME}-${CHART_VERSION}.tgz | grep -oP '(?<=image: ").*(?=")' # >> ./${CHART_NAME}-images.txt
            helm repo remove ${HELMHUB_NAME}
        fi
    fi
}

# https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/
# https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/
function access_service() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        # cd "${TOP_DIR:?}" || exit 1

        local PORT=3000
        local BIND_PORT=${PORT}
        local SECRET=
        echo -e "\n>>> Now access the ${PROJECT_NAME} dashboard on http://127.0.0.1:${BIND_PORT}\n"
        echo "Username: $(kubectl get secret ${SECRET} --namespace ${NAMESPACE} --output=jsonpath='{.data.admin-user}' | base64 --decode)"
        echo "Password: $(kubectl get secret ${SECRET} --namespace ${NAMESPACE} --output=jsonpath='{.data.admin-password}' | base64 --decode)"
        local LABEL="app=${PROJECT_NAME},release=${RELEASE}" # app.kubernetes.io/name=${PROJECT_NAME} | app=${PROJECT_NAME},component=alertmanager | app=${PROJECT_NAME},release=${RELEASE}
        local POD=$(kubectl get pods --namespace=${NAMESPACE} -l ${LABEL} -o jsonpath='{.items[0].metadata.name}')
        # local PORT=$(kubectl get pod ${POD} --namespace=${NAMESPACE} --template='{{(index (index .spec.containers 0).ports 0).containerPort}}{{"\n"}}')
        kubectl port-forward ${POD} --namespace=${NAMESPACE} ${BIND_PORT}:${PORT}
    fi
}

function access_service_by_proxy() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        # cd "${TOP_DIR:?}" || exit 1

        local HOST_IP=localhost
        local HOST_PORT=8001
        local NAMESPACE=
        local PROTOCOL=http # http | https
        local SERVICE_NAME=
        local SERVICE_PORT=80
        echo -e "\n>>> Now access the ${PROJECT_NAME} dashboard on http://${HOST_IP}:${HOST_PORT}/api/v1/namespaces/${NAMESPACE}/services/${PROTOCOL}:${SERVICE_NAME}:${SERVICE_PORT}/proxy/\n"
        # echo "Username: $(kubectl get secret ${SECRET} --namespace ${NAMESPACE} --output=jsonpath='{.data.admin-user}' | base64 --decode)"
        # echo "Password: $(kubectl get secret ${SECRET} --namespace ${NAMESPACE} --output=jsonpath='{.data.admin-password}' | base64 --decode)"
        kubectl proxy
    fi
}

#******************************************************************************
# Selection Parameters

if [ "${ACTION}" == "" ]; then
    MAIN_OPTIONS="create_project_skeleton clean_project \
        install_requirements \
        install uninstall start stop \
        configure remove_configurations \
        create_package delete_package \
        deploy_with_manifest deploy_with_project_template deploy_with_project deploy_with_package deploy_with_helmhub \
        upgrade_with_project upgrade_with_helmhub \
        undeploy_with_manifest undeploy_with_project_template undeploy \
        manifest helm_chart_images \
        show_k8s_status \
        access_service access_service_by_proxy ssh_to_node \
        status get_version lint build"

    select_x_from_array "${MAIN_OPTIONS}" "Action" ACTION # "a"
fi

# if [ "${XXX}" == "" ]; then
#     # OPTIONS="a b c"
#     # select_x_from_array "${OPTIONS}" "XXX" XXX # "a"
#     read_and_confirm "XXX MSG" XXX # "XXX set value"
# fi

# set_packages_by_distribution
set_deployment_settings # "${LOCATION}" "${PLATFORM}" "${PLATFORM_DISTRO}" "${RUNTIME}" "${SSH_USER}"

if [ "${LOCATION}" == "remote" ]; then
    cd "${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}" || exit 1
    case ${ACTION} in
        create_project_skeleton | clean_project) ;;
        start_runtime | stop_runtime) ;;
        deploy_infrastructure | undeploy_infrastructure) ;;
        install | update | upgrade | dist-upgrade | uninstall | enable | start | stop | disable) ;;
        configure | remove_configurations) ;;
        install_infrastructure_requirements | uninstall_infrastructure_requirements | install_requirements | deploy | undeploy | upgrade | backup | restore | status | ssh_to_node | status | ssh_to_node)
            get_terraform_ips ${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR} ${INFRASTRUCTURE_DEPLOYMENT_PROJECT}
            ;;
        show_infrastructure_status | show_k8s_status | show_app_status) ;;
        access_service | access_service_by_proxy | ssh_to_node) ;;
        get_version) ;;
        *) ;;
    esac
fi

GITHUB_USER=    #
GITHUB_PROJECT= #
# https://github.com/${GITHUB_USER}/${GITHUB_PROJECT}/releases
PACKAGE_VERSION=$(curl -s "https://api.github.com/repos/${GITHUB_USER}/${GITHUB_PROJECT}/releases/latest" | jq --raw-output .tag_name)
PROJECT_NAME=${GITHUB_PROJECT} # helloworld | app | app-operator | suse
PROJECT_VERSION=${PACKAGE_VERSION}
MANIFEST_DEPLOYMENT_TYPE=upstream # local | upstream
MANIFEST_URL="https://github.com/${GITHUB_USER}/${GITHUB_PROJECT}/releases/download/${PACKAGE_VERSION}/${PROJECT_NAME}.yaml"
MANIFEST_CRD_URL="https://github.com/${GITHUB_USER}/${GITHUB_PROJECT}/releases/download/${PACKAGE_VERSION}/${PROJECT_NAME}-crd.yaml"
MANIFEST_PATH="${HOME}/src/github.com/${GITHUB_USER}/${GITHUB_PROJECT}" # ${GITHUB_USER} | ${GITHUB_USER}_${GITHUB_PROJECT}
MANIFEST=${TOP_DIR:?}/data/${PROJECT_NAME}/${MANIFEST_DEPLOYMENT_TYPE}/$([ "${MANIFEST_URL}" != "" ] && echo "$(basename ${MANIFEST_URL})" || echo "")
MANIFEST_CRD=${TOP_DIR:?}/data/${PROJECT_NAME}/${MANIFEST_DEPLOYMENT_TYPE}/$([ "${MANIFEST_CRD_URL}" != "" ] && echo "$(basename ${MANIFEST_CRD_URL})" || echo "")
MANIFEST_URLS=
PROJECT_PATH=${HOME}/Documents/myProject/Work/${GITHUB_PROJECT}/src/kubernetes/k8s_helm
CHART_PATH=${PROJECT_PATH:?}/${PROJECT_NAME}/charts
# CHART_PATH=${HOME}/src/github.com/helm/charts/stable
# CHART_PATH=${HOME}/src/github.com/helm/charts/incubator
# CHART_PATH=${HOME}/src/github.com/SUSE/kubernetes-charts-suse-com/stable
# CHART_PATH=${HOME}/src/github.com/cclhsu/kubernetes-charts-suse-com/stable
# CHART_PATH=${HOME}/src/github.com/${GITHUB_USER}/${GITHUB_PROJECT}/chart # ${GITHUB_USER} | ${GITHUB_USER}_${GITHUB_PROJECT}s
HELMHUB_URL=https://kubernetes-charts.suse.com # https://kubernetes-charts.storage.googleapis.com | https://kubernetes-charts-incubator.storage.googleapis.com | https://charts.helm.sh/stable | https://charts.helm.sh/incubator | https://kubernetes-charts.suse.com | https://charts.rancher.io
HELMHUB_NAME=${GITHUB_USER}-charts             # google-stable | google-incubator | helm-stable | helm-incubator | suse-charts
CHART_NAME=${PROJECT_NAME}                     # ${PROJECT_NAME}-operator
CHART_VERSION=$(echo ${PROJECT_VERSION} | sed 's/v//g')
CHART=${HELMHUB_NAME}/${CHART_NAME}
RELEASE=${PROJECT_NAME}    # myRelease
DEPLOYMENT=${PROJECT_NAME} # ${PROJECT_NAME}
DEPLOYMENTS="${DEPLOYMENT}"
NAMESPACE=${PROJECT_NAME} # kube-system | ${PROJECT_NAME} | ${PROJECT_NAME}-system | default
NAMESPACES=""
LABEL="release=${PROJECT_NAME}" # 'component=${PROJECT_NAME}' | 'app=${PROJECT_NAME}' | 'name=${PROJECT_NAME}' | 'app.kubernetes.io/app=${PROJECT_NAME}' | 'app.kubernetes.io/name=${PROJECT_NAME}' | 'app.kubernetes.io/instance=${PROJECT_NAME}'

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

    install)
        ${HOME}/Documents/myProject/Work/kubernetes/src/bash/bash_kubectl/cmd.sh -a install
        ${HOME}/Documents/myProject/Work/kubernetes/src/bash/bash_helm3/cmd.sh -a install
        # ${HOME}/Documents/myProject/Work/{{ SERVICE }}/src/bash/bash_{{ CLIENT }}/cmd.sh -a install
        ;;

    uninstall)
        # ${HOME}/Documents/myProject/Work/{{ SERVICE }}/src/bash/bash_{{ CLIENT }}/cmd.sh -a uninstall
        ${HOME}/Documents/myProject/Work/kubernetes/src/bash/bash_helm3/cmd.sh -a uninstall
        ${HOME}/Documents/myProject/Work/kubernetes/src/bash/bash_kubectl/cmd.sh -a uninstall
        ;;

    install_requirements)
        install_requirements
        ;;

    configure)
        configure
        ;;

    remove_configurations)
        remove_configurations
        ;;

    start)
        start # ${PROJECT_NAME}
        ;;

    stop)
        stop # ${PROJECT_NAME}
        ;;

    deploy_with_manifest)
        deploy_with_manifest
        ;;

    undeploy_with_manifest)
        undeploy_with_manifest
        ;;

    create_package)
        create_package
        ;;

    delete_package)
        delete_package
        ;;

    deploy_with_project_template)
        deploy_with_project_template
        ;;

    deploy_with_project)
        deploy_with_project
        ;;

    upgrade_with_project)
        upgrade_with_project
        ;;

    deploy_with_package)
        deploy_with_package
        ;;

    deploy_with_helmhub)
        deploy_with_helmhub
        ;;

    upgrade_with_helmhub)
        upgrade_with_helmhub
        ;;

    undeploy_with_project_template)
        undeploy_with_project_template
        ;;

    undeploy)
        undeploy
        ;;

    manifest)
        manifest
        ;;

    helm_chart_images)
        helm_chart_images
        ;;

    show_k8s_status)
        show_k8s_status
        ;;

    access_service)
        access_service
        ;;

    access_service_by_proxy)
        access_service_by_proxy
        ;;

    ssh_to_node)
        select_x_from_array "${IP_MASTERS} ${IP_WORKERS}" "NODE_IP" IP
        ssh_cmd "${SSH_USER}" "${IP}"
        ;;

    status)
        status
        ;;

    get_version)
        get_version # ${PROJECT_NAME}
        ;;

    lint)
        # ${HOME}/Documents/myProject/Development/bash/src/bash/bash_format_and_lint/helm/cmd.sh -a lint -s "${SRC_DIR}"
        ${HOME}/Documents/myProject/Development/bash/src/bash/bash_format_and_lint/helm/cmd.sh -a lint -s "${CHART_PATH}/${CHART_NAME}"
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
