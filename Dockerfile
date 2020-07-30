FROM ubuntu:16.04

# install required packages
RUN apt-get -y update && apt-get install -y build-essential libncurses5-dev gcc-arm-linux-gnueabi \
	git-core bc u-boot-tools vim time tftpd-hpa tftp net-tools \
	libssl-dev unzip gawk zlib1g-dev wget python subversion bsdmainutils

WORKDIR /opt
COPY openwrt.config /openwrt.config
COPY entrypoint.sh /entrypoint.sh
CMD /entrypoint.sh
