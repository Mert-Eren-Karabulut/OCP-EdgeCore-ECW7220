# Build Linux kernel
```
docker build -t ocp .
docker run -v `pwd`/opt:/opt -it ocp
```

folder './opt' should contain compiled binary files:
```
bcm4708-edgecore-ecw7220-l.dtb
uImage
squashfs.ubi
```

folder 'linux-stable' is a full Linux kernel tree used for compilation.

#building under OSx

default Mac filesystem is case-insensitive and not compatible with OpenWRT build system.
So, we need to make case-sensitive volume and build inside this volume. Here is a commands
to do this:

```
docker build -t ocp .
hdiutil create -size 20g -fs "Case-sensitive HFS+" -volname OpenWrt OpenWrt.dmg
hdiutil attach OpenWrt.dmg
cd /Volumes/OpenWrt
docker run -v `pwd`/opt:/opt -it ocp
```

#Flashing OpenWRT rootfs+ubifs to AP

Copy binary files (squashfs.ubi, bcm4708-edgecore-ecw7220-l.dtb, uImage) to TFTP server directory and boot AP to u-boot shell.
Then issue following commands in u-boot shell (do not type 'u-boot> ' part, replace 192.168.1.121 to IP-address of your TFTP server):

```
u-boot> tftpboot 0x82000000 192.168.1.121:squashfs.ubi
u-boot> nand erase 0x01080000 0x06F80000
u-boot> nand write 0x82000000 0x01080000 0x06F80000
u-boot> tftpboot 0x80000000 192.168.1.121:bcm4708-edgecore-ecw7220-l.dtb
u-boot> tftpboot 0x82007FC0 192.168.1.121:uImage
u-boot> bootm 0x82007FC0
```

here is a console output if everything is ok:
```
[    0.000000] Linux version 4.9.5-g7954d9c (root@009042690e3e) (gcc version 5.4.0 20160609 (Ubuntu/Linaro 5.4.0-6ubuntu1~16.04.4) ) #1 SMP Wed Feb 1 07
...
[    0.003188] Brought up 2 CPUs
...
[    3.691725] ubi0: attaching mtd6
[    4.122890] random: crng init done
[    4.294440] ubi0: scanning is finished
[    4.320166] gluebi (pid 1): gluebi_resized: got update notification for unknown UBI device 0 volume 1
[    4.329426] ubi0: volume 1 ("rootfs_data") re-sized from 9 to 830 LEBs
[    4.336515] ubi0: attached mtd6 (name "ubi_rootfs", size 111 MiB)
[    4.342644] ubi0: PEB size: 131072 bytes (128 KiB), LEB size: 126976 bytes
[    4.349542] ubi0: min./max. I/O unit sizes: 2048/2048, sub-page size 2048
[    4.356357] ubi0: VID header offset: 2048 (aligned 2048), data offset: 4096
[    4.363345] ubi0: good PEBs: 892, bad PEBs: 0, corrupted PEBs: 0
[    4.369368] ubi0: user volume: 2, internal volumes: 1, max. volumes count: 128
[    4.376610] ubi0: max/mean erase counter: 0/0, WL threshold: 4096, image sequence number: 1693157896
[    4.385766] ubi0: available PEBs: 0, total reserved PEBs: 892, PEBs reserved for bad PEB handling: 20
[    4.395024] ubi0: background thread "ubi_bgt0d" started, PID 95
...
BusyBox v1.24.2 () built-in shell (ash)

  _______                     ________        __
|       |.-----.-----.-----.|  |  |  |.----.|  |_
|   -   ||  _  |  -__|     ||  |  |  ||   _||   _|
|_______||   __|_____|__|__||________||__|  |____|
|__| W I R E L E S S   F R E E D O M
-----------------------------------------------------
DESIGNATED DRIVER (Bleeding Edge, 12009)
-----------------------------------------------------
* 2 oz. Orange Juice         Combine all juices in a
* 2 oz. Pineapple Juice      tall glass filled with
* 2 oz. Grapefruit Juice     ice, stir well.
* 2 oz. Cranberry Juice
-----------------------------------------------------
root@OpenWrt:/#
```
