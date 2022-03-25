#!bin/bash

# [debian 参考](https://www.debian.org/releases/bullseye/amd64/apds03.ja.html)
# ホスト側でdebootstrapをインストールしておく。

# dnfはrhel系以外ならarch系にcommunityでインストールできる。
# 

# cat << END >> /etc/yum.repos.d/fedora.repo
# [fedora]
# name=fedora-server $releasever - Base
# baseurl=http://ftp.riken.jp/pub/Linux/centos/$releasever-stream/BaseOS/$basearch/os
# gpgkey=http://ftp.riken.jp/pub/Linux/centos/RPM-GPG-KEY-CentOS-Official
# END

mkdir /mnt/centos
mount /dev/sdb4 /mnt/centos

https://blue-red.ddo.jp/~ao/wiki/wiki.cgi?page=Fedora5+%A4%CE+yum+%A4%CE%A5%EA%A5%DD%A5%B8%A5%C8%A5%EA%A4%F2%CA%D1%B9%B9%A4%B9%A4%EB
repourl=https://ftp.jp.debian.org/debian

ARCH=amd64
version=8
dnf --installroot=/mnt/centos --repo fedora --releasever=$version centos-stream-release systemd dnf 

echo 'nameserver 8.8.8.8' >> /etc/resolv.conf

# /etc/fstabはdebianは手動で作る方針なので、マルチブートならコピーして流用が簡単
# マウントするデバイスは帰ること。
# cp /etc/fstab /mnt/debian/etc/

# chroot
mount --types proc /proc /mnt/centos/proc
mount --rbind /sys /mnt/centos/sys
mount --make-rslave /mnt/centos/sys
mount --rbind /dev /mnt/centos/dev
mount --make-rslave /mnt/centos/dev
mount --bind /run /mnt/centos/run
mount --make-slave /mnt/centos/run
