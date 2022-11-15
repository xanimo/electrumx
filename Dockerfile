# example of Dockerfile that installs spesmilo electrumx 1.16.0
# ENV variables can be overriden on the `docker run` command
ARG VERSION=1.16.0

FROM python:3.11-buster AS builder

# configure the shell before the first RUN
SHELL ["/bin/bash", "-ex", "-o", "pipefail", "-c"]

ARG USER=electrumx
ENV USER=$USER
ARG VERSION

RUN git clone -b $VERSION https://github.com/xanimo/electrumx.git /home/$USER

WORKDIR /home/$USER

COPY Makefile .
COPY contrib/scripts/ ./contrib/scripts/
COPY requirements.txt .
COPY certs/ certs/
RUN make deps docker=1

RUN make build

COPY .env .

FROM python:3.11-slim-buster

ARG USER=electrumx
ENV USER=$USER

WORKDIR /home/$USER

RUN useradd $USER \
    && mkdir -p ./db  \
    && ulimit -n 1048576 \
    && chown -R $USER ./db

COPY --from=builder --chown=$USER:$USER /home/$USER .

USER $USER

VOLUME ["/db"]

EXPOSE 50001 50002 50004 8000

CMD ["make run"]

# build it with eg.: `docker build -t electrumx .`
# run it with eg.:
# `docker run -d --net=host -v /home/electrumx/db/:/var/lib/electrumx -e DAEMON_URL="http://youruser:yourpass@localhost:22555" -e REPORT_SERVICES=tcp://example.com:50001 electrumx`
# for a clean shutdown, send TERM signal to the running container eg.: `docker kill --signal="TERM" CONTAINER_ID`
