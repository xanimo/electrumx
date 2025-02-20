# example of Dockerfile that installs xanimo electrumx 1.16.0-3-11-buster
# ENV variables can be overriden on the `docker run` command
ARG VERSION=1.16.0-bullseye-slim

FROM debian:bullseye-slim

# configure the shell before the first RUN
SHELL ["/bin/bash", "-ex", "-o", "pipefail", "-c"]

ARG USER_ID
ENV USER_ID=${USER_ID}
ARG GROUP_ID
ENV GROUP_ID=${GROUP_ID}
ARG USERNAME=electrumx
ENV USER=${USERNAME}
ENV PLATFORM="docker"
ARG VERSION
ARG REPO

COPY . /home/$USER
RUN if [ "$REPO" == "remote" ]; then rm -rf /home/$USER && git clone -b $VERSION https://github.com/xanimo/electrumx.git /home/$USER; fi

WORKDIR /home/$USER

COPY .env ./
COPY Makefile ./
COPY contrib/scripts/ ./contrib/scripts/
COPY requirements.txt ./
COPY certs/cert.pem /etc/ssl/certs/cert.pem
COPY certs/privkey.pem /etc/ssl/certs/privkey.pem

RUN apt-get update \
    && apt-get install -y git make gcc
RUN make user
RUN make build

RUN mkdir -p ./db  \
    && chown -R ${USER_ID}:${GROUP_ID} ./db


ENV SSL_KEYFILE=/etc/ssl/certs/privkey.pem
ENV SSL_CERTFILE=/etc/ssl/certs/certs.pem

VOLUME ["./db"]

EXPOSE 50001 50002 50004 8000

ENTRYPOINT ["./contrib/scripts/entrypoint"]
CMD ["./contrib/scripts/run"]

# build it with eg.: `docker build -t electrumx .`
# run it with eg.:
# `docker run -d --net=host -v /home/electrumx/db/:/var/lib/electrumx -e DAEMON_URL="http://youruser:yourpass@localhost:22555" -e REPORT_SERVICES=tcp://example.com:50001 electrumx`
# for a clean shutdown, send TERM signal to the running container eg.: `docker kill --signal="TERM" CONTAINER_ID`
