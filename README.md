#**Important Note**

In order to crosscompile required linux kernel, ```*ECW7220l_defconfig*``` file is mandatory. This file isn't coming by default with any linux kernel build mainly because its custom written for this device. So I will provide this file seperately so you can crosscompile required files with any linux kernel. Since the device is built on arm architecture this file must be found on ```/arch/arm/configs``` directory in linux kernel.

Docker container automatically runs ```endpoint.sh``` file thus commands are in this file. Provided linux kernel is fairly old but works great without any problems. You can try to compile with newer kernel but you may need to make changes on ```*ECW7220l_defconfig*``` file to do so. Current and provided ```endpoint.sh``` will download vanilla linux kernel and then copy ```*ECW7220l_defconfig*``` file to its required directory by default. 

If the given link for linux kernel in endpoint.sh is discontiuned or not available you can find another repo and replace the link in ```endpoint.sh``` before running the commands. **Don't forget to place ```*ECW7220l_defconfig*``` file to required directory before starting the crosscompile proccess.***

#**Compiling in Ubuntu shell for Windows (Ubuntu WSL)**
Since docker doesn't completely support Ubuntu WSL, compiling under Ubuntu WSL is not possible without some tricks. It's not impossible but you need to deal with every error you encountered and find the required patchs. I tried to run commands in Ubuntu WSL version 1 but there were so many errors so I gave up on that. Issues may have been resolved since the version 2 of Ubuntu WSL.


# Building in linux

Along the building and compiling proccess shell may can ask you for some dependencies. Docker container includes all the dependencies required by the time that this guide is written but in future change in some  dependency names can result conflicts. If this is the case for you try to manually install all the dependencies along the building proccess.

```
docker build -t ocp .
docker run -v `pwd`/opt:/opt -it ocp
```

folder './opt' should contain compiled files:
```
bcm4708-edgecore-ecw7220-l.dtb
uImage
squashfs.ubi
```
'linux' folder is the linux kernel fork used for building. 

#Flashing OpenWRT rootfs+ubifs partitions to AP

**In order to flash files to AP we need to deploy a TFTP server in our computer. Afterwards AP will fetch required files from that server so its mandatory. There are free TFTP server applications for both Windows and Linux. After deploying TFTP server, set a root directory.**

Copy the files (squashfs.ubi, bcm4708-edgecore-ecw7220-l.dtb, uImage) to TFTP server root directory and boot AP to u-boot shell.
**In order to boot AP to u-boot you need to connect to serial terminal of AP. After device is powered on you must see the line that asks you if you want to continue with normal boot or U-Boot. Interrupt the normal booting progress by sending any letter over serial.**

Then issue following commands in u-boot shell (do not type 'u-boot> ' part, replace 192.168.1.50 to IP-address of your TFTP server):

```
u-boot> tftpboot 0x82000000 192.168.1.50:squashfs.ubi
u-boot> nand erase 0x01080000 0x06F80000
u-boot> nand write 0x82000000 0x01080000 0x06F80000
u-boot> tftpboot 0x80000000 192.168.1.50:bcm4708-edgecore-ecw7220-l.dtb
u-boot> tftpboot 0x82007FC0 192.168.1.50:uImage
u-boot> bootm 0x82007FC0
```

console output must look like this if everything is ok:
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

**I have also provided compiled files in the folder *_Compiled_*. Since building Arm64 kernel can take long you can use already compiled files. Take the files and continue from the U-boot sequences above.**
