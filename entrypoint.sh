#!/bin/bash
set -e

cd /opt

# Build OpenWRT
if [ ! -d "openwrt" ]; then
	git clone --depth=1 https://github.com/aospan/openwrt.git
fi

cd openwrt

if [ ! -f ".config" ]; then
	cp /openwrt.config ./.config
	FORCE=1 make defconfig
fi

FORCE_UNSAFE_CONFIGURE=1 FORCE=1 make -j"$(nproc)"
PATH=$PATH:./staging_dir/host/bin/ ./scripts/ubinize-image.sh ./build_dir/target-arm_cortex-a9_musl-1.1.16_eabi/linux-bcm53xx/root.squashfs /opt/squashfs.ubi -p 128KiB -m 2048 -E 5

cd /opt
# Build Linux kernel
if [ ! -d "linux-stable" ]; then
    git clone --depth=1 -b ocp-linux-4.9.y https://github.com/aospan/linux-stable.git
fi

cd linux-stable 

if [ ! -f ".config" ]; then
	make -j"$(nproc)" LOADADDR=0x82008000 ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- ecw7220l_defconfig
fi

time make -j"$(nproc)" LOADADDR=0x82008000 ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- uImage
make -j"$(nproc)" LOADADDR=0x82008000 ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- arch/arm/boot/dts/

#copy result to /opt
cp arch/arm/boot/uImage /opt/
cp arch/arm/boot/dts/bcm4708-edgecore-ecw7220-l.dtb /opt/
