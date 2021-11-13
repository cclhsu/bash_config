# https://docs.docker.com/engine/reference/builder/
# https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/
# https://hub.docker.com/_/opensuse/
# http://wiki.opensuselinux.org/wiki/opensuse_leap_Linux_package_management
# https://pkgs.opensuselinux.org/packages

# * https://hub.docker.com/u/helloworld/
# * https://github.com/helloworld/helloworld-docker

# FROM opensuse:latest
FROM opensuse/leap:15.3
# FROM opensuse/tumbleweed
# FROM registry.suse.com/suse/sle15:latest
# FROM opensuse_leap_base/opensuse_leap_python3:latest
# FROM opensuse_leap_base/opensuse_leap_oracle_jdk_8:latest

LABEL maintainer="your@email.here"

WORKDIR /project

# ARG VERSION=0.0.1
# ARG APP=app
# ARG APP_VERSION=0.0.1
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh
# COPY templates /project/templates/
# COPY rootfs /
# COPY src /project/src
# RUN chmod +x /usr/bin/*.sh
# RUN chmod +x /etc/profile.d/*.sh

# Enable Basic Authentication
ARG _USER=user
ARG _USER_ID=1000
ARG _GROUP=user
ARG _GROUP_ID=1000
ARG _PASS=pass
ARG _USER_HOME=/home

RUN groupadd -g ${_GROUP_ID} -r ${_GROUP} && \
    usermod -a -G ${_GROUP} root && \
    useradd -r -m -g ${_GROUP} -u ${_USER_ID} ${_USER} -s /bin/bash -d /${_USER_HOME}/${_USER} && \
    # usermod -a -G wheel ${_USER} && \
    # (echo ${_PASS}; echo ${_PASS}) | sudo -S passwd ${_USER} && \
    mkdir -p ${_USER_HOME}/${_USER}/.ssh && \
    ln -s ${_USER_HOME}/${_USER}/.${_USER} /root/.${_USER}

# COPY bin/${PEM} ${_USER_HOME}/${_USER}/.ssh/${PEM}
# RUN chmod 600 ${_USER_HOME}/${_USER}/.ssh/${PEM}
# # RUN ssh-add ${_USER_HOME}/${_USER}/.ssh/${PEM}

# # Enable Root SSH with PEM
# RUN mkdir -p /root/.ssh
# COPY bin/${PEM} /root/.ssh/${PEM}
# RUN chmod 600 /root/.ssh/${PEM}
# # RUN ssh-add /root/.ssh/${PEM}

# # make the "en_US.UTF-8" locale so splunk will be utf-8 enabled by default
# ENV LANG en_US.UTF-8
# ENV LC_ALL en_US.UTF-8

ENV SDKMAN_DIR /opt/sdkman
RUN zypper --non-interactive --no-gpg-checks --quiet install --auto-agree-with-licenses bash vim sed jq curl rsync tar zip unzip unrar bc git make && \
    curl -s "https://get.sdkman.io" | bash && \
    rm -rf /tmp/* /var/tmp/* /var/cache/zypp/*

ENV _PROJECT=gradle
ENV _HOME=/opt/sdkman/candidates/${_PROJECT}/current \
    _VERSION=4.10.2
RUN /bin/bash -c "source ${SDKMAN_DIR}/bin/sdkman-init.sh && sdk install ${_PROJECT} ${_VERSION}" && \
    ln -s "${_HOME}/bin/"* "/usr/bin/" && \
    zypper clean --all && \
    rm -rf /tmp/* /var/tmp/* /var/cache/zypp/*

# forward request and error logs to docker log collector
# RUN ln -sf /dev/stdout /var/log/${APP}/access_log && \
#     ln -sf /dev/stderr /var/log/${APP}/error_log

# VOLUME[ "/var/www/html" ]
# VOLUME[ "/etc/${APP}" ]
# VOLUME[ "/usr/share/${APP}" ]
VOLUME[ "/project" ]
# VOLUME[ "/opt/${_PROJECT}/${_PROJECT}-${_VERSION}/conf", "/opt/${_PROJECT}/${_PROJECT}-${_VERSION}/data" ]
# VOLUME[ "/var/log", "/etc/helloworld.d" ]
VOLUME[ "/data" ]
# VOLUME[ "/backup" ]

WORKDIR /project
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
# ENTRYPOINT[ "entrypoint.sh" ]
# CMD [ "-d" ]
# CMD [ "-bash" ]

CMD [ "/bin/bash" ]

# ENTRYPOINT[ "helloworld_daemon", "-n", "-f", "/etc/helloworld.conf" ]

# ENTRYPOINT[ "kubectl" ]
# ENTRYPOINT [ "/usr/bin/kubectl" ]
# CMD [ "version" ]
# CMD [ "--help" ]
