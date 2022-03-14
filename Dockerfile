FROM postgrest/postgrest:latest as postgrest

FROM debian:bullseye

ARG DEBIAN_FRONTEND=noninteractive

# Update nodejs version to 17.x
RUN apt-get update && apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_17.x | bash -

RUN apt-get update && apt-get install -y \
    nodejs \
    node-typescript \
    jq \
    && rm -rf /var/lib/apt/lists/*

COPY --from=postgrest /bin/postgrest /bin/postgrest

WORKDIR /usr/src/app

COPY ./postgrest-proxy.js ./
COPY ./package.json ./
COPY ./package-lock.json ./

RUN npm install --no-fund --no-update-notifier

COPY start.sh ./

ENV PGRST_DB_URI=postgres://docker:docker@db.openbalena.local:5432
ENV PGRST_DB_SCHEMA=public
ENV PGRST_DB_ANON_ROLE=anon
ENV PGRST_SERVER_HOST=127.0.0.1

CMD ["bash", "start.sh"]