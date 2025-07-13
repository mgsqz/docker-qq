FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

# title
ENV TITLE=qq
ENV GTK_IM_MODULE=fcitx
ENV QT_IM_MODULE=fcitx
ENV XMODIFIERS=@im=fcitx

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /kclient/public/favicon.ico \
    https://im.qq.com/favicon.ico && \
  curl -o \
    /kclient/public/qq.png \
    https://qzonestyle.gtimg.cn/qzone/qzact/act/external/tiqq/logo.png && \
  echo "**** download packages ****" && \
  curl -o /tmp/QQ_3.2.18_250710_amd64_01.deb \
    https://dldir1v6.qq.com/qqfile/qq/QQNT/Linux/QQ_3.2.18_250710_amd64_01.deb && \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    libatomic1 \
    libxkbcommon-x11-dev \
    libxcb-icccm4-dev \
    libxcb-image0-dev \
    libxcb-render-util0-dev \
    libxcb-keysyms1-dev \
    zenity && \
  apt-get install -y --no-install-recommends \
    /tmp/QQ_3.2.18_250710_amd64_01.deb
RUN \
  echo "**** add fcitx5 ****" && \
  apt-get install -y --no-install-recommends \
    fcitx5 \
    fcitx5-chinese-addons && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# add local files
COPY /root /
RUN chmod +x /usr/bin/wrapped-qq

# ports and volumes
EXPOSE 3000

VOLUME /config
