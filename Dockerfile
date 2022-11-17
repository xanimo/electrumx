# example of Dockerfile that installs xanimo electrumx 1.16.0-3-11-buster
# ENV variables can be overriden on the `docker run` command
ARG VERSION=1.16.0-3-11-buster

FROM python:3.11-buster AS builder

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

COPY Makefile .
COPY contrib/scripts/ ./contrib/scripts/
COPY requirements.txt .
COPY certs/ certs/

RUN apt-get update \
    && apt-get install make
RUN make user
RUN make deps DOCKER=1
RUN make build

RUN mkdir -p ./db  \
    && ulimit -n 1048576 \
    && chown -R ${USER_ID}:${GROUP_ID} ./db

FROM python:3.11-slim-buster

ARG USER
ARG USER_ID
ENV USER_ID=${USER_ID}
ARG GROUP_ID
ENV GROUP_ID=${GROUP_ID}

WORKDIR /home/$USER

COPY --from=builder --chown=$USER_ID:$GROUP_ID /home/$USER .

VOLUME ["./db"]

EXPOSE 50001 50002 50004 8000

CMD ["make run"]

# build it with eg.: `docker build -t electrumx .`
# run it with eg.:
# `docker run -d --net=host -v /home/electrumx/db/:/var/lib/electrumx -e DAEMON_URL="http://youruser:yourpass@localhost:22555" -e REPORT_SERVICES=tcp://example.com:50001 electrumx`
# for a clean shutdown, send TERM signal to the running container eg.: `docker kill --signal="TERM" CONTAINER_ID`
