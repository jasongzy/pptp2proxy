FROM alpine:latest

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk add --no-cache pptpclient 3proxy iproute2 bash curl perl iptables kmod util-linux tzdata \
    && rm -rf /var/cache/apk/*

COPY --chmod=755 entrypoint.sh /entrypoint.sh
COPY --chmod=755 ip-up.sh /etc/ppp/ip-up.local

EXPOSE 1080 8888

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD (ip link show ppp0 > /dev/null && nc -z 127.0.0.1 8888 && nc -z 127.0.0.1 1080) || exit 1

ENTRYPOINT ["/entrypoint.sh"]
