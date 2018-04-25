#!/bin/sh
#
# BSD 2-Clause License
# 
# Copyright (c) 2018, YAMAMOTO, Shigeru
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# 
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


SETUP_DATE=`date +'%Y%m%d'`

export BSDINSTALL_CHROOT=/zr${SETUP_DATE}
export DESTDIR=/zr${SETUP_DATE}

export ZFSBOOT_POOL_NAME=zr${SETUP_DATE}
export ZFSBOOT_SWAP_SIZE=16g

/usr/libexec/bsdinstall/time

/usr/libexec/bsdinstall/zfsboot

cd ${DESTDIR}

for i in base doc kernel ports src test base-dbg kernel-dbg
do
	fetch -o - http://ftp.freebsd.org/pub/FreeBSD/snapshots/arm64/aarch64/12.0-CURRENT/${i}.txz | tar fvxz -
done

rm -fr ${DESTDIR}/boot/kernel

cp -r /boot/kernel ${DESTDIR}/boot/.

mkdir -p ${DESTDIR}/boot/msdos

echo 'zfs_load="YES"' >> ${DESTDIR}/boot/loader.conf
echo 'opensolaris_load="YES"' >> ${DESTDIR}/boot/loader.conf
echo 'zpool_load="YES"' >> ${DESTDIR}/boot/loader.conf
echo 'zpool_type="zpool"' >> ${DESTDIR}/boot/loader.conf
echo 'zpool_name="/boot/zfs/zpool.cache"' >> ${DESTDIR}/boot/loader.conf

echo '# Custom /etc/fstab for FreeBSD embedded images' \
	> ${DESTDIR}/etc/fstab
echo "#/dev/ufs/rootfs   /       ufs     rw      1       1" \
	>> ${DESTDIR}/etc/fstab
echo "/dev/gpt/efiboot0 /boot/msdos msdosfs rw,noatime 0 0" \
	>> ${DESTDIR}/etc/fstab
echo "#tmpfs /tmp tmpfs rw,mode=1777,size=50m 0 0" \
	>> ${DESTDIR}/etc/fstab

cp /etc/rc.conf ${DESTDIR}/etc/.
echo 'zfs_enable="YES"' >> ${DESTDIR}/etc/rc.conf
echo 'autofs_enable="YES"' >> ${DESTDIR}/etc/rc.conf


# Create a default user account 'freebsd' with the password 'freebsd',
# and set the default password for the 'root' user to 'root'.
/usr/sbin/pw -R /zr${SETUP_DATE} groupadd freebsd -g 1001
mkdir -p ${DESTDIR}/home/freebsd
/usr/sbin/pw -R ${DESTDIR} \
		useradd freebsd \
		-m -M 0755 -w yes -n freebsd -u 1001 -g 1001 -G 0 \
		-c 'FreeBSD User' -d '/home/freebsd' -s '/bin/csh'
/usr/sbin/pw -R ${DESTDIR} \
		usermod root -w yes

# rename /boot/loader.efi
if [ -f /boot/loader.efi ]; then
	mv /boot/loader.efi /boot/loader.efi.backup
fi

