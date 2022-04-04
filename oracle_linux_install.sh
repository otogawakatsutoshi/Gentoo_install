#!bin/bash

# [debian 参考](https://www.debian.org/releases/bullseye/amd64/apds03.ja.html)
# ホスト側でdebootstrapをインストールしておく。

# dnfはrhel系以外ならarch系にcommunityでインストールできる。
# 

# cat << END >> /etc/yum.repos.d/oracle_linux.repo
# [oracle_linux]
# name=oracle_linux $releasever - Base
# baseurl=https://yum.oracle.com/repo/OracleLinux/OL$releasever/baseos/latest/$basearch/
# gpgkey=https://yum.oracle.com/RPM-GPG-KEY-oracle-ol$releasever
# END

mkdir /mnt/oracle_linux
mount /dev/sdb4 /mnt/oracle_linux

https://blue-red.ddo.jp/~ao/wiki/wiki.cgi?page=Fedora5+%A4%CE+yum+%A4%CE%A5%EA%A5%DD%A5%B8%A5%C8%A5%EA%A4%F2%CA%D1%B9%B9%A4%B9%A4%EB
repourl=https://ftp.jp.debian.org/debian

ARCH=x86_64
version=8
dnf install --installroot=/mnt/oracle_linux --repo=oracle_linux --releasever=$version oracle-release-el${version} systemd dnf

echo 'nameserver 8.8.8.8' >> /etc/resolv.conf

# /etc/fstabはdebianは手動で作る方針なので、マルチブートならコピーして流用が簡単
# マウントするデバイスは帰ること。
# cp /etc/fstab /mnt/debian/etc/

# chroot
mount --types proc /proc /mnt/oracle_linux/proc
mount --rbind /sys /mnt/oracle_linux/sys
mount --make-rslave /mnt/oracle_linux/sys
mount --rbind /dev /mnt/oracle_linux/dev
mount --make-rslave /mnt/oracle_linux/dev
mount --bind /run /mnt/oracle_linux/run
mount --make-slave /mnt/oracle_linux/run
