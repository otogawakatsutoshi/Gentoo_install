#!bin/bash

# chroot /mnt/gentoo /bin/bash

source /etc/profile
export PS1="(chroot) gentoo ${PS1}"

# これはchrootの外からでもできる。mount /dev/sda1 /mnt/gentoo/boot　になるが。
mount /dev/${disk}1 /boot

# sync package and source 
emerge-webrsync

# もし必要なら。メモリ足りてないなら使わんほうがいい。
# This setting is optional.
# if you error 
# 'Your current profile is invalid.'
# emerge --sync --quiet

# stage3 などに対して適切なprofileか確認。
# ここでplasmaやgnomeなどの選択をする。
eselect profile list
eselect profile set 

# desktop-systemdが嫌なら、gnome,prasmaに変更すること。
# eselect profile set number という形式で選択

# if UEIF use set
echo '# set grub ueif setting' >> /etc/portage/make.conf
echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf

# profileで使いたいUSEフラグを追加する。
# 例えば、gnome,KDE(plasma)はデフォルトでnetworkmanagerを使うようになっているわけでないので
# 追加する。wifi使うなら必須。

# kde(plasma)の場合

# sddmはxserverを内部で使っているログインマネージャ
# desktop の場合、ログインマネージャーが必要なのでインストール
# wikiではplasmaインストール時に自動でインストールされると書かれているが
# profile選択してもインストールされない。
echo '# set for plasma desktop' >> /etc/portage/make.conf
echo 'USE="${USE} networkmanager sddm"' >> /etc/portage/make.conf

# ログインマネージャを有効にしておく
# kdeの場合。
systemctl enable sddm

# デスクトップのためのbatteryなどの管理
# ほぼ必須
emerge kde-plasma/powerdevil

# システム設定。
# ほぼ必須
emerge kde-plasma/systemsettings

# gnomeの場合
echo '# set for gnome desktop' >> /etc/portage/make.conf
echo 'USE="${USE} networkmanager"' >> /etc/portage/make.conf

emerge gnome-base/gnome

# update all package
emerge --update --deep --newuse @world
emerge app-editors/vim

echo "# set default editor for root." >> /root/.bashrc
echo "export EDITOR=$(command -v vim)" >> /root/.bashrc

# 間違ったprofileを選択して、ビルドしてしまった場合は下のようにして
# 消す。
# # depcleanの対象にする。
# emerge --deselect 
# # emerge --depclean
# emerge --update --deep --newuse @world
# emerge --depclean

# # profile を変更しても削除できない場合は下のようにuseフラグを指定して
# # 削除する。
# emerge -C $(qlist -CI kde)

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

env-update && source /etc/profile && export PS1="(chroot) gentoo ${PS1}"

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


# eseclect repository をインストールしておく。
# laymanの代替として強力なため
emerge app-eselect/eselect-repository

# できるだけ影響範囲が小さくしておく。
# community repositoryを有効にしておく。
eselect repository enable guru

echo '*/*::guru' >> /etc/portage/package.mask/guru

# guru でunstableなので使う場合は、かなり気をつける。
# echo 'app-backup/timeshift::guru' >> /etc/portage/package.unmask

# echo '# timeshift exists testing branch only' >> /etc/portage/package.accept_keywords/timeshift
# echo '# if official merge request and aprove this package,remove these row.' >> /etc/portage/package.accept_keywords/timeshift
# echo 'app-backup/timeshift::guru' >> /etc/portage/package.accept_keywords/timeshift

# # repository enableしたら emerge-webrsyncではだめ
# emerge --sync

# emerge -pv app-backup/timeshift::guru

# rootのパスワード設定
passwd

# sudo コマンドのインストール
# 開発ユーザー用、運用時はdoas使う。
emerge app-admin/sudo

# 運用ユーザー用、一部の機能だけroot権限必要ならという感じ。
emerge app-admin/doas

# 作業用一般ユーザーの作成
USER=yourname

# su でrootユーザーに変更できる権限を付与
useradd -m $USER
passwd $USER
# 管理者グループに追加
usermod -aG wheel $USER

# gentooはsudoers groupがないのでwheel group に入っている人はsudoが使えるようにしておく
visudo

# gnomeデスクトップを使っているなら、plugdevグループに追加する
getent group plugdev
usermod -aG plugdev $USER

# デスクトップ環境ならグラフィカルモードになっていることを確認。
systemctl get-default

# キーボードの設定
# /etc/conf.d/keymaps

# setting hostname etc
systemd-firstboot --prompt --setup-machine-id
# hostnameの設定など
# 日本は321
# 102 jp keyboard
# キーボドの設定はUSでも設定しないと動かないのでinputめそっでで注意

# network setting

# dhcp client
emerge net-misc/dhcpcd

systemctl enable dhcpcd
# install wireless tool

# wep tool
emerge net-wireless/iw 
# wpa tool
emerge net-wireless/wpa_supplicant

# nmcliの設定
systemctl enable NetworkManager

# DNS解決を簡単にするためにresolvectlを有効にする
systemctl enable systemd-resolved

# gnome desktopの場合
systemctl enable gdm

## gnomeの場合、特に.xsessionなどは設定しなくて良い。

# 時刻がずれたとときに合わせるよう。
# 時刻を合わせないとパッケージ取れない。
systemctl enable systemd-timesyncd

# connect wifi
# nmcli dev wifi connect $SSID password $PASSOWRD

# guiのクライアントのインストール（必要ならば）

# accepting google-chrome license for all package
echo "*/* google-chrome" >> /etc/portage/package.license
emerge www-clinet/google-chrome

# 日本語のインプットメソッド
# mozcの場合。
echo '# set for input method mozc' >> /etc/portage/make.conf
echo 'USE="${USE} fctix4 -ibus"' >> /etc/portage/make.conf
emerge app-i18n/fcitx app-i18n/fcitx-configtool app-i18n/mozc

# ibusの場合
# gnomeとの組み合わせはfcitxよりもibusのほうがよい。ibus-mozcパッケージは廃止されるが、
# 組み合わせ自体は残る。
echo '# set for input method ibus' >> /etc/portage/make.conf
echo 'USE="${USE} -fctix4 ibus"' >> /etc/portage/make.conf
emerge app-i18n/mozc
# gnomeのキーボードの設定からmozcを追加

# 日本語フォントインストール
echo "*/* free-noncomm" >> /etc/portage/package.license
emerge --ask media-fonts/kochi-substitute media-fonts/ja-ipafonts

# cuiなら下記の設定は不要
# x11 の設定を追加（gnomeも必要。）
# 英字キーボードだと必須
localectl set-x11-keymap jp apple_laptop

[x11 key board setting](https://atmarkit.itmedia.co.jp/ait/articles/1811/30/news060.html)
# ※3 オプションで指定できる「MODEL」「VARIANT」「OPTIONS」は次のコマンドで確認できる。「list-x11-keymap-models」
# 「list-x11-keymap-layouts」「list-x11-keymap-variants [配列]」「list-x11-keymap-options」

## install grub
emerge sys-boot/grub:2

# accept_keywordでtesting ブランチも使える。
# 開発ツール
echo '# github-cli exists testing branch only' >> /etc/portage/package.accept_keywords/github-cli
echo '# if official merge request and aprove this package,remove these row.' >> /etc/portage/package.accept_keywords/github-cli
echo 'dev-util/github-cli' >> /etc/portage/package.accept_keywords/github-cli
emerge dev-util/github-cli

echo '# vscode exists testing branch only' >> /etc/portage/package.accept_keywords/vscode
echo '# if official merge request and aprove this package,remove these row.' >> /etc/portage/package.accept_keywords/vscode
echo 'app-editors/vscode' >> /etc/portage/package.accept_keywords/vscode
# license
echo "*/* Microsoft-vscode" >> /etc/portage/package.license
emerge app-editors/vscode

echo '# pwsh-bin exists testing branch only' >> /etc/portage/package.accept_keywords/pwsh-bin
echo '# if official merge request and aprove this package,remove these row.' >> /etc/portage/package.accept_keywords/pwsh-bin
echo 'app-shells/pwsh-bin' >> /etc/portage/package.accept_keywords/pwsh-bin
emerge app-shells/pwsh-bin
# ueifで
# if もし、GRUB_PLATFORMS="efi-64"とならなかった場合、
# 下記の設定をして、もう一度
# emerge --ask --update --newuse --verbose sys-boot/grub:2
# とする必要がある。

# bootにgrubのインストール
# bios
grub-install /dev/${disk}

# before ccheck up
# /efi/bootしか無理なマザーボードもあるが、それの
# 判断の自動化のために--remobableをつける。
# とりあえずやってみる精神。
# macは--removableがいった。
grub-install --target=x86_64-efi --efi-directory=/boot --removable

if [ ! -d /boot/grub.d ]; then
  mkdir /boot/grub.d
fi

cat < ./grub/40_custom | sed '1,3d' >> /etc/grub.d/40_custom

# systemd.unit=emergency.target

# 設定ファイルを出力。上書きも同じ。
grub-mkconfig -o /boot/grub/grub.cfg

# chrootをやめる。
exit
# cd /
# umount -l /mnt/gentoo/dev{/shm,/pts,}
# umount -R /mnt/gentoo

# reboot
# reboot五に抜く。
