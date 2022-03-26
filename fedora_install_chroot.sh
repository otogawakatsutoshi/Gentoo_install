#!bin/bash

# chroot /mnt/fedora /bin/bash

source /etc/profile
export PS1="(chroot) fedora ${PS1}"

[](https://wiki.archlinux.jp/index.php/GRUB)

# ホストも/bootを使っているなら、
# --rbindもいるかもしれない
mount /dev/${disk}1 /boot

# 後からファームウェアを入れるのが難しいので、
# firmware入れるならnon freeのbootstrap

dnf update -y 

# みんながよく使うツールインストール
# shutdown,halt,lspciもないため、ほぼ必要。
tasksel install standard

apt install vim -y

echo "# set default editor for root." >> /root/.bashrc
echo "export EDITOR=$(command -v vim)" >> /root/.bashrc

# setting for UEFI
cat << END >> /etc/fstab
/dev/sda1   /boot        vfat    defaults             0 2
/dev/sda2   none         swap    sw                   0 0
/dev/sda3   /            ext4    noatime              0 1
END

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

# wifiが使っているカーネルモジュールの特定
lspci -vvnn | grep -A 9 Network | grep Kernel

[debian形でドライバーの探し方](https://wiki.ubuntulinux.jp/UbuntuTips/Hardware/HowToSetupBcm43xx)

# メタパッケージをインストールするといい感じにwifiのモジュールを取ってきてくれる。
apt install -y firmware-linux-nonfree
# contributeのもインストールしておく。
apt install -y firmware-linux

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


# キャッシュの解放
apt clean

# umount -l /mnt/gentoo/dev{/shm,/pts,}
# umount -R /mnt/gentoo
