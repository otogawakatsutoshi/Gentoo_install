#/bin/bash

# [install cookbook](https://wiki.gentoo.org/wiki/Handbook:AMD64)


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

mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev

chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) ${PS1}"

mount /dev/sda1 /boot

# sync package and source 
emerge-webrsync

# update all package
emerge --update --deep --newuse @world
emerge app-editors/vim

# set timezone 
echo "Asia/Tokyo" > /etc/timezone
emerge --config sys-libs/timezone-data

# set locale
# locale-gen

echo en_US ISO-8859-1 >> /etc/locale.gen
echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
echo ja_JP.EUC-JP EUC-JP >> /etc/locale.gen
echo ja_JP.UTF-8 UTF-8 >> /etc/locale.gen
echo ja_JP EUC-JP >> /etc/locale.gen

env-update && source /etc/profile && export PS1="(chroot) ${PS1}"

# install kernel
emerge sys-kernel/gentoo-sources

emerge sys-kernel/genkernel


echo "/dev/sda1	/boot	ext2	defaults	0 2"  >> /etc/fstab
genkernel all

# install firmware
emerge sys-kernel/linux-firmware
