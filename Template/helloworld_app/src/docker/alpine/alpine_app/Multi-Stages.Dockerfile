# https://docs.docker.com/engine/reference/builder/
# https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/
# https://hub.docker.com/_/alpine/
# http://wiki.alpinelinux.org/wiki/Alpine_Linux_package_management
# https://pkgs.alpinelinux.org/packages
# https://docs.docker.com/develop/develop-images/multistage-build/
# https://tachingchen.com/tw/blog/docker-multi-stage-builds/

# * https://hub.docker.com/u/helloworld/
# * https://github.com/helloworld/helloworld-docker

# FROM golang:alpine AS gobuilder
# https://hub.docker.com/_/golang
FROM golang:1.13.7-alpine AS gobuilder

ENV GOPATH /go
ENV GOOS linux
ENV GOARCH amd64
ENV GO111MODULE off
ENV GOFLAGS -mod=vendor
ENV CGO_ENABLED 1
# ENV GOPROXY https://proxy.golang.org

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

RUN apk add --update --no-cache alpine-sdk autoconf automake bash cdrkit curl perl syslinux xorriso xz-dev && \
    # apk cache clean && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* && \
    git clone https://github.com/{{ GITHUB_USER }}/{{ GITHUB_PROJECT }}.git && \
    cd /build/github.com/{{ GITHUB_PROJECT }}/{{ GITHUB_PROJECT }} && \
    make && \
    make install

# FROM alpine:latest
FROM alpine:3.14
# FROM alpine:edge
# FROM alpine_base/alpine:latest
# FROM alpine_base/alpine_glibc:latest
# FROM alpine_base/alpine_python3:latest
# FROM alpine_base/alpine_oracle_jdk_8:latest

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

# RUN addgroup -S -g ${_GROUP_ID} ${_GROUP} && \
#     adduser -S -G ${_GROUP} -u ${_USER_ID} ${_USER} -D -h ${_USER_HOME}/${_USER} -s /bin/bash && \
#     addgroup ${_USER} root && \
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
# ENV LANG en_US.UTF-8
# ENV LC_ALL en_US.UTF-8

# # Here we install GNU libc (aka glibc) and set C.UTF-8 locale as default.
# # https://github.com/sgerrand/alpine-pkg-glibc/releases
# ENV GLIBC_BASE_URL="https://github.com/andyshinn/alpine-pkg-glibc/releases/download"
# #ENV GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download"
# ENV GLIBC_PACKAGE_VERSION="2.28-r0"
# ENV LANG=C.UTF-8

# RUN set -ex && \
#     apk add --update curl ca-certificates bash && \
#     curl -L "https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub" \
#         -o "/etc/apk/keys/sgerrand.rsa.pub" && \
#     for pkg in glibc-${GLIBC_PACKAGE_VERSION} glibc-bin-${GLIBC_PACKAGE_VERSION} glibc-i18n-${GLIBC_PACKAGE_VERSION}; do curl -L ${GLIBC_BASE_URL}/${GLIBC_PACKAGE_VERSION}/${pkg}.apk -o /tmp/${pkg}.apk; done && \
#     apk add --update --no-cache --allow-untrusted /tmp/*.apk && \
#     rm -f "/etc/apk/keys/sgerrand.rsa.pub" && \
#     rm -v /tmp/*.apk && \
#     ( /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true ) && \
#     echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
#     /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib && \
#     apk del glibc-i18n && \
#     rm -rf /var/cache/apk/*

# # Install Tools
# RUN apk add --update --no-cache bash vim sed jq curl rsync tar zip unzip unrar bc && \
#     # apk add --update --no-cache netcat-openbsd net-tools iputils && \
#     apk add --update --no-cache ca-certificates openssh openssl openssh-keygen gnupg sudo && \
#     # apk add --update --no-cache git make gcc linux-headers libc-dev libffi-dev openssl-dev && \
#     # apk cache clean && \
#     rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

RUN apk add --update --no-cache bash ca-certificates openssl # fuse

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
