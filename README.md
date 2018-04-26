# freebsd_arm64_sd_setup_zfs
setup ZFS root in external USB HDD/SSD, for PINE64

# Set up sequence

1. fetch SD image
```
fetch http://ftp.freebsd.org/pub/FreeBSD/snapshots/arm64/aarch64/ISO-IMAGES/12.0/FreeBSD-12.0-CURRENT-arm64-aarch64-PINE64-20180412-r332432.img.xz
```

2. write SD image
```
xzcat FreeBSD-12.0-CURRENT-arm64-aarch64-PINE64-20180412-r332432.img.xz | dd of=/dev/da0 bs=1k conv=sync,noerror
```

3. boot from SD
4. connect external USB HDD or USB SSD
5. login as root
6. set current time
7. fetch setup script
```
fetch https://raw.githubusercontent.com/bsd-hacker/freebsd_arm64_sd_setup_zfs/master/setup_zfs.sh
```

8. execute setup script
```
/bin/sh setup_zfs.sh
```

9. reboot

