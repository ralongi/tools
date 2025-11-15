#!/bin/bash

$dbg_flag

# Script to create a new initrd.img file (using an existing initrd.img file) with a 120s nm-wait-online timeout

# Example links to download existing initrd.img files:
# https://download.eng.rdu.redhat.com/released/rhel-9/RHEL-9/9.4.0/BaseOS/x86_64/os/images/pxeboot/initrd.img (RHEL-9.4, x86_64)
# https://download.eng.rdu.redhat.com/released/rhel-10/RHEL-10/10.0/BaseOS/x86_64/os/images/pxeboot/initrd.img (RHEL-10.0, x86_64)
# https://download.eng.rdu.redhat.com/released/rhel-9/RHEL-9/9.4.0/BaseOS/aarch64/os/images/pxeboot/initrd.img (RHEL-9.4, aarch64)

# While in the directory that contains the existing initrd.img file:
echo "Working on it..."
rm -Rf initrd_temp

# Get the RHEL version info from initrd.img
initrd_version=$(xzcat initrd.img | cpio -i --to-stdout .buildstamp 2>/dev/null | grep Version | awk -F '=' '{print $NF}')

# Extract
mkdir initrd_temp
cd initrd_temp
xzcat ../initrd.img | cpio -idm --quiet 2>&1 | grep -v "Cannot mknod"

# Modify
sed -i 's/-t 3600/-t 120/' usr/lib/systemd/system/nm-wait-online-initrd.service

# Repack and name new file based on RHEL version and 120s timeout
find . -print0 | cpio --null --create --format=newc --quiet 2>&1 | grep -v "Cannot mknod" | xz --check=crc32 --x86 --lzma2=dict=1M > ../initrd_rhel-"$initrd_version"-120s.img

cd ..
rm -Rf initrd_temp
file_size=$(ls -lh initrd_rhel-"$initrd_version"-120s.img | awk '{print $5}')
echo "New initrd.img file with a 120s timeout for nm-wait-online: initrd_rhel-"$initrd_version"-120s.img ($file_size)"
