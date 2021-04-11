#!bin/bash

# chroot /mnt/gentoo /bin/bash

source /etc/profile
export PS1="(chroot) ${PS1}"

mount /dev/sda2 /boot

# sync package and source 
emerge-webrsync

emerge --sync

# update all package
emerge --update --deep --newuse @world
emerge app-editors/vim

# set timezone 
echo "Asia/Tokyo" > /etc/timezone
emerge --config sys-libs/timezone-data

# set locale
echo en_US ISO-8859-1 >> /etc/locale.gen
echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
echo ja_JP.EUC-JP EUC-JP >> /etc/locale.gen
echo ja_JP.UTF-8 UTF-8 >> /etc/locale.gen
echo ja_JP EUC-JP >> /etc/locale.gen

locale-gen

env-update && source /etc/profile && export PS1="(chroot) ${PS1}"

# install kernel
emerge sys-kernel/gentoo-sources

emerge sys-kernel/genkernel

# setting fstab
cat << END >> /etc/fstab
/dev/sda2   /boot        ext2    defaults             0 2
/dev/sda3   none         swap    sw                   0 0
/dev/sda3   /            ext4    noatime              0 1
END

genkernel all

# install firmware
emerge sys-kernel/linux-firmware
