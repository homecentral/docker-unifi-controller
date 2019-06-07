FROM ubuntu:xenial

ARG UNIFI_VERSION=5.6.42
ARG DEBIAN_FRONTEND="noninteractive"

RUN printf "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d && \
    apt-get update && \
    apt-get install -y gnupg && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6

ADD https://dl.ubnt.com/unifi/$UNIFI_VERSION/unifi_sysvinit_all.deb /unifi.deb

RUN echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" >> /etc/apt/sources.list.d/mongo.list
RUN export RUNLEVEL=1 && \
    apt-get update && \ 
    apt-get install -y binutils jsvc mongodb-org-server openjdk-8-jre-headless libcap2 && \
    dpkg -i /unifi.deb && \
    rm /unifi.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/lib/unifi

VOLUME [ "/data" ]

# 8443 is excluded on purpose, the UI should be exposed ONLY through the proxy
EXPOSE 8080 8081 8843 8880

ENTRYPOINT [ "java", "-jar", "/usr/lib/unifi/lib/ace.jar", "start" ]