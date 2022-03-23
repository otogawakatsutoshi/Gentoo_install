#!bin/bash

# chroot /mnt/debian /bin/bash

source /etc/profile
export PS1="(chroot) debian ${PS1}"

# ホストも/bootを使っているなら、
# --rbindもいるかもしれない
mount /dev/${disk}1 /boot

wget http://cdimage.debian.org/cdimage/unofficial/non-free/firmware/stable/11.2.0/firmware.tar.gz

# non freeなパッケージが使えるように追加してやる。
# debootstrapで使ったレポジトリは追加済みになっている。
cat << END
deb-src http://ftp.us.debian.org/debian bullseye main non-free contrib

deb http://security.debian.org/ bullseye-security main
deb-src http://security.debian.org/ bullseye-security main
END

# http://cdimage.debian.org/cdimage/unofficial/non-free/firmware/bullseye/11.2.0/firmware.tar.gz
# 
apt update && apt upgrade -y

apt install vim -y

echo "# set default editor for root." >> /root/.bashrc
echo "export EDITOR=$(command -v vim)" >> /root/.bashrc

apt install -y locales
dpkg-reconfigure locales
# (必要なら) 以下のようにキーボードの設定を行ってください。

# apt install console-setup
# dpkg-reconfigure keyboard-configuration 

# debian形なので,dpkg-reconfigureでtimezonの変更
dpkg-reconfigure tzdata

apt install -y network-manager

apt install -y dhcpcd5

systemctl enable dhcpcd
# install wireless tool

# wep tool
apt install -y iw
# wpa tool
apt install -y wpasupplicant

# 管理者のパスワード設定
passwd

# sudo コマンドのインストール
# 開発ユーザー用、運用時はdoas使う。
apt install -y sudo 

# 運用ユーザー用、一部の機能だけroot権限必要ならという感じ。
apt install -y doas 

# 作業用一般ユーザーの作成
USER=yourname

# su でrootユーザーに変更できる権限を付与
useradd -m $USER
passwd $USER

# 管理者グループに追加
usermod -aG wheel $USER

# wheel グループがsudo使えるように
# visudoで変更

# debianではsystemd-firstbootはあんま使わない。

DebianHostName=yourhostname
echo $DebianHostName > /etc/hostname

# 最新のkernelが自動ではいる。
apt install linux-image-amd64

# ホストと同じbootパーティしょんを使うならgrubはインストールしない
# apt install grub-pc
# grub-install /dev/sda
# update-grub

# ホストと同じものを使うならdebianのエントリーを追加するだけでよい。
# [ grub menuの追加方法](https://wiki.archlinux.jp/index.php/GRUB)

# shutdown もhaltもないため、必要。
tasksel install standard

# キャッシュの解放
apt clean

# umount -l /mnt/gentoo/dev{/shm,/pts,}
# umount -R /mnt/gentoo
