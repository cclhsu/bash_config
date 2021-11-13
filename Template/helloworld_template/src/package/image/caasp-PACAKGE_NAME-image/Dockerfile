# Defines the tag for OBS and build script builds:
#!BuildTag: caasp/v4.5/{{ PACKAGE_NAME }}:%%PKG_VERSION%%-rev<VERSION>
#!BuildTag: caasp/v4.5/{{ PACKAGE_NAME }}:%%PKG_VERSION%%-rev<VERSION>-build<RELEASE>

# virt-api container image
FROM suse/sle15:15.3

# labelprefix=com.suse.kubevirt
PREFIXEDLABEL org.opencontainers.image.description="{{ PACKAGE_NAME }} running on a SLES15 SP2 container guest"
PREFIXEDLABEL org.opencontainers.image.title="CaaSP {{ PACKAGE_NAME }} container"
PREFIXEDLABEL org.opencontainers.image.created="%BUILDTIME%"
PREFIXEDLABEL org.opencontainers.image.vendor="SUSE LLC"
PREFIXEDLABEL org.opencontainers.image.url="https://www.suse.com/products/caas-platform/"
PREFIXEDLABEL org.opencontainers.image.version="%%PKG_VERSION%%"
PREFIXEDLABEL org.openbuildservice.disturl="%DISTURL%"
PREFIXEDLABEL com.suse.reference="registry.suse.com/caasp/v4.5/{{ PACKAGE_NAME }}:%%PKG_VERSION%%"

RUN zypper update -y && \
    zypper install -y \
           {{ PACKAGE_NAME }} \
           {{ PACKAGE_NAME }}ctl \
           shadow && \
    useradd -u 1001 --create-home -s /bin/bash {{ PACKAGE_NAME }}
WORKDIR /home/{{ PACKAGE_NAME }}
USER 1001
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
