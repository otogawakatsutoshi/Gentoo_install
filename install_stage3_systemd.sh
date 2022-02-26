#!/bin/bash

# [install cookbook](https://wiki.gentoo.org/wiki/Handbook:AMD64)

# Model: BUFFALO USB Flash Disk (scsi)
# Disk /dev/sdd: 8097MB
# Sector size (logical/physical): 512B/512B
# Partition Table: msdos
# Disk Flags: 

# Number  Start   End     Size    Type     File system  Flags
#  1      4194kB  8096MB  8092MB  primary  fat32


# 512byte=1sector
# 1mib=1024byte

# create partition for BIOS
parted -s -a optimal /dev/sda mklabel msdos -- unit mib mkpart primary 1     3 name 1 grub set 1 bios_grub on
parted -s -a optimal /dev/sda             -- unit mib mkpart primary 3   259 name 2 boot set 2 boot on
parted -s -a optimal /dev/sda             -- unit mib mkpart primary 259 771 name 3 swap set 3 swap on
parted -s -a optimal /dev/sda             -- unit mib mkpart primary 771  -1 name 4 rootfs

# create partition for UEFI
parted -s -a optimal /dev/sda mklabel gpt -- unit mib mkpart primary            1     3 name 1 grub set 1 bios_grub on
parted -s -a optimal /dev/sda             -- unit mib mkpart ESP     fat32      3   259 name 2 "EFI System Partition" set 2 esp on
parted -s -a optimal /dev/sda             -- unit mib mkpart primary linux-swap 259 771 name 3 linux-swap set 3 swap on
parted -s -a optimal /dev/sda             -- unit mib mkpart primary ext4       771  -1 name 4 rootfs

parted -s -a optimal /dev/sda mklabel gpt
parted -s -a optimal /dev/sda             -- unit mib mkpart ESP     fat32      2   258 name 1 "EFI System Partition" set esp on
parted -s -a optimal /dev/sda             -- unit mib mkpart primary linux-swap 258 770 name 2 linux-swap set swap on
parted -s -a optimal /dev/sda             -- unit mib mkpart primary ext4       770  -1 name 3 rootfs

# 256mib /boot
parted -s -a optimal /dev/sda             -- unit mib mkpart "'EFI system partition'" 1   257 
# 2048mib swap
parted -s -a optimal /dev/sda             -- unit mib mkpart linux-swap               257 2305
# -1mib
parted -s -a optimal /dev/sda             -- unit mib mkpart rootfs                   2305  -1

parted -s -a optimal /dev/sda set 1 esp on
parted -s -a optimal /dev/sda set 2 swap on

# uefi
mkfs.vfat -F 32 /dev/sda1

# bios
# mkfs.ext3 /dev/sda1

mkswap    /dev/sda2
swapon    /dev/sda2
mkfs.ext4 /dev/sda3

# create file system
# mkfs.ext2 /dev/sda2
# mkswap    /dev/sda3
# mkfs.ext4 /dev/sda4

# print partition list
parted -s -a optimal /dev/sda p

# install stage3 

cd /mnt/gentoo
wget https://ftp.jaist.ac.jp/pub/Linux/Gentoo/releases/amd64/autobuilds/current-stage3-amd64-desktop-systemd/stage3-amd64-desktop-systemd-20220130T170547Z.tar.xz

tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner

rm -rf *.tar.xz

# add mirror
# echo GENTOO_MIRRORS=\"https://ftp.jaist.ac.jp/pub/Linux/Gentoo/ rsync://ftp.jaist.ac.jp/pub/Linux/Gentoo/ https://ftp.riken.jp/Linux/gentoo/ rsync://ftp.riken.jp/gentoo/\" >> /mnt/gentoo/etc/portage/make.conf

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
