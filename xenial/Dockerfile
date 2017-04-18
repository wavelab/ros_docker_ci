FROM ubuntu:xenial

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

ENV CONTINUOUS_INTEGRATION true

RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    make \
    gcc \
    g++ \
    locales \
    wget \
    software-properties-common \
    sudo 

ADD /scripts /scripts

RUN bash /scripts/install_deps_for_docker_ci.bash

