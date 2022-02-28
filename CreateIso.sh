
iso=$(ls -1 .cache/ | grep iso)
timestamp=$(echo $iso | sed 's/install-amd64-minimal-//' | sed 's/.iso//')

isolabel=$(isoinfo -d -i .cache/${iso} | sed -n 's/Volume id: //p')

sudo mkdir "/run/media/$USER/$(echo $isolabel)"

sudo mount -o loop -t iso9660 .cache/${iso} "/run/media/$USER/$(echo $isolabel)"

mkdir .cache/gentoo-${timestamp}

# timestampなどの属性が変更されないために-aをつける。
sudo cp -ar "/run/media/$USER/$(echo $isolabel)"/* .cache/gentoo-${timestamp}/

umount "/run/media/$USER/$(echo $isolabel)"

# add stage3 compressive file.
ls -1 .cache/ | \
  grep stage3 | \
  xargs -I {} cp .cache/{} .cache/gentoo-${timestamp}/

# add map


# mkisofs -r -J -V "Gentoo" -o .cache/gentoo-${timestamp}.iso .cache/gentoo-${timestamp}/

# [How to create bootable iso](https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/5/html/installation_guide/s2-steps-make-cd)
mkisofs -V "Gentoo" -o .cache/gentoo-${timestamp}.iso -b \
  isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot \
  -boot-load-size 4 \
  -boot-info-table -R -J -v \
  -T .cache/gentoo-${timestamp}/

# example
# /dev/sdd1 on /run/media/katsutoshi/7148-6906 type vfat (rw,nosuid,nodev,relatime,uid=1000,gid=1000,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,showexec,utf8,flush,errors=remount-ro,uhelper=udisks2)
