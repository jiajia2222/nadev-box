# 构建阶段
FROM alpine:latest AS builder
ARG TARGETARCH
ENV ARCH=$TARGETARCH

# 安装构建依赖
RUN set -ex &&\
  apk add --no-cache wget xz

# 下载并解压 s6-overlay
RUN set -ex &&\
  case "$ARCH" in \
    amd64) S6_ARCH=x86_64 ;; \
    arm64) S6_ARCH=aarch64 ;; \
    armv7) S6_ARCH=armhf ;; \
    *) S6_ARCH=x86_64 ;; \
  esac &&\
  wget -qO- https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-noarch.tar.xz | tar -C / -Jx &&\
  wget -qO- https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-$S6_ARCH.tar.xz | tar -C / -Jx

# 运行阶段
FROM alpine:latest
ARG TARGETARCH
ENV ARCH=$TARGETARCH

LABEL org.opencontainers.image.title="Nadev Box" \
      org.opencontainers.image.description="Nadev Box container image, based on fscarmen/sing-box" \
      org.opencontainers.image.source="https://github.com/jiajia2222/nadev-box" \
      org.opencontainers.image.licenses="GPL-3.0-or-later"

# 设置工作目录
WORKDIR /sing-box

# 从构建阶段复制 s6-overlay 文件
COPY --from=builder / /

# 复制初始化脚本
COPY docker_init.sh /sing-box/init.sh

# 将 GPL 第三方署名一并带入镜像，便于离线查看
COPY NOTICE.md /usr/share/doc/nadev-box/NOTICE.md

# 安装运行时依赖并生成证书
RUN set -ex &&\
  apk add --no-cache wget nginx bash openssl &&\
  mkdir -p /sing-box/cert /sing-box/conf /sing-box/subscribe /sing-box/logs &&\
  chmod +x /sing-box/init.sh &&\
  rm -rf /var/cache/apk/*

CMD [ "./init.sh" ]
