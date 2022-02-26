#!bin/bash

# chroot /mnt/gentoo /bin/bash

source /etc/profile
export PS1="(chroot) ${PS1}"

mount /dev/sda2 /boot

# sync package and source 
emerge-webrsync

# もし必要なら。メモリ足りてないなら使わんほうがいい。
# This setting is optional.
# if you error 
# 'Your current profile is invalid.'
# emerge --sync --quiet

# stage3 などに対して適切なprofileか確認。
eselect profile list

# update all package
emerge --update --deep --newuse @world
emerge app-editors/vim

echo "# set default editor for root." >> /root/.bashrc
echo "export EDITOR=$(command -v vim)" >> /root/.bashrc

# set timezone 
# echo "Asia/Tokyo" > /etc/timezone
# emerge --config sys-libs/timezone-data

# set locale
echo en_US ISO-8859-1 >> /etc/locale.gen
echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
# echo ja_JP.EUC-JP EUC-JP >> /etc/locale.gen
echo ja_JP.UTF-8 UTF-8 >> /etc/locale.gen
# echo ja_JP EUC-JP >> /etc/locale.gen

locale-gen

eselect locale list | grep en_US.utf8 | 
eselect locale set 

env-update && source /etc/profile && export PS1="(chroot) ${PS1}"

# graphic cardなどあるかないかわからないデバイスなどは
# kernelをインストールするまえに入れておいたほうが良い。
# install firmware
emerge sys-kernel/linux-firmware

# メモリーが足りない場合はこれと
# 無線wifiのビルドをやめて、後でインストールしても良い。
# 

# これがないとwifi,仮想環境などカーネル
# に依存した機能のビルドで失敗する
# install kernel
emerge sys-kernel/gentoo-sources

# ここは任意
emerge sys-kernel/genkernel
genkernel all

# setting for bios
cat << END >> /etc/fstab
/dev/sda1   /boot        ext2    defaults             0 2
/dev/sda2   none         swap    sw                   0 0
/dev/sda3   /            ext4    noatime              0 1
END

# setting for UEFI
cat << END >> /etc/fstab
/dev/sda1   /boot        vfat    defaults             0 2
/dev/sda2   none         swap    sw                   0 0
/dev/sda3   /            ext4    noatime              0 1
END


# network setting
# dhcp client
# しなくてもいい設定のはず。
# メモリ少なかったら後回しにする。
# 手動で設定できるはず。
# emerge net-misc/dhcpcd

# timedatectl Asia/Tokyo
# hostnamectl hostname maciar-gentoo
systemctl enable dhcpcd

# rootのパスワード設定
passwd

# キーボードの設定
# /etc/conf.d/keymaps

# setting hostname etc
systemd-firstboot --prompt --setup-machine-id

# install wireless tool
emerge net-wireless/iw 
emerge net-wireless/wpa_supplicant

# system keymaps

## install grub
emerge --ask --verbose sys-boot/grub:2

# ueifで
# if もし、GRUB_PLATFORMS="efi-64"とならなかった場合、
# 下記の設定をして、もう一度
# echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf
# emerge --ask --update --newuse --verbose sys-boot/grub:2
# とする必要がある。

# 順番考えた上でイニシャルかどうかも書いとく。

# bootにgrubのインストール
# bios
grub-install /dev/sda

# ueif
grub-install --target=x86_64-efi --efi-directory=/boot

grub-mkconfig -o /boot/grub/grub.cfg

# chrootをやめる。
exit
# cd /
# umount -l /mnt/gentoo/dev{/shm,/pts,}
# umount -R /mnt/gentoo