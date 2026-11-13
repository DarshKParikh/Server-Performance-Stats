FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash procps coreutils gawk && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY server-stats.sh /app/server-stats.sh

RUN chmod +x /app/server-stats.sh

ENTRYPOINT ["/app/server-stats.sh"]
