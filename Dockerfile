# Dockerfile for bitcore-dash-nu

# alpha - unoptimized

FROM phusion/baseimage:0.9.19
MAINTAINER nubitcore <nubitcore@github.io>
LABEL description="dockerized nubitcore/insight-api"

# replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Set debconf to run non-interactively
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# update base
RUN apt-get update \
    && apt-get upgrade -y -q \
    && apt-get install -y -q \
        build-essential \
        curl \
        git \
        libzmq3-dev \
        python2.7 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && ln -s /usr/bin/python2.7 /usr/bin/python

# install dashd 12.1 compile prerequisites
RUN apt-get update \
    && apt-get install -y -q software-properties-common \
    && add-apt-repository ppa:bitcoin/bitcoin \
    && apt-get update \
    && apt-get install -y -q \
        automake \
        autotools-dev \
        bsdmainutils \
        build-essential \
        libboost-all-dev \
        libdb4.8-dev \
        libdb4.8++-dev \
        libevent-dev \
        libssl-dev \
        libtool \
        pkg-config \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# compile dashd 12.1
RUN cd /tmp \
    && git clone https://github.com/nubitcore/dash -b v0.12.1.x \
    && cd dash \
    && git reset --hard d368bc84c84209ef27281bea32c30f0df890490c \
    && ./autogen.sh \
    && ./configure \
    && make

# copy compiled nud 12.1, delete source
RUN cp /tmp/dash/src/{dashd,dash-cli} /usr/bin \
    && rm -rf /tmp/dash

# setup and switch to user bitcore
RUN /usr/sbin/useradd -s /bin/bash -m -d /bitcore bitcore \
  && chown bitcore:bitcore -R /bitcore
USER bitcore
ENV HOME /bitcore

# install npm/node
ENV NODE_VERSION 5.0.0
ENV NVM_VERSION 0.31.2
ENV NVM_DIR $HOME/.nvm
RUN curl https://raw.githubusercontent.com/creationix/nvm/v$NVM_VERSION/install.sh | bash \
    && source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# install bitcore-node
RUN cd $HOME \
    && source $NVM_DIR/nvm.sh \
    && nvm use v5.0.0 \
    && mkdir -p $HOME/.bitcore/data \
    && ln -s /usr/bin/dashd $HOME/.bitcore/data \
    && npm install -g bitcore-node-dash \
    && bitcore-node-dash create dash-node -d $HOME/.bitcore/data \
    && cd dash-node \
    && bitcore-node-dash install insight-api-dash

# build launch wrapper until I figure out how to source nvm envs through CMD
RUN cd $HOME \
    && echo "#!/bin/bash" >> launch_bitcore-node.sh \
    && echo "source $NVM_DIR/nvm.sh" >> launch_bitcore-node.sh \
    && echo "cd $HOME/dash-node" >> launch_bitcore-node.sh \
    && echo "bitcore-node-dash start" >> launch_bitcore-node.sh \
    && chmod a+x launch_bitcore-node.sh

EXPOSE 3001

VOLUME ["$HOME/.bitcore"]

CMD ["/bitcore/launch_bitcore-node.sh"]
