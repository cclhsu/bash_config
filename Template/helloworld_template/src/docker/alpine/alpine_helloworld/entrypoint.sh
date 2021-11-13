#!/usr/bin/env bash
set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x

# TOP_DIR=$(cd "$(dirname "${0}")" && pwd)
# TOP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# source /etc/profile.d/xxx.sh

COMMAND_TYPE=${COMMAND_TYPE:-default}
# XXX_SERVER=${XXX_SERVER:-"localhost:8181"}

# # Should wait till remote service is ready
# DOCKER_SERVICE_HOST=$(echo ${XXX_SERVER}| cut -d":" -f1)
# DOCKER_SERVICE_PORT=$(echo ${XXX_SERVER}| cut -d":" -f2)
# echo -e "\n>>> Waiting for service ${DOCKER_SERVICE_HOST}:${DOCKER_SERVICE_PORT} to be ready...\n"
# while ! nc -z ${DOCKER_SERVICE_HOST} ${DOCKER_SERVICE_PORT} </dev/null; do sleep 10; done

# function function_01() {
#     if [ "$#" != "1" ]; then
#         log_e "Usage: ${FUNCNAME[0]} <ARGS>"
#         log_e "${FUNCNAME[0]} $# ${*}"
#     else
#         log_m "${FUNCNAME[0]} $# ${*}"
#         # cd "${TOP_DIR:?}" || exit 1
#     fi
# }
echo "Starting task on $(date)."
START_TIME=$(date +%s)
if [ "$#" -gt 0 ]; then
    if [ "${1}" == "cmd" ]; then
        :
    else
        echo -e "\n>>> $* ...\n"
        # exec $@
        # pid=$!
        # echo -e "\n>>> Waiting for command $pid to finish...\n"
        # wait $pid

        # i=0;
        # while true
        # do
        #     echo "$i: $(date): Hello, World!"
        #     i=$((i+1))
        #     sleep 1
        # done

        RANDOM_WAIT_MIN=${1:-100}
        RANDOM_WAIT_MAX=${1:-3000}

        while true; do
            WAIT=$(shuf -i $RANDOM_WAIT_MIN-$RANDOM_WAIT_MAX -n 1)
            sleep $(echo "scale=4; $WAIT/1000" | bc)
            I=$(shuf -i 1-4 -n 1)
            D=$(date -Iseconds)
            case "$I" in
                "1")
                    echo "$D ERROR An error is usually an exception that has been caught and not handled."
                    ;;
                "2")
                    echo "$D INFO This is less important than debug log and is often used to provide context in the current task."
                    ;;
                "3")
                    echo "$D WARN A warning that should be ignored is usually at this level and should be actionable."
                    ;;
                "4")
                    echo "$D DEBUG This is a debug log that shows a log that can be ignored."
                    ;;
            esac
        done
    fi
elif [ "${COMMAND_TYPE}" == "producer" ] || [ "${COMMAND_TYPE}" == "server" ]; then
    :
elif [ "${COMMAND_TYPE}" == "consumer" ] || [ "${COMMAND_TYPE}" == "client" ]; then
    :
else
    # echo -e "\n>>> Install...\n"

    # echo -e "\n>>> Remove run and tmp folder...\n"

    # echo -e "\n>>> Export PATH...\n"

    # echo -e "\n>>> set variables...\n"

    # echo -e "\n>>> Create missing directories...\n"

    # echo -e "\n>>> Add missing configuration...\n"

    # echo -e "\n>>> add Mount Point...\n"

    # echo -e "\n>>> Initialize...\n"
    # /usr/bin/python /project/app initialize

    # echo -e "\n>>> Starting Web UI...\n"

    echo -e "\n>>> Starting service...\n"
    # /usr/bin/python /project/app start
    # trap "/usr/bin/python /project/app stop" SIGINT SIGTERM EXIT

    # /usr/bin/python /project/src start
    # trap "/usr/bin/python /project/src stop" SIGINT SIGTERM EXIT

    # echo -e "\n>>> Starting Bash...\n"
    # /bin/bash
    # trap "/bin/bash" SIGINT SIGTERM EXIT

    # echo -e "\n>>> Starting logging...\n"
    # tail -n 0 -f /var/log/${APP}/access_log 2>/dev/null &
    # tail -n 0 -F /var/log/${APP}/stderr.log 2>/dev/null &
    # tail -n 0 -F /var/log/${APP}/stdout.log 2>/dev/null &
    # tail -n 0 -F /var/log/${APP}/${APP}.log 2>/dev/null &

    # echo -e "\n>>> ${HOSTNAME} waiting...\n"
    # wait || :
fi
END_TIME=$(date +%s)
ELAPSED_TIME=$((${END_TIME} - ${START_TIME}))
echo -e "\nIt took ${ELAPSED_TIME} seconds to complete this task\n"
echo -e "\n>>> ${HOSTNAME} exited!\n"
