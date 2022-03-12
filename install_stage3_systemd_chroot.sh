#!bin/bash

# chroot /mnt/gentoo /bin/bash

source /etc/profile
export PS1="(chroot) ${PS1}"

# これはchrootの外からでもできる。mount /dev/sda1 /mnt/gentoo/boot　になるが。
mount /dev/sda1 /boot

# sync package and source 
emerge-webrsync

# もし必要なら。メモリ足りてないなら使わんほうがいい。
# This setting is optional.
# if you error 
# 'Your current profile is invalid.'
# emerge --sync --quiet

# stage3 などに対して適切なprofileか確認。
eselect profile list

# desktop-systemdが嫌なら、gnome,prasmaに変更すること。
# eselect profile set number という形式で選択

# if UEIF use set
echo '# set grub ueif setting' >> /etc/portage/make.conf
echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf

# update all package
emerge --update --deep --newuse @world
emerge app-editors/vim

echo "# set default editor for root." >> /root/.bashrc
echo "export EDITOR=$(command -v vim)" >> /root/.bashrc

# set timezone 
# echo "Asia/Tokyo" > /etc/timezone
# emerge --config sys-libs/timezone-data

# set locale
# echo en_US ISO-8859-1 >> /etc/locale.gen
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
# 再配布可能であるもののUSEFlagを建てる
echo "sys-kernel/linux-firmware @BINARY-REDISTRIBUTABLE" >> /etc/portage/package.license

emerge sys-kernel/linux-firmware

# これがないとwifi,仮想環境などカーネル
# に依存した機能のビルドで失敗する
# install kernel
emerge sys-kernel/gentoo-sources

# kernel 一覧を表示
eselect kernel list

# 使うlinuxカーネルを設定する
eselect kernel set 1

# manual setting

# manu configなど
# auto
emerge sys-kernel/genkernel

# /etc/fstab require for genkernl build
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

# 外付けにインストールして再起動した場合、
# 正しく動かないなら、
# /etc/fstab を見て/dev/sdaなどの位置が正しいか確認すること。


genkernel all

# network setting
# dhcp client
emerge net-misc/dhcpcd

systemctl enable dhcpcd

# rootのパスワード設定
passwd

# sudo コマンドのインストール
# 開発ユーザー用、運用時はdoas使う。
emerge app-admin/sudo

# 運用ユーザー用、一部の機能だけroot権限必要ならという感じ。
emerge app-admin/doas

# 作業用一般ユーザーの作成
USER=yourname

# sudoできるユーザーの作成
useradd -m $USER
passwd $USER
usermod -aG wheel $USER

# デスクトップ環境ならグラフィカルモードになっていることを確認。
systemctl get-default

# キーボードの設定
# /etc/conf.d/keymaps

# setting hostname etc
systemd-firstboot --prompt --setup-machine-id
# hostnameの設定など
# 日本は321
# 102 jp keyboard

# install wireless tool
emerge net-wireless/iw 
emerge net-wireless/wpa_supplicant

## install grub
emerge sys-boot/grub:2

# ueifで
# if もし、GRUB_PLATFORMS="efi-64"とならなかった場合、
# 下記の設定をして、もう一度
# emerge --ask --update --newuse --verbose sys-boot/grub:2
# とする必要がある。

# bootにgrubのインストール
# bios
grub-install /dev/sda

# before ccheck up
# ueif
# --remobableはいるマザーボードかどうかは場合によりけり。
# とりあえずやってみる精神。
# macは--removableがいった。
grub-install --target=x86_64-efi --efi-directory=/boot --removable

# 設定ファイルを出力。上書きも同じ。
grub-mkconfig -o /boot/grub/grub.cfg

# chrootをやめる。
exit
# cd /
# umount -l /mnt/gentoo/dev{/shm,/pts,}
# umount -R /mnt/gentoo

# reboot
# reboot五に抜く。
