#!/bin/bash

# [install cookbook](https://wiki.gentoo.org/wiki/Handbook:AMD64)

# create partition
parted -s -a optimal /dev/sda mklabel gpt -- unit mib mkpart primary 1     3 name 1 grub set 1 bios_grub on
parted -s -a optimal /dev/sda             -- unit mib mkpart primary 3   131 name 2 boot set 2 boot on
parted -s -a optimal /dev/sda             -- unit mib mkpart primary 131 643 name 3 swap set 3 swap on
parted -s -a optimal /dev/sda             -- unit mib mkpart primary 643  -1 name 4 rootfs

# create file system
mkfs.ext2 /dev/sda2
mkswap    /dev/sda3
mkfs.ext4 /dev/sda4

# print partition list
parted -s -a optimal /dev/sda p

# install stage3 

cd /mnt/gentoo
wget https://ftp.jaist.ac.jp/pub/Linux/Gentoo/releases/amd64/autobuilds/current-stage3-amd64-systemd/stage3-amd64-systemd-20210407T214504Z.tar.xz

tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner

rm -rf *.tar.xz

# add mirror
echo GENTOO_MIRRORS=\"https://ftp.jaist.ac.jp/pub/Linux/Gentoo/ rsync://ftp.jaist.ac.jp/pub/Linux/Gentoo/ https://ftp.riken.jp/Linux/gentoo/ rsync://ftp.riken.jp/gentoo/\" >> /mnt/gentoo/etc/portage/make.conf

# create ebuild repository
mkdir --parents /mnt/gentoo/etc/portage/repos.conf

cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf

# DNS 情報
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

# mount
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
