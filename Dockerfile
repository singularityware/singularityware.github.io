FROM ubuntu:17.04
ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /opt
RUN apt-get update -qq \
    && apt-get install -yq --no-install-recommends autoconf \
                                                   automake \
                                                   g++ \
                                                   gcc \
                                                   ca-certificates \
                                                   git \
                                                   libtool \
                                                   make \
                                                   python \
                                                   sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && git clone https://github.com/singularityware/singularity.git \
    && cd singularity \
    && ./autogen.sh \
    && ./configure --prefix=/usr/local \
    && make \
    && sudo make install \
    && rm -rf /opt/singularity \
    && apt-get purge -yq --auto-remove autoconf automake g++ gcc git make

WORKDIR /home
