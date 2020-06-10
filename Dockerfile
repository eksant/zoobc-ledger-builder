####################################################################
# Clone private repo zoobc-ledger-hw using SSH
####################################################################
FROM ubuntu as intermediate
LABEL stage=intermediate
RUN apt-get update && apt-get install -y git

ARG SSH_KEY
RUN mkdir /root/.ssh/ && echo "${SSH_KEY}" >/root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa && touch /root/.ssh/known_hosts
RUN ssh-keyscan github.com >>/root/.ssh/known_hosts

WORKDIR /root/temp
RUN git clone -b hello-zoobc git@github.com:zoobc/zoobc-ledger-hw.git

####################################################################
# How to :
# Build : docker build -t docker-zoobc-s .
# Run : docker run -v `pwd`:/home/workspace -ti docker-ledger-s make
####################################################################
# FROM ubuntu:16.04 AS builder
FROM ubuntu:latest AS builder
LABEL version="0.1.0"
LABEL name="docker-zoobc-ledger"
LABEL maintainer="ZooBC Hardware Team"
LABEL description="The docker image for compiling Ledger Nano S."

####################################################################
# Tool Setup
####################################################################
RUN apt-get update && apt-get -y upgrade && apt-get -y install \
  tar \
  git \
  wget \
  cmake \
  virtualenv \
  build-essential \
  gcc gcc-multilib g++-multilib \
  libc6-i386 libc6-dev-i386 lib32z1 \
  libudev-dev libusb-1.0-0-dev libssl-dev libffi-dev \
  python3 python3-pip python-dev python3-setuptools python3-dev

####################################################################
# Configuration OpenSSL (Optional)
####################################################################
# WORKDIR /usr/include/openssl/
# RUN ln -s /usr/include/gnutls/openssl.h .
# RUN ln -s ../x86_64-linux-gnu/openssl/opensslconf.h .

####################################################################
# BOLOS dev envitonment setup
####################################################################
WORKDIR /
# RUN mkdir -p /bolos-devenv
# WORKDIR /bolos-devenv
# ENV BOLOS_ENV=/bolos-devenv

RUN mkdir /opt/bolos
WORKDIR /opt/bolos

RUN echo "5a261cac18c62d8b7e8c70beba2004bd  gcc-arm-none-eabi-5_3-2016q1-20160330-linux.tar.bz2" >gcc.md5
RUN wget https://launchpad.net/gcc-arm-embedded/5.0/5-2016-q1-update/+download/gcc-arm-none-eabi-5_3-2016q1-20160330-linux.tar.bz2
RUN md5sum -c gcc.md5
RUN tar xjvf gcc-arm-none-eabi-5_3-2016q1-20160330-linux.tar.bz2

RUN wget http://releases.llvm.org/8.0.0/clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz
RUN tar xvf clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz
RUN ln -s clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04 clang-arm-fropi

# RUN echo "78e6401f85a656e1915f189de90a1af8  clang+llvm-4.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz" >clang.md5
# RUN wget https://releases.llvm.org/4.0.0/clang+llvm-4.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz
# RUN md5sum -c clang.md5
# RUN tar xvf clang+llvm-4.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz
# RUN ln -s clang+llvm-4.0.0-x86_64-linux-gnu-ubuntu-16.04 clang-arm-fropi

ENV PATH=/opt/bolos/clang-arm-fropi/bin:/opt/bolos/gcc-arm-none-eabi-5_3-2016q1/bin:$PATH
ENV BOLOS_ENV=/opt/bolos

####################################################################
# BOLOS, Blue or Nano S SDK and Ledgerblue setup
####################################################################
# RUN easy_install3 pip && pip install --upgrade pip setuptools
# RUN pip3 install virtualenv

WORKDIR /
RUN mkdir /zoobc
WORKDIR /zoobc
# RUN git clone https://github.com/LedgerHQ/blue-secure-sdk
RUN git clone https://github.com/LedgerHQ/nanos-secure-sdk
ENV BOLOS_SDK=/zoobc/nanos-secure-sdk

# RUN git clone https://github.com/LedgerHQ/blue-loader-python
# WORKDIR /nanos-secure-sdk
# ENV BOLOS_SDK=/nanos-secure-sdk
# RUN sed -i s/python/python3/g icon.py

# WORKDIR /blue-loader-python
# RUN virtualenv ledger
# RUN . ledger/bin/activate
# RUN pip3 install ledgerblue

WORKDIR /zoobc
RUN pip3 install --upgrade pip
RUN pip3 install pillow
RUN pip3 install git+https://github.com/LedgerHQ/blue-loader-python.git --upgrade
RUN virtualenv -p python3 ledger && . ledger/bin/activate && pip3 install ledgerblue

RUN ls -ltr

####################################################################
# Copy repo from intermediate and compiling the app
####################################################################
WORKDIR /zoobc
RUN alias python=python3
# COPY --from=intermediate /root/temp/zoobc-ledger-hw ./zoobc-ledger-hw

# WORKDIR /zoobc-ledger-hw
# RUN make clean
# RUN make delete
# # RUN make -f Makefile check

# RUN git clone https://github.com/lenondupe/ledger-app-stellar
# WORKDIR /ledger-app-stellar
# RUN make clean
# RUN make load

RUN git clone https://github.com/LedgerHQ/ledger-sample-apps
WORKDIR /zoobc/ledger-sample-apps/blue-app-helloworld
RUN ls -ltr

# RUN make clean
RUN make load
