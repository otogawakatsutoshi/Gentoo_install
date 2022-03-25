#!bin/bash

# [debian 参考](https://www.debian.org/releases/bullseye/amd64/apds03.ja.html)
# ホスト側でdebootstrapをインストールしておく。

# dnfはrhel系以外ならarch系にcommunityでインストールできる。

mkdir /mnt/centos
mount /dev/sdb4 /mnt/centos

https://blue-red.ddo.jp/~ao/wiki/wiki.cgi?page=Fedora5+%A4%CE+yum+%A4%CE%A5%EA%A5%DD%A5%B8%A5%C8%A5%EA%A4%F2%CA%D1%B9%B9%A4%B9%A4%EB
repourl=https://ftp.jp.debian.org/debian

ARCH=amd64
version=35
dnf --installroot=/mnt/centos -releasever=$version centos-stream-release systemd

# /etc/fstabはdebianは手動で作る方針なので、マルチブートならコピーして流用が簡単
# マウントするデバイスは帰ること。
# cp /etc/fstab /mnt/debian/etc/

# chroot
mount --types proc /proc /mnt/fedora/proc
mount --rbind /sys /mnt/fedora/sys
mount --make-rslave /mnt/fedora/sys
mount --rbind /dev /mnt/fedora/dev
mount --make-rslave /mnt/fedora/dev
mount --bind /run /mnt/fedora/run
mount --make-slave /mnt/fedora/run
