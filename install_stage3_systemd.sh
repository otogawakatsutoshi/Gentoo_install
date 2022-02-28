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

boot_memory=256
swap_memory=2048
# 256mib /boot
parted -s -a optimal /dev/sda             -- unit mib mkpart "'EFI system partition'" 1   $(( 1 + $boot_memory )) 
# 2048mib swap
parted -s -a optimal /dev/sda             -- unit mib mkpart linux-swap               $(( 1 + $boot_memory )) $(( 1 + $boot_memory + $swap_memory ))
# -1mib
parted -s -a optimal /dev/sda             -- unit mib mkpart rootfs                   $(( 1 + $boot_memory + $swap_memory ))  -1

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

# nicを確認
ip link show

# 下のように使うnicを起動させる。
ip link set wlp2s0b1 up

# net-setupは設定が間違っていても普通にコマンドは通るので
# ping -c 3 8.8.8.8
# で送って確認。
net-setup

# install stage3 

cd /mnt/gentoo
# stage3
wget https://ftp.jaist.ac.jp/pub/Linux/Gentoo/releases/amd64/autobuilds/current-stage3-amd64-desktop-systemd/stage3-amd64-desktop-systemd-20220130T170547Z.tar.xz
# checksum

wget https://ftp.jaist.ac.jp/pub/Linux/Gentoo/releases/amd64/autobuilds/current-stage3-amd64-desktop-systemd/stage3-amd64-desktop-systemd-20220130T170547Z.tar.xz.DIGESTS
wget https://ftp.jaist.ac.jp/pub/Linux/Gentoo/releases/amd64/autobuilds/current-stage3-amd64-desktop-systemd/stage3-amd64-desktop-systemd-20220130T170547Z.tar.xz.CONTENTS.gz

# 失敗した時の出戻りが大きいからチェック
# checksum

sha512sum -c < stage3-amd64-desktop-systemd-20220220T170542Z.tar.xz.DIGESTS

tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
# if you use systemd and stage3 desktop, /mnt/gentoo disk size 2.8G
# /mnt/gentoo is tmpfs, boot diside
# ぶーたぶるusbから起動時に自動的にpcのramの半分の値がtmpfsの値になるため、
# memory 4Gなら半分の2Gだけ使われるので、tarの展開に失敗する。
# df -h で使われているtmpfsの量が確認できる。
# その場合は動的にtmpfsの量を変更すると良い。
# [tmpfs]https://wiki.archlinux.jp/index.php/Tmpfs
# tmpfsがroot ディレクトリのとき。
# mount -o remount,size=3G,noatime /
# これだと展開はできるが、のちのemerge-webrsyncで容量不足になるため下のようにする。
# mount -o remount,size=3584M,noatime /
# メモリが8G未満だと問題が起きる。

# systemd-amd64だけだと/は1.2GBで済む。がやはり、webrsyncでスペースが足りなくなる。
# mount -o remount,size=3G,noatime /

# systemd-amd64-desktopだとtmpfsに8Gあってもgenkernel all
# とカーネルを自動でコンパイルした時点で8Gでも足りなくなる。
# 

rm -rf *.tar.xz

# add mirror
# echo GENTOO_MIRRORS=\"https://ftp.jaist.ac.jp/pub/Linux/Gentoo/ rsync://ftp.jaist.ac.jp/pub/Linux/Gentoo/ https://ftp.riken.jp/Linux/gentoo/ rsync://ftp.riken.jp/gentoo/\" >> /mnt/gentoo/etc/portage/make.conf

mirrorselect -i -o >> /mnt/gentoo/etc/portage/make.conf

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
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run
