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

# https://github.com/helm/charts

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

function get_nodes() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <KUBECONFIG> <USERNAME> <IP_MASTERS> <IP_WORKERS>"
    else
        log_m "${FUNCNAME[0]}" # ${*}

        echo -e "\n>>> nodes...\n"
        kubectl get nodes -o wide

        # echo -e "\n>>> get nodes...\n"
        # kubectl get nodes -o json
        # # kubectl get nodes -o yaml

        for IP in ${IPS[*]}; do
            echo -e "\n>>> ${IP}...\n"
            ssh_cmd "${SSH_USER}" "${IP}" "df -h;  echo; free -h"
        done
    fi
}

function describe_node() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <KUBECONFIG>"
    else
        log_m "${FUNCNAME[0]}" # ${*}

        NODE_NAMES=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}')
        select_x_from_array "${NODE_NAMES}" "NODE_NAME" NODE_NAME

        echo -e "\n>>> describe node ${NODE_NAME}...\n"
        kubectl describe node "${NODE_NAME}"

        # echo -e "\n>>> get node ${NODE_NAME}...\n"
        # kubectl get nodes ${NODE_NAME} -o json
        # # kubectl get nodes ${NODE_NAME} -o yaml
    fi
}

function bash_master_node() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <IP_MASTERS> <USERNAME>"
    else
        log_m "${FUNCNAME[0]}" # ${*}

        # kubectl get nodes --selector=kubernetes.io/role!=master -o jsonpath={.items[*].status.addresses[?\(@.type==\"ExternalIP\"\)].address}
        # kubectl get nodes --selector=kubernetes.io/role!=master -o jsonpath={.items[*].status.addresses[?\(@.type==\"InternalIP\"\)].address}

        # kubectl get nodes --selector=node-role.kubernetes.io/control-plane=true-o jsonpath={.items[*].status.addresses[?\(@.type==\"ExternalIP\"\)].address}
        # kubectl get nodes --selector=node-role.kubernetes.io/control-plane=true-o jsonpath={.items[*].status.addresses[?\(@.type==\"InternalIP\"\)].address}

        IP_MASTERS=(${IP_MASTERS[*]})
        # echo "Masters IP: ${#IP_MASTERS[*]} ${IP_MASTERS[*]}"
        select_x_from_array "${IP_MASTERS}" "Master_IP" IP
        ssh_cmd "${SSH_USER}" "${IP}"
    fi
}

function bash_worker_node() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <IP_WORKERS> <USERNAME>"
    else
        log_m "${FUNCNAME[0]}" # ${*}

        # kubectl get nodes --selector=kubernetes.io/role!=master -o jsonpath={.items[*].status.addresses[?\(@.type==\"ExternalIP\"\)].address}
        # kubectl get nodes --selector=kubernetes.io/role!=master -o jsonpath={.items[*].status.addresses[?\(@.type==\"InternalIP\"\)].address}

        # kubectl get nodes --selector=node-role.kubernetes.io/control-plane!= -o jsonpath={.items[*].status.addresses[?\(@.type==\"ExternalIP\"\)].address}
        # kubectl get nodes --selector=node-role.kubernetes.io/control-plane!= -o jsonpath={.items[*].status.addresses[?\(@.type==\"InternalIP\"\)].address}

        IP_WORKERS=(${IP_WORKERS[*]})
        echo "Workers IP: ${#IP_WORKERS[*]} ${IP_WORKERS[*]}"
        select_x_from_array "${IP_WORKERS}" "Worker_IP" IP
        ssh_cmd "${SSH_USER}" "${IP}"
    fi
}

function journal_master_node() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <IP_MASTERS> <USERNAME>"
    else
        log_m "${FUNCNAME[0]}" # ${*}

        IP_MASTERS=(${IP_MASTERS[*]})
        # echo "Masters IP: ${#IP_MASTERS[*]} ${IP_MASTERS[*]}"
        select_x_from_array "${IP_MASTERS}" "Master_IP" IP
        select_x_from_array "cloud-init kernel systemd systemd-coredump [RPM] crio kubelet skuba skuba-update skuba-update ${MINIO_RELEASE_NAME} ${ETCD_RELEASE_NAME} ${SERVER_RELEASE_NAME} ${SERVICE_RELEASE_NAME} ${APP_RELEASE_NAME}" "IDENTIFIER" IDENTIFIER
        ssh_cmd "${SSH_USER}" "${IP}" "sudo journalctl -xet ${IDENTIFIER}"
    fi
}

function journal_worker_node() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <IP_WORKERS> <USERNAME>"
    else
        log_m "${FUNCNAME[0]}" # ${*}

        # kubectl get nodes --selector=kubernetes.io/role!=master -o jsonpath={.items[*].status.addresses[?\(@.type==\"ExternalIP\"\)].address}
        # kubectl get nodes --selector=kubernetes.io/role!=master -o jsonpath={.items[*].status.addresses[?\(@.type==\"InternalIP\"\)].address}

        IP_WORKERS=(${IP_WORKERS[*]})
        echo "Workers IP: ${#IP_WORKERS[*]} ${IP_WORKERS[*]}"
        select_x_from_array "${IP_WORKERS}" "Worker_IP" IP
        select_x_from_array "cloud-init kernel systemd systemd-coredump [RPM] crio kubelet skuba skuba-update skuba-update ${MINIO_RELEASE_NAME} ${ETCD_RELEASE_NAME} ${SERVER_RELEASE_NAME} ${SERVICE_RELEASE_NAME} ${APP_RELEASE_NAME}" "IDENTIFIER" IDENTIFIER
        ssh_cmd "${SSH_USER}" "${IP}" "sudo journalctl -xet ${IDENTIFIER}"
    fi
}

function get_events() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <KUBECONFIG> <NAMESPACE> <ALL>"
    else
        log_m "${FUNCNAME[0]}" # ${*}

        if [ "${NAMESPACES}" == "" ]; then
            # NAMESPACES="kube-system default"
            NAMESPACES="kube-system default ${NAMESPACE}"
            # NAMESPACES="${MINIO_NAMESPACE} ${ETCD_NAMESPACE} ${SERVER_NAMESPACE} ${SERVICE_NAMESPACE} ${APP_NAMESPACE}"
        fi

        for NAMESPACE in ${NAMESPACES[*]}; do
            echo -e "\n>>> namespace=${NAMESPACE}...\n"
            kubectl get events --sort-by='{.lastTimestamp}' --namespace=${NAMESPACE}
        done
    fi
}

function deploy_metrics_server() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
    else
        log_m "${FUNCNAME[0]}" # ${*}
        cd ${HOME}/Documents/myProject/Work/kubernetes/src/kubernetes/k8s_manifiest/tools/metrics-server || exit 1
        make deploy
    fi
}

function undeploy_metrics_server() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
    else
        log_m "${FUNCNAME[0]}" # ${*}
        cd ${HOME}/Documents/myProject/Work/kubernetes/src/kubernetes/k8s_manifiest/tools/metrics-server || exit 1
        make undeploy
    fi
}

function install_awscli() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
    else
        log_m "${FUNCNAME[0]}" # ${*}
        sudo pip3 install --upgrade awscli s3cmd python-magic
    fi
}

function uninstall_awscli() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
    else
        log_m "${FUNCNAME[0]}" # ${*}
        sudo pip3 uninstall -y awscli s3cmd python-magic
    fi
}

function deploy_server() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        # log_m "${FUNCNAME[0]} $# ${*}"
        # cd "${TOP_DIR:?}" || exit 1

        kubectl apply -f "${TOP_DIR:?}/data/server/base.yaml"
        # cd "${SERVER_MANIFEST}" || exit 1
        # make deploy
    fi
}

function upgrade_server() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        # log_m "${FUNCNAME[0]} $# ${*}"
        # cd "${TOP_DIR:?}" || exit 1

        kubectl delete -f "${TOP_DIR:?}/data/server/base.yaml"
        # cd "${SERVER_MANIFEST}" || exit 1
        # make undeploy
    fi
}

function undeploy_server() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        # log_m "${FUNCNAME[0]} $# ${*}"
        # cd "${TOP_DIR:?}" || exit 1

        kubectl delete -f "${TOP_DIR:?}/data/server/base.yaml"
        # cd "${SERVER_MANIFEST}" || exit 1
        # make undeploy
    fi
}

function install_service() {
    if [ "$#" != "1" ]; then
        log_e "Usage: ${FUNCNAME[0]} <SERVICE_VERSION>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        cd "${TOP_DIR:?}" || exit 1

        curl -L ${SERVICE_DOWNLOAD_URL}/v${1}/{{ SERVICE }}-v${1}-linux-amd64.tar.gz -o ${TOP_DIR:?}/data/bin/{{ SERVICE }}-v${1}-linux-amd64.tar.gz
        # tar xzvf ${TOP_DIR:?}/data/bin/{{ SERVICE }}-v${1}-linux-amd64.tar.gz -C ${TOP_DIR:?}/data/bin --strip-components=1
        tar xzvf ${TOP_DIR:?}/data/bin/{{ SERVICE }}-v${1}-linux-amd64.tar.gz -C ${TOP_DIR:?}/data/bin

        sudo cp "${TOP_DIR:?}/data/bin/{{ SERVICE }}-v${1}-linux-amd64/{{ SERVICE }}" "${USER_BIN}"
        sudo cp "${TOP_DIR:?}/data/bin/{{ SERVICE }}-v${1}-linux-amd64/{{ SERVICE }}ctl" "${USER_BIN}"
        which service
        which {{ SERVICE }}ctl
        {{ SERVICE }} --version
        {{ SERVICE }}ctl --version

        # sudo zypper addrepo --refresh http://download.suse.de/ibs/Devel:/CaaSP:/4.5/SLE_15_SP2/Devel:CaaSP:4.5.repo
        # sudo zypper --gpg-auto-import-keys install -y {{ SERVICE }} {{ SERVICE }}ctl # kubernetes-client
    fi
}

function uninstall_service() {
    if [ "$#" != "1" ]; then
        log_e "Usage: ${FUNCNAME[0]} <SERVICE_VERSION>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        cd "${TOP_DIR:?}" || exit 1
        rm -f ${TOP_DIR:?}/data/bin/{{ SERVICE }}-v${1}-linux-amd64.tar.gz
        rm -rf "${TOP_DIR:?}/data/bin/{{ SERVICE }}-v${1}-linux-amd64/"
        sudo rm -rf "${USER_BIN}/{{ SERVICE }}"
        sudo rm -rf "${USER_BIN}/{{ SERVICE }}ctl"

        # sudo zypper remove -y {{ SERVICE }} {{ SERVICE }}ctl
    fi
}

function deploy_service() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
    else
        log_m "${FUNCNAME[0]} ${SERVICE_DEPLOY_TYPE} ${SERVICE_HELM_TYPE}"

        if [ "${SERVICE_DEPLOY_TYPE}" == "cli" ]; then
            :
        else
            if [ "${SERVICE_HELM_TYPE}" == "git" ]; then
                cd "${SERVICE_HELM_CHARTS}" || exit 1
            else
                if [ "$(helm repo list | grep suse-charts | wc -l)" == 0 ]; then
                    $(which helm) init --client-only

                    # helm repo remove incubator
                    # helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com
                    # helm search incubator

                    # helm repo remove bitnami
                    # helm repo add bitnami https://charts.bitnami.com/bitnami
                    # helm search bitnami

                    # helm repo remove suse-charts
                    helm repo add suse-charts https://kubernetes-charts.suse.com
                    helm search suse-charts

                    # helm repo list
                    # helm search
                fi
                helm repo update
            fi

            helm install "${HELM_CHART_NAME}" \
                --name "${SERVICE_RELEASE_NAME}" \
                --namespace=${SERVICE_NAMESPACE}
            # --wait
        fi
    fi
}

function undeploy_service() {
    if [ "$#" != "0" ]; then
        log_e "Usage: ${FUNCNAME[0]} <ARGS>"
    else
        log_m "${FUNCNAME[0]}" # ${*}
        if [ "${SERVICE_DEPLOY_TYPE}" == "cli" ]; then
            :
        else
            helm delete --purge "${SERVICE_RELEASE_NAME}"
            helm list --all "${SERVICE_RELEASE_NAME}"
        fi
    fi
}

function deploy_app() {
    if [ "$#" != "1" ]; then
        log_e "Usage: ${FUNCNAME[0]} <APP_VERSION>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        # cd "${TOP_DIR:?}" || exit 1

        kubectl apply -f "${TOP_DIR:?}/data/nginx-app/base.yaml"
        # cd "${APP_MANIFEST}" || exit 1
        # make deploy
    fi
}

function upgrade_app() {
    if [ "$#" != "1" ]; then
        log_e "Usage: ${FUNCNAME[0]} <APP_VERSION>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        # cd "${TOP_DIR:?}" || exit 1

        kubectl apply -f "${TOP_DIR:?}/data/nginx-app/base.yaml"
        # cd "${APP_MANIFEST}" || exit 1
        # make deploy
    fi
}

function undeploy_app() {
    if [ "$#" != "1" ]; then
        log_e "Usage: ${FUNCNAME[0]} <APP_VERSION>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        # cd "${TOP_DIR:?}" || exit 1

        kubectl delete -f "${TOP_DIR:?}/data/nginx-app/base.yaml"
        # cd "${APP_MANIFEST}" || exit 1
        # make undeploy
    fi
}

function log() {
    if [ "$#" != "3" ]; then
        log_e "Usage: ${FUNCNAME[0]} <KUBECONFIG> <NAMESPACE> <LABEL>"
    else
        log_m "${FUNCNAME[0]}" # ${*}

        POD_NAMES=$(kubectl --kubeconfig="${1}" get pods --namespace="${2}" -l "${3}" -o jsonpath='{.items[*].metadata.name}')
        select_x_from_array "${POD_NAMES}" "POD_NAME" POD_NAME
        kubectl --kubeconfig="${1}" logs "${POD_NAME}" --namespace="${2}"
    fi
}

function describe() {
    if [ "$#" != "3" ]; then
        log_e "Usage: ${FUNCNAME[0]} <KUBECONFIG> <NAMESPACE> <LABEL>"
    else
        log_m "${FUNCNAME[0]}" # ${*}

        POD_NAMES=$(kubectl --kubeconfig="${1}" get pods --namespace="${2}" -l "${3}" -o jsonpath='{.items[*].metadata.name}')
        select_x_from_array "${POD_NAMES}" "POD_NAME" POD_NAME

        echo -e "\n>>> describe node ${NODE_NAME}...\n"
        kubectl --kubeconfig="${1}" describe pod "${POD_NAME}" --namespace="${2}"

        # echo -e "\n>>> get node ${NODE_NAME}...\n"
        # kubectl --kubeconfig="${1}" get pod "${POD_NAME}" --namespace="${2}" -o yaml
    fi
}

function bash() {
    if [ "$#" != "3" ]; then
        log_e "Usage: ${FUNCNAME[0]} <KUBECONFIG> <NAMESPACE> <LABEL>"
    else
        log_m "${FUNCNAME[0]}" # ${*}

        POD_NAMES=$(kubectl --kubeconfig="${1}" get pods --namespace="${2}" -l "${3}" -o jsonpath='{.items[*].metadata.name}')
        select_x_from_array "${POD_NAMES}" "POD_NAME" POD_NAME
        kubectl --kubeconfig="${1}" --namespace="${2}" exec -it "${POD_NAME}" /bin/bash
    fi
}

function copy_from_container() {
    if [ "$#" != "3" ]; then
        log_e "Usage: ${FUNCNAME[0]} <KUBECONFIG> <NAMESPACE> <LABEL>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        # cd "${TOP_DIR:?}" || exit 1

        POD_NAMES=$(kubectl --kubeconfig="${1}" get pods --namespace="${2}" -l "${3}" -o jsonpath='{.items[*].metadata.name}')
        select_x_from_array "${POD_NAMES}" "POD_NAME" POD_NAME
        mkdir -p ${TOP_DIR:?}/data/etc/${POD_NAME}
        kubectl --kubeconfig="${1}" cp ${2}/${POD_NAME}:/etc/{{ SERVICE }}.conf ${TOP_DIR:?}/data/etc/${POD_NAME}/
        kubectl --kubeconfig="${1}" cp ${2}/${POD_NAME}:/etc/{{ SERVICE }}.d ${TOP_DIR:?}/data/etc/${POD_NAME}/
    fi
}

function copy_to_container() {
    if [ "$#" != "3" ]; then
        log_e "Usage: ${FUNCNAME[0]} <KUBECONFIG> <NAMESPACE> <LABEL>"
        log_e "${FUNCNAME[0]} $# ${*}"
    else
        log_m "${FUNCNAME[0]} $# ${*}"
        # cd "${TOP_DIR:?}" || exit 1

        POD_NAMES=$(kubectl --kubeconfig="${1}" get pods --namespace="${2}" -l "${3}" -o jsonpath='{.items[*].metadata.name}')
        select_x_from_array "${POD_NAMES}" "POD_NAME" POD_NAME
        kubectl --kubeconfig="${1}" cp ${TOP_DIR:?}/data/etc/{{ SERVICE }}.conf ${2}/${POD_NAME}:/etc/{{ SERVICE }}.conf
        kubectl --kubeconfig="${1}" cp ${TOP_DIR:?}/data/etc/{{ SERVICE }}.d ${2}/${POD_NAME}:/etc/{{ SERVICE }}.d
    fi
}

#******************************************************************************
# Selection Parameters

if [ "${ACTION}" == "" ]; then

    MAIN_OPTIONS="get_nodes describe_node bash_master_node bash_worker_node journal_master_node journal_worker_nodeget_events \
        deploy_helm_and_tiller undeploy_helm_and_tiller deploy_helm undeploy_helm \
        deploy_metrics_server undeploy_metrics_server \
        deploy upgrade undeploy \
        log show_k8s_status describe bash copy_from_container copy_to_container ps_a_pod remove_container_and_image \
        install_debug_tools install_service_debuginfo cp_gdb_script_to_remote cp_gdb_log_to_local"

    select_x_from_array "${MAIN_OPTIONS}" "Action" ACTION # "a"
fi

# if [ "${XXX}" == "" ]; then
#     # OPTIONS="a b c"
#     # select_x_from_array "${OPTIONS}" "XXX" XXX # "a"
#     read_and_confirm "XXX MSG" XXX # "XXX set value"
# fi

set_packages_by_distribution

if [ "${SSH_USER}" == "" ]; then
    # select_x_from_array "${DISTROS} rancher root ec2-user" "SSH_USER" SSH_USER # "sles"
    read_and_confirm "SSH_USER MSG" SSH_USER "sles"
fi
if [ "${PLATFORM}" == "" ]; then
    # select_x_from_array "${PLATFORMS}" "PLATFORM" PLATFORM # "libvirt"
    read_and_confirm "PLATFORM MSG" PLATFORM "openstack"
fi
DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR=${HOME}/Documents/myProject/Workspace/suse/caasp4.5/deploy_caasp/tfstate/${PLATFORM}
get_terraform_env_ips ${DEPLOYMENT_PLATFORM_DISTRO_TOP_DIR}
CLUSTER_NAME=$(ls ${HOME}/clusters)
# K8S_CLUSTER=${HOME}/clusters/${CLUSTER_NAME}
KUBECONFIG=${HOME}/clusters/${CLUSTER_NAME}/admin.conf
NAMESPACE=kube-system # default | kube-system

# # SERVER
if [ "${SERVER_RELEASE_NAME}" == "" ]; then
    read_and_confirm "SERVER_RELEASE_NAME" SERVER_RELEASE_NAME "{{ SERVICE }}-server"
fi
if [ "${SERVER_LABEL}" == "" ]; then
    # 'component=server' | 'app=server' | 'name=server' | 'app.kubernetes.io/app=server' | 'app.kubernetes.io/name=server' | 'app.kubernetes.io/instance=server'
    read_and_confirm "SERVER_LABEL" SERVER_LABEL "app=${SERVER_RELEASE_NAME}"
fi
if [ "${SERVER_NAMESPACE}" == "" ]; then
    # default | kube-system | velero | server
    read_and_confirm "SERVER_NAMESPACE" SERVER_NAMESPACE "default"
fi
if [ "${SERVER_MANIFEST}" == "" ]; then
    read_and_confirm "SERVER_MANIFEST" SERVER_MANIFEST "${HOME}/Documents/myProject/Work/{{ SERVICE }}/src/kubernetes/k8s_manifiest/sles/${SERVER_RELEASE_NAME}"
    # read_and_confirm "SERVER_MANIFEST" SERVER_MANIFEST "${HOME}/src/gitlab.com/caasp/caasp-kubernetes-manifests/tools/test_artifacts/${SERVER_RELEASE_NAME}"
fi
if [ "${SERVER_HOST}" == "" ]; then
    read_and_confirm "SERVER_HOST" SERVER_HOST "${SERVER_RELEASE_NAME}.${SERVER_NAMESPACE}.svc.cluster.local"
fi
if [ "${SERVER_PORT}" == "" ]; then
    read_and_confirm "SERVER_PORT" SERVER_PORT "514"
fi
if [ "${SERVER_PROTOCOL}" == "" ]; then
    # TCP | UDP
    read_and_confirm "SERVER_PROTOCOL" SERVER_PROTOCOL "TCP"
fi

# # SERVICE
if [ "${SERVICE_DEPLOY_TYPE}" == "" ]; then
    # cli | helm | manifest
    read_and_confirm "SERVICE_DEPLOY_TYPE" SERVICE_DEPLOY_TYPE "helm"
fi
if [ "${SERVICE_RELEASE_NAME}" == "" ]; then
    read_and_confirm "SERVICE_RELEASE_NAME" SERVICE_RELEASE_NAME "{{ SERVICE }}"
fi
if [ "${SERVICE_LABEL}" == "" ]; then
    # 'component={{ SERVICE }}' | 'app={{ SERVICE }}' | 'name={{ SERVICE }}' | 'app.kubernetes.io/app={{ SERVICE }}' | 'app.kubernetes.io/name={{ SERVICE }}' | 'app.kubernetes.io/instance={{ SERVICE }}'
    read_and_confirm "SERVICE_LABEL" SERVICE_LABEL 'app={{ SERVICE }}'
fi
if [ "${SERVICE_NAMESPACE}" == "" ]; then
    # default | kube-system | {{ SERVICE }}
    read_and_confirm "SERVICE_NAMESPACE" SERVICE_NAMESPACE "kube-system"
fi
if [ "${SERVICE_HELM_TYPE}" == "" ]; then
    # git | helm_server
    read_and_confirm "SERVICE_HELM_TYPE" SERVICE_HELM_TYPE "git"
fi
if [ "${SERVICE_HELM_TYPE}" == "git" ]; then
    HELM_CHART_NAME=.
else
    # # https://hub.helm.sh/
    # https://hub.helm.sh/charts/incubator/{{ SERVICE }}
    HELM_CHART_NAME=incubator/{{ SERVICE }}
    # # https://hub.helm.sh/charts/stable/{{ SERVICE }}
    # HELM_CHART_NAME=stable/{{ SERVICE }}
    # HELM_CHART_NAME=suse-charts/{{ SERVICE }}
fi
if [ "${SERVICE_HELM_CHARTS}" == "" ]; then
    # ${HOME}/src/github.com/cclhsu/kubernetes-charts-suse-com/stable/{{ SERVICE }}
    # ${HOME}/src/github.com/SUSE/kubernetes-charts-suse-com/stable/{{ SERVICE }}
    # ${HOME}/src/gitlab.com/caasp/caasp-kubernetes-manifests/charts/{{ SERVICE }}
    read_and_confirm "SERVICE_HELM_CHARTS" SERVICE_HELM_CHARTS "${HOME}/src/github.com/cclhsu/kubernetes-charts-suse-com/stable/{{ SERVICE }}"
fi
if [ "${SERVICE_IMAGE}" == "" ]; then
    # gcr.io/{{ SERVICE }}-development/{{ SERVICE }}
    # {{ SERVICE }}/{{ SERVICE }}
    # registry.suse.de/home/cclhsu/branches/devel/caasp/4.5/containers/cr/containers/caasp/v4.5/{{ SERVICE }}
    # registry.suse.de/devel/caasp/4.5/containers/cr/containers/caasp/v4.5/{{ SERVICE }}
    # registry.suse.de/devel/caasp/4.5/containers/containers/caasp/v4.5/{{ SERVICE }}
    # registry.suse.com/caasp/v4.5/{{ SERVICE }}
    read_and_confirm "SERVICE_IMAGE" SERVICE_IMAGE "registry.suse.com/caasp/v4.5/{{ SERVICE }}"
fi
if [ "${SERVICE_VERSION}" == "" ]; then
    # https://github.com/{{ SERVICE }}-io/{{ SERVICE }}/releases
    read_and_confirm "SERVICE_VERSION" SERVICE_VERSION "3.3.15" # 3.3.18 | 3.4.4 | 3.4.3 | 3.3.15
fi
if [ "${SERVICE_DOWNLOAD_URL}" == "" ]; then
    read_and_confirm "SERVICE_DOWNLOAD_URL" SERVICE_DOWNLOAD_URL "https://storage.googleapis.com/{{ SERVICE }}" # https://storage.googleapis.com/{{ SERVICE }} | https://github.com/{{ SERVICE }}-io/{{ SERVICE }}/releases/download
fi

# # APP
if [ "${APP_RELEASE_NAME}" == "" ]; then
    read_and_confirm "APP_RELEASE_NAME" APP_RELEASE_NAME "nginx"
    # read_and_confirm "APP_RELEASE_NAME" APP_RELEASE_NAME "helloworld"
fi
# if [ "${APP_VERSION}" == "" ]; then
#     read_and_confirm "APP_VERSION" APP_VERSION "1.0.0" # 1.0.0
# fi
if [ "${APP_LABEL}" == "" ]; then
    # 'component=app' | 'app=app' | 'name=app' | 'app.kubernetes.io/app=app' | 'app.kubernetes.io/name=app' | 'app.kubernetes.io/instance=app'
    read_and_confirm "APP_LABEL" APP_LABEL "app=${APP_RELEASE_NAME}"
fi
if [ "${APP_NAMESPACE}" == "" ]; then
    # default | kube-system | velero | app
    read_and_confirm "APP_NAMESPACE" APP_NAMESPACE "nginx-example"
fi
if [ "${APP_MANIFEST}" == "" ]; then
    read_and_confirm "APP_MANIFEST" APP_MANIFEST "${TOP_DIR:?}/data/nginx-app"
    # read_and_confirm "APP_MANIFEST" APP_MANIFEST "${HOME}/Documents/myProject/Work/{{ SERVICE }}/src/kubernetes/k8s_manifiest/busybox/helloworld"
fi

NAMESPACES="${MINIO_NAMESPACE} ${ETCD_NAMESPACE} ${SERVER_NAMESPACE} ${SERVICE_NAMESPACE} ${APP_NAMESPACE}"

#******************************************************************************
# Main Program

mkdir -p "${TOP_DIR:?}/data/bin"

case ${ACTION} in
    get_nodes)
        get_nodes # <KUBECONFIG> <USERNAME> <IP_MASTERS> <IP_WORKERS>
        ;;
    describe_node)
        describe_node # <KUBECONFIG>
        ;;
    bash_master_node)
        bash_master_node # <IP_MASTERS> <USERNAME>
        ;;
    bash_worker_node)
        bash_worker_node # <IP_WORKERS> <USERNAME>
        ;;
    journal_master_node)
        journal_master_node # <IP_MASTERS> <USERNAME>
        ;;
    journal_worker_node)
        journal_worker_node # <IP_WORKERS> <USERNAME>
        ;;
    get_events)
        get_events # <KUBECONFIG> <NAMESPACE> <ALL>
        ;;

    deploy_helm_and_tiller)
        ${HOME}/Documents/myProject/Work/kubernetes/src/bash/bash_helm_and_tiller/cmd.sh -a install
        ;;
    undeploy_helm_and_tiller)
        ${HOME}/Documents/myProject/Work/kubernetes/src/bash/bash_helm_and_tiller/cmd.sh -a uninstall
        ;;

    deploy_helm3)
        ${HOME}/Documents/myProject/Work/kubernetes/src/bash/bash_helm3/cmd.sh -a install
        ;;
    undeploy_helm)
        ${HOME}/Documents/myProject/Work/kubernetes/src/bash/bash_helm3/cmd.sh -a uninstall
        ;;

    deploy_metrics_server)
        deploy_metrics_server
        ;;
    undeploy_metrics_server)
        undeploy_metrics_server
        ;;

    deploy_server)
        deploy_server
        ;;
    upgrade_server)
        upgrade_server
        ;;
    undeploy_server)
        undeploy_server
        ;;

    deploy)
        # ${HOME}/Documents/myProject/Work/minio/src/bash/bash_helm3_minio/cmd.sh -a create_credential
        # ${HOME}/Documents/myProject/Work/minio/src/bash/bash_helm3_minio/cmd.sh -a deploy_with_manifest
        # ${HOME}/Documents/myProject/Work/minio/src/bash/bash_mc/cmd.sh -a install
        # install_awscli
        # ${HOME}/Documents/myProject/Work/etcd/src/bash/bash_etcd/cmd.sh -a install
        # ${HOME}/Documents/myProject/Work/etcd/src/bash/bash_helm3_etcd/cmd.sh -a deploy
        # deploy_server "${SERVER_VERSION}"
        # install_service "${SERVICE_VERSION}"
        deploy_service
        # deploy_app "${APP_VERSION}"
        # status
        ;;
    # upgrade)
    #     upgrade
    #     ;;
    undeploy)
        # undeploy_app "${APP_VERSION}"
        undeploy_service
        # install_service "${SERVICE_VERSION}"
        # undeploy_server "${SERVER_VERSION}"
        # ${HOME}/Documents/myProject/Work/etcd/src/bash/bash_helm3_etcd/cmd.sh -a undeploy
        # ${HOME}/Documents/myProject/Work/etcd/src/bash/bash_etcd/cmd.sh -a uninstall
        # uninstall_awscli
        # ${HOME}/Documents/myProject/Work/minio/src/bash/bash_mc/cmd.sh -a uninstall
        # ${HOME}/Documents/myProject/Work/minio/src/bash/bash_helm3_minio/cmd.sh -a undeploy_with_manifest
        # ${HOME}/Documents/myProject/Work/minio/src/bash/bash_helm3_minio/cmd.sh -a delete_credential
        ;;

    deploy_app)
        deploy_app
        ;;
    upgrade_app)
        upgrade_app
        ;;
    undeploy_app)
        undeploy_app
        ;;

    log)
        select_x_from_array "minio etcd server service app kube-system" "SERVICE_TYPE" SERVICE_TYPE # "a"
        if [ "${SERVICE_TYPE}" == "minio" ]; then
            log "${KUBECONFIG}" "${MINIO_NAMESPACE}" "${MINIO_LABEL}"
        elif [ "${SERVICE_TYPE}" == "etcd" ]; then
            log "${KUBECONFIG}" "${ETCD_NAMESPACE}" "${ETCD_LABEL}"
        elif [ "${SERVICE_TYPE}" == "server" ]; then
            log "${KUBECONFIG}" "${SERVER_NAMESPACE}" "${SERVER_LABEL}"
        elif [ "${SERVICE_TYPE}" == "service" ]; then
            log "${KUBECONFIG}" "${SERVICE_NAMESPACE}" "${SERVICE_LABEL}"
        elif [ "${SERVICE_TYPE}" == "app" ]; then
            log "${KUBECONFIG}" "${APP_NAMESPACE}" "${APP_LABEL}"
        else
            log "${KUBECONFIG}" "${NAMESPACE}" "${LABEL}"
        fi
        ;;
    show_k8s_status)
        show_k8s_status
        ;;
    describe)
        select_x_from_array "minio etcd server service app kube-system" "SERVICE_TYPE" SERVICE_TYPE # "a"
        if [ "${SERVICE_TYPE}" == "minio" ]; then
            describe "${KUBECONFIG}" "${MINIO_NAMESPACE}" "${MINIO_LABEL}"
        elif [ "${SERVICE_TYPE}" == "etcd" ]; then
            describe "${KUBECONFIG}" "${ETCD_NAMESPACE}" "${ETCD_LABEL}"
        elif [ "${SERVICE_TYPE}" == "server" ]; then
            describe "${KUBECONFIG}" "${SERVER_NAMESPACE}" "${SERVER_LABEL}"
        elif [ "${SERVICE_TYPE}" == "service" ]; then
            describe "${KUBECONFIG}" "${SERVICE_NAMESPACE}" "${SERVICE_LABEL}"
        elif [ "${SERVICE_TYPE}" == "app" ]; then
            describe "${KUBECONFIG}" "${APP_NAMESPACE}" "${APP_LABEL}"
        else
            describe "${KUBECONFIG}" "${NAMESPACE}" "${LABEL}"
        fi
        ;;
    bash)
        select_x_from_array "minio etcd server service app kube-system" "SERVICE_TYPE" SERVICE_TYPE # "a"
        if [ "${SERVICE_TYPE}" == "minio" ]; then
            bash "${KUBECONFIG}" "${MINIO_NAMESPACE}" "${MINIO_LABEL}"
        elif [ "${SERVICE_TYPE}" == "etcd" ]; then
            bash "${KUBECONFIG}" "${ETCD_NAMESPACE}" "${ETCD_LABEL}"
        elif [ "${SERVICE_TYPE}" == "server" ]; then
            bash "${KUBECONFIG}" "${SERVER_NAMESPACE}" "${SERVER_LABEL}"
        elif [ "${SERVICE_TYPE}" == "service" ]; then
            bash "${KUBECONFIG}" "${SERVICE_NAMESPACE}" "${SERVICE_LABEL}"
        elif [ "${SERVICE_TYPE}" == "app" ]; then
            bash "${KUBECONFIG}" "${APP_NAMESPACE}" "${APP_LABEL}"
        else
            bash "${KUBECONFIG}" "${NAMESPACE}" "${LABEL}"
        fi
        ;;
    copy_from_container)
        select_x_from_array "server service app kube-system" "SERVICE_TYPE" SERVICE_TYPE # "a"
        if [ "${SERVICE_TYPE}" == "server" ]; then
            copy_from_container "${KUBECONFIG}" "${SERVER_NAMESPACE}" "${SERVER_LABEL}"
        elif [ "${SERVICE_TYPE}" == "service" ]; then
            copy_from_container "${KUBECONFIG}" "${SERVICE_NAMESPACE}" "${SERVICE_LABEL}"
        elif [ "${SERVICE_TYPE}" == "app" ]; then
            copy_from_container "${KUBECONFIG}" "${APP_NAMESPACE}" "${APP_LABEL}"
        else
            copy_from_container "${KUBECONFIG}" "${NAMESPACE}" "${LABEL}"
        fi
        ;;
    copy_to_container)
        select_x_from_array "server service app kube-system" "SERVICE_TYPE" SERVICE_TYPE # "a"
        if [ "${SERVICE_TYPE}" == "server" ]; then
            copy_to_container "${KUBECONFIG}" "${SERVER_NAMESPACE}" "${SERVER_LABEL}"
        elif [ "${SERVICE_TYPE}" == "service" ]; then
            copy_to_container "${KUBECONFIG}" "${SERVICE_NAMESPACE}" "${SERVICE_LABEL}"
        elif [ "${SERVICE_TYPE}" == "app" ]; then
            copy_to_container "${KUBECONFIG}" "${APP_NAMESPACE}" "${APP_LABEL}"
        else
            copy_to_container "${KUBECONFIG}" "${NAMESPACE}" "${LABEL}"
        fi
        ;;
    ps_a_pod)
        # /usr/bin/kubeadm
        echo -e "\n>>> get pods...\n"
        # kubectl get pods --namespace=${NAMESPACE}
        # kubectl get pods --namespace=${MINIO_NAMESPACE} -l "${MINIO_LABEL}"
        # kubectl get pods --namespace=${ETCD_NAMESPACE} -l "${ETCD_LABEL}"
        # kubectl get pods --namespace=${SERVER_NAMESPACE} -l "${SERVER_LABEL}"
        kubectl get pods --namespace=${SERVICE_NAMESPACE} -l "${SERVICE_LABEL}"
        # kubectl get pods --namespace=${APP_NAMESPACE} -l "${APP_LABEL}"
        for IP in ${IPS[*]}; do
            echo -e "\n>>> List pods in ${IP}...\n"
            ssh_cmd "${SSH_USER}" "${IP}" "sudo crictl ps -a"
            # ssh_cmd "${SSH_USER}" "${IP}" "sudo crictl ps -a | grep -i ${SERVICE_RELEASE_NAME}"
            # ssh_cmd "${SSH_USER}" "${IP}" "sudo crictl pods"
            echo -e "\n>>> List coredump directory in ${IP}...\n"
            ssh_cmd "${SSH_USER}" "${IP}" 'ls -l /var/lib/systemd/coredump/'
            echo -e "\n>>> coredumpctl list in ${IP}...\n"
            ssh_cmd "${SSH_USER}" "${IP}" 'sudo /usr/bin/coredumpctl list'
            echo -e "\n>>> Grep errors in ${IP}...\n"
            # ssh_cmd "${SSH_USER}" "${IP}" "sudo journalctl | grep -i 'warning\|error\|critical\|fail\|fatal\|kill\|out of \|oom\|memory\|evict\|fault\|core dump'"
            ssh_cmd "${SSH_USER}" "${IP}" "sudo journalctl | grep -i 'fail\|fatal\|kill\|out of \|oom\|evict\|fault\|core dump'"
            echo -e "\n>>> Show disk usage in ${IP}...\n"
            ssh_cmd "${SSH_USER}" "${IP}" "df -h"
            echo -e "\n>>> Show memory status in ${IP}...\n"
            ssh_cmd "${SSH_USER}" "${IP}" "free -h -t"
            # crictl exec -it ${CONTAINER_ID} /bin/bash
        done
        ;;
    remove_container_and_image)
        for IP in ${IPS[*]}; do
            echo -e "\n>>> ${IP}...\n"
            ssh_cmd "${SSH_USER}" "${IP}" 'sudo crictl images | grep {{ SERVICE }} | sed "s/  */ /g" | cut -d " " -f 3'
            ssh_cmd "${SSH_USER}" "${IP}" 'sudo crictl rmi $(sudo crictl images | grep {{ SERVICE }} | sed "s/  */ /g" | cut -d " " -f 3)'
        done
        ;;
    install_debug_tools)
        cat <<*EOF* >"${TOP_DIR:?}/data/enable_coredump.sh"
#!/usr/bin/env bash
set -x
# - [How to obtain application core dumps](https://www.suse.com/support/kb/doc/?id=3054866)
# - [How to obtain systemd service core dumps](https://www.suse.com/support/kb/doc/?id=7017137)
# - [systemd-sysctl.service, systemd-sysctl — Configure kernel parameters at boot](https://www.freedesktop.org/software/systemd/man/systemd-sysctl.service.html)
ulimit -c unlimited
# install -m 1777 -d /var/log/dump
# echo "/var/log/dump/core.%e.%p" > /proc/sys/kernel/core_pattern
install -m 1777 -d /var/lib/systemd/coredump
echo '|/usr/lib/systemd/systemd-coredump %P %u %g %s %t %c %e' > /proc/sys/kernel/core_pattern
/usr/lib/systemd/systemd-sysctl --prefix kernel.core_pattern
echo 'kernel.core_pattern=|/usr/lib/systemd/systemd-coredump %P %u %g %s %t %c %e' >> /etc/sysctl.d/50-coredump.conf
/usr/lib/systemd/systemd-sysctl /etc/sysctl.d/50-coredump.conf
rcapparmor stop
sysctl -w kernel.suid_dumpable=2
systemctl restart systemd-sysctl
/sbin/sysctl kernel.core_uses_pid
/sbin/sysctl kernel.core_pattern
ls -alh /var/log
# rm -rf /var/lib/systemd/coredump/*
ls -alh /var/lib/systemd/coredump/
# rm -rf /var/crash/*
ls -alh /var/crash/
cat /etc/systemd/coredump.conf
cat /etc/sysctl.d/50-coredump.conf
*EOF*
        for IP in ${IPS[*]}; do
            echo -e "\n>>> ${IP}...\n"
            ssh_cmd "${SSH_USER}" "${IP}" 'sudo zypper addrepo --refresh https://download.opensuse.org/repositories/devel:gcc/SLE-15/devel:gcc.repo'
            ssh_cmd "${SSH_USER}" "${IP}" 'sudo zypper lr -u'
            ssh_cmd "${SSH_USER}" "${IP}" 'sudo zypper --gpg-auto-import-keys install -y gdb gdbserver systemd-coredump kdump lz4'

            scp_to ${TOP_DIR:?}/data/enable_coredump.sh ${SSH_USER}@${IP}:/home/${SSH_USER}
            ssh_cmd "${SSH_USER}" "${IP}" "chmod +x /home/${SSH_USER}/enable_coredump.sh"
            ssh_cmd "${SSH_USER}" "${IP}" "sudo /home/${SSH_USER}/enable_coredump.sh"
            ssh_cmd "${SSH_USER}" "${IP}" 'sudo kill -11 $$'

            # ssh_cmd "${SSH_USER}" "${IP}" 'sudo zypper addrepo --refresh http://download.suse.de/ibs/home:/cclhsu:/branches:/Devel:/CaaSP:/4.5/SLE_15_SP2/home:cclhsu:branches:Devel:CaaSP:4.5.repo'
            # ssh_cmd "${SSH_USER}" "${IP}" 'sudo zypper --gpg-auto-import-keys install -y {{ SERVICE }} {{ SERVICE }}-debuginfo {{ SERVICE }}-debugsource syslog-service'
        done
        ;;

    install_service_debuginfo)
        for IP in ${IPS[*]}; do
            echo -e "\n>>> ${IP}...\n"
            ssh_cmd "${SSH_USER}" "${IP}" 'sudo zypper addrepo --refresh http://download.suse.de/ibs/home:/cclhsu:/branches:/Devel:/CaaSP:/4.5/SLE_15_SP2/home:cclhsu:branches:Devel:CaaSP:4.5.repo'
            ssh_cmd "${SSH_USER}" "${IP}" 'sudo zypper --gpg-auto-import-keys install -y {{ SERVICE }} {{ SERVICE }}-debuginfo {{ SERVICE }}-debugsource syslog-service'

            SLE_REGISTRATION_CODE=INTERNAL-USE-ONLY-4f45-86ca   # SUSE Linux Enterprise Server 15 SP2 x86_64
            CAASP_REGISTRATION_CODE=INTERNAL-USE-ONLY-65d9-22db # SUSE CaaS Platform 4.0 x86_64

            # http://updates.suse.de/SUSE/Products/SLE-Module-Basesystem/15-SP2/x86_64/product_debug/
            # http://download.suse.de/ibs/SUSE/Products/SLE-Module-Basesystem/15-SP2/x86_64/product_debug/
            # http://updates.suse.de/SUSE/Updates/SLE-Product-SLES/15-SP2/x86_64/update_debug/SUSE:Updates:SLE-Product-SLES:15-SP2:x86_64.repo
            ssh_cmd "${SSH_USER}" "${IP}" "sudo SUSEConnect -r ${SLE_REGISTRATION_CODE}"
            ssh_cmd "${SSH_USER}" "${IP}" "sudo SUSEConnect -p sle-module-containers/15.3/x86_64"
            ssh_cmd "${SSH_USER}" "${IP}" "sudo SUSEConnect -p caasp/4.5/x86_64 -r ${CAASP_REGISTRATION_CODE}"
            ssh_cmd "${SSH_USER}" "${IP}" "sudo zypper modifyrepo --enable SLE-Module-Basesystem15-SP2-Debuginfo-Pool"
            ssh_cmd "${SSH_USER}" "${IP}" "sudo zypper modifyrepo --enable SLE-Module-Basesystem15-SP2-Debuginfo-Updates"
            # ssh_cmd "${SSH_USER}" "${IP}" 'sudo zypper --gpg-auto-import-keys install -y gdb gdbserver systemd-coredump kdump lz4'
            # ssh_cmd "${SSH_USER}" "${IP}" 'sudo zypper --gpg-auto-import-keys install -y glibc-debuginfo-2.26-13.36.1.x86_64 krb5-debuginfo-1.16.3-3.6.1.x86_64 libcap2-debuginfo-2.25-2.41.x86_64 libcom_err2-debuginfo-1.43.8-4.17.1.x86_64 libcurl4-debuginfo-7.60.0-3.23.1.x86_64 libestr0-debuginfo-0.1.10-1.25.x86_64 libfastjson4-debuginfo-0.99.8-1.16.x86_64 libgcrypt20-debuginfo-1.8.2-8.15.3.x86_64 libgpg-error0-debuginfo-1.29-1.8.x86_64 libidn2-0-debuginfo-2.2.0-3.3.1.x86_64 libkeyutils1-debuginfo-1.5.10-3.42.x86_64 libldap-2_4-2-debuginfo-2.4.46-9.25.1.x86_64 liblognorm5-debuginfo-2.0.4-1.17.x86_64 liblz4-1-debuginfo-1.8.0-3.5.1.x86_64 liblzma5-debuginfo-5.2.3-4.3.1.x86_64 libnghttp2-14-debuginfo-1.39.2-3.3.1.x86_64 libopenssl1_1-debuginfo-1.1.0i-14.6.1.x86_64 libpcre1-debuginfo-8.41-4.20.x86_64 libpsl5-debuginfo-0.20.1-1.20.x86_64 libsasl2-3-debuginfo-2.1.26-5.3.1.x86_64 libselinux1-debuginfo-2.8-6.35.x86_64 libssh4-debuginfo-0.8.7-10.9.1.x86_64 libsystemd0-debuginfo-234-24.42.1.x86_64 libunistring2-debuginfo-0.9.9-1.15.x86_64 libuuid1-debuginfo-2.33.1-4.5.1.x86_64 libz1-debuginfo-1.2.11-3.9.1.x86_64'
            ssh_cmd "${SSH_USER}" "${IP}" 'sudo zypper --gpg-auto-import-keys install -y glibc-debuginfo-2.26-13.36.1.x86_64 libcom_err2-debuginfo-1.43.8-4.17.1.x86_64 libcurl4-debuginfo-7.60.0-3.26.1.x86_64 libidn2-0-debuginfo-2.2.0-3.3.1.x86_64 libldap-2_4-2-debuginfo-2.4.46-9.25.1.x86_64 liblz4-1-debuginfo-1.8.0-3.5.1.x86_64 liblzma5-debuginfo-5.2.3-4.3.1.x86_64 libnghttp2-14-debuginfo-1.39.2-3.3.1.x86_64 libsystemd0-debuginfo-234-24.42.1.x86_64 libz1-debuginfo-1.2.11-3.9.1.x86_64'
            ssh_cmd "${SSH_USER}" "${IP}" "sudo SUSEConnect -d"
        done
        ;;

    cp_gdb_script_to_remote)
        mkdir -p "${TOP_DIR:?}/data"
        cat <<\*EOF* >"${TOP_DIR:?}/data/create_gdb_traceback.sh"
#!/usr/bin/env bash
TOP_DIR=$(cd "$(dirname "${0}")" && pwd)
mkdir -p "${TOP_DIR:?}/log"
# cd "/var/crash"
cd "/var/lib/systemd/coredump"
rm -rf core.bash.*
OPTIONS=(*.lz4)
if [ "${OPTIONS}" == "*.lz4" ]; then
    exit 0
fi
SERVICE_BIN=/sbin/{{ SERVICE }}d # /sbin/{{ SERVICE }}d | /usr/bin/{{ SERVICE }} | /usr/bin/{{ SERVICE }}-agent
for OPTION in ${OPTIONS[*]}; do
  FILE=$(basename ${OPTION})
  rm -f ${FILE%.*} ${FILE%.*}.log ${TOP_DIR:?}/log/${FILE%.*}.log
  lz4 -d ${FILE}
  # getappcore ${FILE} 2>/dev/null | grep '\-\->' | cut -d '>' -f 2 | sed 's/   //g' | sed 's/.rpm/ /g' | tr -d '\n'
  gdb -x ${TOP_DIR:?}/gdb_cmds.txt -c ${FILE%.*} ${SERVICE_BIN} &> ${TOP_DIR:?}/log/${FILE%.*}.log
  rm -f ${FILE%.*}
done
*EOF*

        cat <<*EOF* >"${TOP_DIR:?}/data/gdb_cmds.txt"
bt
info threads
thread apply all bt full
quit
*EOF*
        for IP in ${IPS[*]}; do
            echo -e "\n>>> ${IP}...\n"
            scp_to ${TOP_DIR:?}/data/create_gdb_traceback.sh ${SSH_USER}@${IP}:/home/${SSH_USER}
            scp_to ${TOP_DIR:?}/data/gdb_cmds.txt ${SSH_USER}@${IP}:/home/${SSH_USER}
            ssh_cmd "${SSH_USER}" "${IP}" "chmod +x /home/${SSH_USER}/create_gdb_traceback.sh"
            # ssh_cmd "${SSH_USER}" "${IP}" "sudo /home/${SSH_USER}/create_gdb_traceback.sh"
        done
        ;;
    cp_gdb_log_to_local)
        for IP in ${IPS[*]}; do
            echo -e "\n>>> ${IP}...\n"
            mkdir -p ${TOP_DIR:?}/data/log/${IP}
            scp_to ${SSH_USER}@${IP}:/home/${SSH_USER}/log ${TOP_DIR:?}/data/log/${IP}
            ls -1 ${TOP_DIR:?}/data/log/${IP} | wc -l
        done
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
