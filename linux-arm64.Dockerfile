ARG UPSTREAM_IMAGE
ARG UPSTREAM_DIGEST_ARM64

# https://github.com/by275/docker-libtorrent
FROM ghcr.io/by275/libtorrent:1-alpine3.19 AS libtorrent

FROM ${UPSTREAM_IMAGE}@${UPSTREAM_DIGEST_ARM64}

ENV VIRTUAL_ENV="${APP_DIR}/venv"
COPY --from=libtorrent /libtorrent-build/usr/lib/libtorrent-rasterbar.* /usr/lib/
COPY --from=libtorrent /libtorrent-build/usr/lib/python3.11 ${VIRTUAL_ENV}/lib/python3.11

ENV PYTHON_EGG_CACHE="${CONFIG_DIR}/plugins/.python-eggs"
ENV PATH="${VIRTUAL_ENV}/bin:$PATH" PIP_DISABLE_PIP_VERSION_CHECK=1
ARG VERSION
ADD https://github.com/deluge-torrent/deluge/archive/refs/tags/deluge-${VERSION}.tar.gz /tmp/deluge-src.tar.gz
RUN apk add --no-cache boost-python3 && \
    mkdir -p /tmp/deluge-src && \
    tar xvf /tmp/deluge-src.tar.gz --strip-components 1 -C /tmp/deluge-src && \
    echo "${VERSION}" >/tmp/deluge-src/RELEASE-VERSION && \
    python3 -m venv ${VIRTUAL_ENV} && \
    pip install --no-cache -U pygeoip /tmp/deluge-src && \
    rm -rf /tmp/deluge-*

EXPOSE 8112 58846
ARG IMAGE_STATS
ENV IMAGE_STATS=${IMAGE_STATS} WEBUI_PORTS="8112/tcp,8112/udp,58846/tcp,58846/udp"
ENV DELUGE_LOGLEVEL="info"

COPY root/ /
