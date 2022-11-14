# example of Dockerfile that installs spesmilo electrumx 1.16.0
# ENV variables can be overriden on the `docker run` command
ARG VERSION=1.16.0

FROM python:3.11-buster AS builder

# configure the shell before the first RUN
SHELL ["/bin/bash", "-ex", "-o", "pipefail", "-c"]

ARG USER
ENV USER=$USER
ARG VERSION

RUN git clone -b $VERSION https://github.com/xanimo/electrumx.git /home/$USER

WORKDIR /home/$USER

COPY ../scripts /contrib/scripts
COPY requirements.txt .
COPY `pwd`/certs/ ./certs/
RUN if [ -z "$(ls -A ./certs)" ]; then \
        openssl req -x509 -newkey rsa:4096 -nodes -x509 -days 365 -subj "/O=ElectrumX" -keyout /certs/privkey.pem -out /certs/cert.pem -sha256 -days 365; \
    fi

RUN apt-get update && apt-get install -y \
    python-requests \
    gettext \
    libsecp256k1-0 \
    libleveldb-dev \
    python3-cryptography \
    && rm -rf /var/lib/apt/lists/*

RUN python -m venv .venv \
    && source .venv/bin/activate \
    && python -m pip install -r requirements.txt --upgrade \
    && python -m setup build \
    && python -m setup install

COPY .env .

FROM python:3.11-slim-buster

ARG USER
ENV USER=$USER
ARG UID=1001
ENV UID=${UID}
ARG GID=1001
ENV GID=${GID}

WORKDIR /home/$USER

RUN groupadd -g $GID $USER \
    && useradd --uid $UID $USER -g $GID \
    && mkdir -p ./db \
    && ulimit -n 1048576 \
    && chown -R $UID:$GID ./db

COPY --from=builder --chown=$USER:$USER /home/$USER .

USER $USER

VOLUME ["/db"]

EXPOSE 50001 50002 50004 8000

CMD [".venv/bin/python", ".venv/bin/electrumx_server"]

# build it with eg.: `docker build -t electrumx .`
# run it with eg.:
# `docker run -d --net=host -v /home/electrumx/db/:/var/lib/electrumx -e DAEMON_URL="http://youruser:yourpass@localhost:8332" -e REPORT_SERVICES=tcp://example.com:50001 electrumx`
# for a clean shutdown, send TERM signal to the running container eg.: `docker kill --signal="TERM" CONTAINER_ID`
