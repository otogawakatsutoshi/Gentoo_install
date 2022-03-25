#!bin/bash

# [debian 参考](https://www.debian.org/releases/bullseye/amd64/apds03.ja.html)
# ホスト側でdebootstrapをインストールしておく。

mkdir /mnt/manjaro
mount /dev/sdb5 /mnt/manjaro

wget https://raw.githubusercontent.com/tokland/arch-bootstrap/master/arch-bootstrap.sh
# install arch-bootstrap.sh /usr/local/bin/arch-bootstrap

ARCH=x86_64
repourl=http://ftp.riken.jp/Linux/manjaro
arch-bootstrap -a $ARCH -r $repourl /mnt/manjaro
# arch-bootstrap -a $ARCH  /mnt/manjaro

echo 'nameserver 8.8.8.8' >> /mnt/manjaro/etc/resolv.conf

# /etc/fstabはdebianは手動で作る方針なので、マルチブートならコピーして流用が簡単
# マウントするデバイスは帰ること。
# cp /etc/fstab /mnt/debian/etc/

# chroot
mount --types proc /proc /mnt/manjaro/proc
mount --rbind /sys /mnt/manjaro/sys
mount --make-rslave /mnt/manjaro/sys
mount --rbind /dev /mnt/manjaro/dev
mount --make-rslave /mnt/manjaro/dev
mount --bind /run /mnt/manjaro/run
mount --make-slave /mnt/manjaro/run
