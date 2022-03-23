#!bin/bash

# [debian 参考](https://www.debian.org/releases/bullseye/amd64/apds03.ja.html)
# ホスト側でdebootstrapをインストールしておく。

mkdir /mnt/debian
mount /dev/sdb4 /mnt/debian

repourl=https://ftp.jp.debian.org/debian

ARCH=amd64
version=bullseye
debootstrap --arch $ARCH $version /mnt/debinst $repourl

# /etc/fstabはdebianは手動で作る方針なので、マルチブートならコピーして流用が簡単
# マウントするデバイスは帰ること。
# cp /etc/fstab /mnt/debian/etc/

# chroot
mount --types proc /proc /mnt/debian/proc
mount --rbind /sys /mnt/debian/sys
mount --make-rslave /mnt/debian/sys
mount --rbind /dev /mnt/debian/dev
mount --make-rslave /mnt/debian/dev
mount --bind /run /mnt/debian/run
mount --make-slave /mnt/debian/run
