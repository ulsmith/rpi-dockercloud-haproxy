FROM hypriot/rpi-alpine-scratch

COPY . /haproxy-src

# BASE SETUP
RUN apk update && \
    apk add make cmake haproxy py-pip build-base python-dev ca-certificates && \
    cp /haproxy-src/reload.sh /reload.sh && \
    cd /haproxy-src && \
    pip install -r requirements.txt && \
    pip install .

# BUILD TINI
ENV TINI_VERSION 0.9.0
ADD https://github.com/krallin/tini/archive/v${TINI_VERSION}.tar.gz /tini/v${TINI_VERSION}.tar.gz
RUN tar -zxvf /tini/v${TINI_VERSION}.tar.gz -C /tini
WORKDIR /tini/tini-${TINI_VERSION}
RUN export CFLAGS="-DPR_SET_CHILD_SUBREAPER=36 -DPR_GET_CHILD_SUBREAPER=37" && \
    cmake . && make && \
    cp tini /sbin/tini && chmod +x /sbin/tini
WORKDIR /

# CEANUP
RUN apk del build-base make cmake python-dev && \
    rm -rf "/tini" "/tmp/*" "/root/.cache" `find / -regex '.*\.py[co]'`

# OTHER
ENV RSYSLOG_DESTINATION=127.0.0.1 \
    MODE=http \
    BALANCE=roundrobin \
    MAXCONN=4096 \
    OPTION="redispatch, httplog, dontlognull, forwardfor" \
    TIMEOUT="connect 5000, client 50000, server 50000" \
    STATS_PORT=1936 \
    STATS_AUTH="stats:stats" \
    SSL_BIND_OPTIONS=no-sslv3 \
    SSL_BIND_CIPHERS="ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:AES128-GCM-SHA256:AES128-SHA256:AES128-SHA:AES256-GCM-SHA384:AES256-SHA256:AES256-SHA:DHE-DSS-AES128-SHA:DES-CBC3-SHA" \
    HEALTH_CHECK="check inter 2000 rise 2 fall 3"

EXPOSE 80 443 1936
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["dockercloud-haproxy"]
