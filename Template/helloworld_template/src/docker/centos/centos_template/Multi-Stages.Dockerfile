# https://docs.docker.com/engine/reference/builder/
# https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/
# https://hub.docker.com/r/library/centos/
# http://linux.die.net/man/8/yum
# https://rpmfind.net/
# https://pkgs.org/
# https://docs.docker.com/develop/develop-images/multistage-build/
# https://tachingchen.com/tw/blog/docker-multi-stage-builds/

# * https://hub.docker.com/u/helloworld/
# * https://github.com/helloworld/helloworld-docker

# FROM golang:centos AS gobuilder
# https://hub.docker.com/_/golang
FROM golang:1.13.7-centos AS gobuilder

ENV GOPATH /go
ENV GOOS linux
ENV GOARCH amd64
ENV GO111MODULE off
ENV GOFLAGS -mod=vendor
ENV CGO_ENABLED 1
# ENV GOPROXY https://proxy.golang.org

# WORKDIR /project
# # https://github.com/restic/restic/releases
# ARG TAG=v0.9.6
# RUN yum install -y --setopt=tsflags=nodocs centos-sdk && \
#     git clone https://github.com/restic/restic.git && \
#     cd /project/restic && \
#     git checkout -b ${DOCKER_TAG} ${DOCKER_TAG} && \
#     make release-binary

# WORKDIR ${GOPATH}/src/github.com/restic
# # https://github.com/restic/restic/releases
# ARG TAG=v0.9.6
# RUN yum install -y --setopt=tsflags=nodocs centos-sdk && \
#     # go get -u github.com/restic/restic && \
#     cd ${GOPATH}/src/github.com/restic && \
#     git clone https://github.com/restic/restic.git && \
#     cd ${GOPATH}/src/github.com/restic/restic && \
#     git checkout -b ${DOCKER_TAG} ${DOCKER_TAG} && \
#     make all
#     # make setup && \
#     # make && \
#     # make install

WORKDIR ${GOPATH}/src/github.com/{{ GITHUB_PROJECT }}
# https://github.com/{{ GITHUB_USER }}/{{ GITHUB_PROJECT }}/releases
ARG TAG=v0.9.6
RUN apk add --update --no-cache git make gcc linux-headers libc-dev && \
    # apk add --update --no-cache alpine-sdk && \
    # go get -u github.com/{{ GITHUB_USER }}/{{ GITHUB_PROJECT }} && \
    mkdir -p ${GOPATH}/src/github.com/{{ GITHUB_PROJECT }} && \
    cd ${GOPATH}/src/github.com/{{ GITHUB_PROJECT }} && \
    git clone https://github.com/{{ GITHUB_USER }}/{{ GITHUB_PROJECT }}.git && \
    cd ${GOPATH}/src/github.com/{{ GITHUB_USER }}/{{ GITHUB_PROJECT }} && \
    git checkout -b ${DOCKER_TAG} ${DOCKER_TAG} && \
    mkdir -p ${GOPATH}/bin && \
    go run build.go -o ${GOPATH}/bin/{{ GITHUB_PROJECT }}
    # go build -a -buildmode=pie -ldflags "-s -w -extldflags "-static" -X main.version=${DOCKER_TAG}" -o ${GOPATH}/bin/{{ GITHUB_PROJECT }} ./cmd/{{ GITHUB_PROJECT }}
    # go build -a -buildmode=pie -ldflags "-s -w -extldflags "-static" -X main.version=${DOCKER_TAG}" -o ${GOPATH}/bin/{{ GITHUB_PROJECT }} main.go
    # go build -a -buildmode=pie -ldflags "-s -w -extldflags "-static" -X main.version=${DOCKER_TAG}" ./cmd/{{ GITHUB_PROJECT }}

FROM alpine:3.14 AS makebuilder

WORKDIR /build/github.com/{{ GITHUB_PROJECT }}

# RUN apk add --update --no-cache alpine-sdk autoconf automake bash cdrkit curl perl syslinux xorriso xz-dev && \
#     # apk cache clean && \
#     rm -rf /tmp/* /var/tmp/* /var/cache/apk/* && \
#     git clone https://github.com/{{ GITHUB_USER }}/{{ GITHUB_PROJECT }}.git && \
#     cd /build/github.com/{{ GITHUB_PROJECT }}/{{ GITHUB_PROJECT }} && \
#     make && \
#     make install

FROM centos:latest
# FROM centos:7.4.1708
# FROM centos_base/centos:latest
# FROM centos_base/centos_systemd:latest
# FROM centos_base/centos_python3:latest
# FROM centos_base/centos_oracle_jdk_8:latest

LABEL maintainer="your@email.here"

# WORKDIR /project

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

# # Install EPEL, SCL, and Update
# RUN yum clean all && \
#     yum install -y --setopt=tsflags=nodocs epel-release centos-release-scl && \
#     # yum update -y --setopt=tsflags=nodocs && \
#     rm -rf /tmp/* /var/tmp/* /var/cache/yum/*

# # Install Tools
# RUN yum install -y --setopt=tsflags=nodocs bash vim sed jq curl rsync tar zip unzip bc which yum-utils && \
#     yum install -y --setopt=tsflags=nodocs nc net-tools iproute iputils && \
#     yum install -y --setopt=tsflags=nodocs ca-certificates openssh openssl openssh-keygen gnupg sudo && \
#     yum install -y --setopt=tsflags=nodocs git make gcc kernel-devel && \
#     yum clean all && \
#     rm -rf /tmp/* /var/tmp/* /var/cache/yum/*

RUN yum install -y --setopt=tsflags=nodocs ca-certificates openssl # fuse

ENV GOPATH /go
COPY --from=gobuilder ${GOPATH}/bin/{{ GITHUB_PROJECT }} /usr/bin/{{ GITHUB_PROJECT }}
WORKDIR /

# COPY --from=makebuilder /build /

# RUN apk add --update --no-cache {{ GITHUB_PROJECT }}

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
# ENTRYPOINT[ "entrypoint.sh" ]
# CMD [ "-d" ]
# CMD [ "-bash" ]

# CMD [ "/bin/bash" ]

# ENTRYPOINT[ "helloworld_daemon", "-n", "-f", "/etc/helloworld.conf" ]

# ENTRYPOINT[ "kubectl" ]
# ENTRYPOINT [ "/usr/bin/kubectl" ]
# CMD [ "version" ]
# CMD [ "--help" ]
