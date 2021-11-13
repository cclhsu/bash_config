# https://docs.docker.com/engine/reference/builder/
# https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/
# https://hub.docker.com/r/library/debian/
# http://linux.die.net/man/8/apt-get
# https://packages.ubuntu.com/

# * https://hub.docker.com/u/helloworld/
# * https://github.com/helloworld/helloworld-docker

FROM debian:latest
# FROM debian:16.04.1
# FROM debian_base/debian:latest
# FROM debian_base/debian_glibc:latest
# FROM debian_base/debian_python3:latest
# FROM debian_base/debian_oracle_jdk_8:latest

LABEL maintainer="your@email.here"

WORKDIR /project

# ARG VERSION=0.0.1
# ARG APP=app
# ARG APP_VERSION=0.0.1
# COPY entrypoint.sh /usr/bin/entrypoint.sh
# RUN chmod +x /usr/bin/entrypoint.sh
# COPY templates /project/templates/
# COPY rootfs /
# COPY src /project/src
# RUN chmod +x /usr/bin/*.sh
# RUN chmod +x /etc/profile.d/*.sh

# # Enable Basic Authentication
# ARG _USER=user
# ARG _USER_ID=1000
# ARG _GROUP=user
# ARG _GROUP_ID=1000
# ARG _PASS=pass
# ARG _USER_HOME=/home

# RUN groupadd -g ${_GROUP_ID} -r ${_GROUP} && \
#     usermod -a -G ${_GROUP} root && \
#     useradd -r -m -g ${_GROUP} -u ${_USER_ID} ${_USER} -s /bin/bash -d /${_USER_HOME}/${_USER} && \
#     # usermod -a -G wheel ${_USER} && \
#     # (echo ${_PASS}; echo ${_PASS}) | sudo -S passwd ${_USER} && \
#     mkdir -p ${_USER_HOME}/${_USER}/.ssh && \
#     ln -s ${_USER_HOME}/${_USER}/.${_USER} /root/.${_USER}

# COPY bin/${PEM} ${_USER_HOME}/${_USER}/.ssh/${PEM}
# RUN chmod 600 ${_USER_HOME}/${_USER}/.ssh/${PEM}
# # RUN ssh-add ${_USER_HOME}/${_USER}/.ssh/${PEM}

# # Enable Root SSH with PEM
# RUN mkdir -p /root/.ssh
# COPY bin/${PEM} /root/.ssh/${PEM}
# RUN chmod 600 /root/.ssh/${PEM}
# # RUN ssh-add /root/.ssh/${PEM}

# # make the "en_US.UTF-8" locale so splunk will be utf-8 enabled by default
# RUN localedef -i en_US -f UTF-8 en_US.UTF-8
# ENV LANG en_US.UTF-8
# ENV LC_ALL en_US.UTF-8

# Update Repo and Package
RUN apt-get -y update

# Install Tools
RUN apt-get install -y bash vim sed jq curl rsync tar zip unzip unrar bc apt-utils && \
    apt-get install -y nc net-tools iproute iputils-ping && \
    apt-get install -y ca-certificates ssh openssl gnupg sudo && \
    apt-get install -y git make gcc linux-headers-generic && \
    apt-get autoclean && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apt/*

# # Install Development Tools
# RUN apt-get install -y build-essential linux-headers-generic && \
#     apt-get install -y apt-utils autoconf automake gcc g++ libtool python3 && \
#     apt-get install -y docker coreutils procps su-exec && \
#     apt-get autoclean && \
#     rm -rf /tmp/* /var/tmp/* /var/cache/apt/*

# # Method 1:
# # Install Python, PIP, and Requirements: https://pypi.python.org/pypi
# # apt-cache search python3
# # pip3 search pytest
# RUN apt-get install -y bash curl python3 python3-doc python3-dev && \
#     curl https://bootstrap.pypa.io/get-pip.py -o - | python3 && \
#     pip3 install --upgrade pip setuptools pytest pytest-cov && \
#     if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
#     if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
#     # curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash && \
#     rm -rf /var/cache/apt/* && \
#     rm -rf ${HOME}/.cache/pip/* && \
#     rm -r /root/.cache
# # ADD requirements.txt /project
# # RUN pip install -r requirements.txt && \
# #     # python setup.py install && \
# #     rm -rf ${HOME}/.cache/pip/* && \
# #     rm -rf requirements.txt

# http://zookeeper.apache.org/releases.html#download
ENV _PROJECT zookeeper
ENV _VERSION=3.4.13 \
    TOP_DIR=/opt/${_PROJECT} \
    BASE_URL=https://www.apache.org/dist/${_PROJECT} \
    TMP_DIR=/tmp
# BASE_URL http://ftp.mirror.tw/pub/apache/${_PROJECT}/
ENV _HOME=${TOP_DIR:?}/default \
    _WEB=/var/${_PROJECT}
ENV PATH ${PATH}:${_HOME}/bin
# ENV XXX_HOME=${_HOME}

# Download
# COPY bin/* /tmp/
COPY bin/${_PROJECT}-${_VERSION}.tar.gz /tmp/${_PROJECT}-${_VERSION}.tar.gz
# RUN curl -k -L ${BASE_URL}/${_PROJECT}-${_VERSION}/${_PROJECT}-${_VERSION}.tar.gz \
#         -o /tmp/${_PROJECT}-${_VERSION}.tar.gz && \
#     curl -k -L ${BASE_URL}/KEYS \
#         -o /tmp/KEYS && \
#     curl -k -L ${BASE_URL}/${_PROJECT}-${_VERSION}/${_PROJECT}-${_VERSION}.tar.gz.asc \
#         -o /tmp/${_PROJECT}-${_VERSION}.tar.gz.asc && \
#     curl -k -L ${BASE_URL}/${_PROJECT}-${_VERSION}/${_PROJECT}-${_VERSION}.tar.gz.md5 \
#         -o /tmp/${_PROJECT}-${_VERSION}.tar.gz.md5

# # Verify download
# RUN apk add --update --no-cache gnupg && \
#     rm -rf /var/cache/apk/*
# RUN md5sum -c /tmp/${_PROJECT}-${_VERSION}.tar.gz.md5 && \
#     gpg --import KEYS && \
#     gpg --verify /tmp/${_PROJECT}-${_VERSION}.tar.gz.asc

# Install
RUN mkdir -p "${TOP_DIR:?}" && \
    tar -xzf /tmp/${_PROJECT}-${_VERSION}.tar.gz -C "${TOP_DIR:?}" && \
    ln -s ${TOP_DIR:?}/${_PROJECT}-${_VERSION} ${_HOME}

# # Configure
# RUN cp ${TOP_DIR:?}/${_PROJECT}-${_VERSION}/conf/${_PROJECT}_sample.cfg ${TOP_DIR:?}/${_PROJECT}-${_VERSION}/conf/${_PROJECT}.cfg
# RUN sed  -i "s|/tmp/${_PROJECT}|${_HOME}/data|g" ${_HOME}/conf/${_PROJECT}.cfg && \
#     mkdir ${_HOME}/data

# Clean
RUN rm -rf /tmp/*

# forward request and error logs to docker log collector
# RUN ln -sf /dev/stdout /var/log/${APP}/access_log && \
#     ln -sf /dev/stderr /var/log/${APP}/error_log

# VOLUME[ "/var/www/html" ]
# VOLUME[ "/etc/${APP}" ]
# VOLUME[ "/usr/share/${APP}" ]
# VOLUME[ "/project" ]
# VOLUME[ "/opt/${_PROJECT}/${_PROJECT}-${_VERSION}/conf", "/opt/${_PROJECT}/${_PROJECT}-${_VERSION}/data" ]
# VOLUME[ "/var/log", "/etc/helloworld.d" ]
VOLUME[ "/data" ]
# VOLUME[ "/backup" ]

# WORKDIR /
# WORKDIR /project
# WORKDIR /opt/${_PROJECT}/${_PROJECT}-${_VERSION}

# EXPOSE 22 80 443 873 8080
# EXPOSE 8181 3000
# EXPOSE 514/tcp 514/udp

# Run As User
# USER ${_USER}
# USER root
# USER daemon:daemon
# USER nobody:nobody
# USER 1001:1001
# STOPSIGNAL SIGTERM

# CMD [ "supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf" ]
# Prefer ENTRYPOINT to CMD when building executable Docker image and you need a command always to be executed. Additionally use CMD if you need to provide extra default arguments that could be overwritten from command line when docker container runs.
# ENTRYPOINT [ "python", "/project/app", "start" ]      # exec form: preferred form
# CMD [ "python", "/project/app", "start" ]             # exec form: preferred form (main)

# CMD [ "entrypoint.sh" ]
ENTRYPOINT[ "entrypoint.sh" ]
# CMD [ "-d" ]
# CMD [ "-bash" ]

# CMD [ "/bin/bash" ]

# ENTRYPOINT[ "helloworld_daemon", "-n", "-f", "/etc/helloworld.conf" ]

# ENTRYPOINT[ "kubectl" ]
# ENTRYPOINT [ "/usr/bin/kubectl" ]
# CMD [ "version" ]
# CMD [ "--help" ]
