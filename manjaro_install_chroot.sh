#!bin/bash

# chroot /mnt/manjaro /bin/bash

source /etc/profile
export PS1="(chroot) manjaro ${PS1}"

[](https://wiki.archlinux.jp/index.php/GRUB)

# ホストも/bootを使っているなら、
# --rbindもいるかもしれない
mount /dev/${disk}1 /boot

# 後からファームウェアを入れるのが難しいので、
# firmware入れるならnon freeのbootstrap

# non freeなパッケージが使えるように追加してやる。
# pacman-mirros
cat << END
# non freeのcdと同じようにfirmwareが追加される。
deb-src http://ftp.us.debian.org/debian bullseye main non-free contrib

deb http://security.debian.org/ bullseye-security main non-free contrib
deb-src http://security.debian.org/ bullseye-security main non-free contrib
END

# http://cdimage.debian.org/cdimage/unofficial/non-free/firmware/bullseye/11.2.0/firmware.tar.gz
# 
# みんながよく使うツールインストール
# shutdown,halt,lspciもないため、ほぼ必要。

pacman -Sy base base-devel
pacman -Sy less
pacman -Sy vim

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

pacman -Sy pciutils

systemd-firstboot --prompt

systemctl enable NetworkManager

pacman -Sy dhcpcd

systemctl enable dhcpcd
# install wireless tool

# wep tool
pacman -Sy iw
# wpa tool
pacman -Sy wpa_supplicant

# メタパッケージをインストールするといい感じにwifiのモジュールを取ってきてくれる。
apt install -y firmware-linux-nonfree
# contributeのもインストールしておく。
apt install -y firmware-linux

# 管理者のパスワード設定
passwd

# sudo コマンドのインストール
# 開発ユーザー用、運用時はdoas使う。
pacman -Sy sudo

# 運用ユーザー用、一部の機能だけroot権限必要ならという感じ。
pacman -Sy doas

# 作業用一般ユーザーの作成
USER=yourname

# su でrootユーザーに変更できる権限を付与
useradd -m $USER
passwd $USER

# 管理者グループに追加
usermod -aG wheel $USER

[manjaro desktop](https://wiki.manjaro.org/index.php/Install_Desktop_Environments)

# Install a basic KDE Plasma environment
pacman -S plasma kio-extras
# Optional: Install KDE applications
# To install a full set of K* applications use kde-applications. This will be ~300 packages(including dependencies)

pacman -S kde-applications
# Optional: Install and use SDDM, the recommended display manager for KDE
# SDDM is installed as a dependency of plasma. To enable it

systemctl enable sddm.service --force
systemctl reboot
# Optional: Install the Manjaro configuration and theming for plasma
pacman -S manjaro-kde-settings sddm-breath-theme manjaro-settings-manager-knotifier manjaro-settings-manager-kcm
# Open plasma settings, go to Startup & Shutdown->Login Screen and select "Breath"

# Alternatively, the newer themes may be installed with:

# pacman -S breath2-icon-themes breath2-wallpaper plasma5-themes-breath2 sddm-breath2-theme
# Create a new user for the new desktop environment
useradd -mG lp,network,power,sys,wheel <username>
passwd <username>

# wheel グループがsudo使えるように
# visudoで変更

# debianではsystemd-firstbootはあんま使わない。

DebianHostName=yourhostname
echo $DebianHostName > /etc/hostname

# kernelとヘッダーをインストール
pacman -S linux515 linux515-header


# ホストと同じbootパーティしょんを使うならgrubはインストールしない
# apt install grub-pc
# grub-install /dev/sda
# update-grub

# ホストと同じものを使うならdebianのエントリーを追加するだけでよい。
# [ grub menuの追加方法](https://wiki.archlinux.jp/index.php/GRUB)


# キャッシュの解放
apt clean

# umount -l /mnt/manjaro/dev{/shm,/pts,}
# umount -R /mnt/manjaro
