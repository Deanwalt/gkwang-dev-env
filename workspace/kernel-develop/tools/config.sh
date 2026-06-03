#!/bin/bash

cd $KERNEL_SOURCE

if test "$1" = "pkg"; then
	if test -f $BUILD/.config; then
		make O=$BUILD olddefconfig
		echo 0
		exit 0
	else
		echo "need a old config!"
		echo "FOR EXAMPLE: 'cp /boot/config-xxx $BUILD/.config'"
		echo 1
		exit 1
	fi
else
	make O=$BUILD x86_64_defconfig

	./scripts/config --file $BUILD/.config --enable CONFIG_KGDB
	./scripts/config --file $BUILD/.config --enable CONFIG_KGDB_SERIASL_CONSOLE
	./scripts/config --file $BUILD/.config --enable CONFIG_KGDB_KDB
	./scripts/config --file $BUILD/.config --set-val CONFIG_KDB_DEFAULT_ENABLE 0x1
	./scripts/config --file $BUILD/.config --enable CONFIG_DEBUG_INFO
	./scripts/config --file $BUILD/.config --enable CONFIG_DEBUG_INFO_DWARF4
	./scripts/config --file $BUILD/.config --enable CONFIG_DEBUG_INFO_BTF
	./scripts/config --file $BUILD/.config --enable CONFIG_GDB_SCRIPTS
	./scripts/config --file $BUILD/.config --enable CONFIG_FRAME_POINTER
	./scripts/config --file $BUILD/.config --enable CONFIG_KALLSYMS
	./scripts/config --file $BUILD/.config --enable CONFIG_KALLSYMS_ALL
	./scripts/config --file $BUILD/.config --enable CONFIG_DEBUG_KERNEL
	./scripts/config --file $BUILD/.config --disable CONFIG_BLK_DEV_INITRD
	./scripts/config --file $BUILD/.config --set-val CONFIG_INITRAMFS_SOURCE ""
	./scripts/config --file $BUILD/.config --disable CONFIG_SECURITY_SELINUX
	./scripts/config --file $BUILD/.config --enable CONFIG_EXT4_FS
	./scripts/config --file $BUILD/.config --enable CONFIG_EXT4_FS_POSIX_ACL
	./scripts/config --file $BUILD/.config --enable CONFIG_EXT4_FS_SECURITY
	./scripts/config --file $BUILD/.config --enable CONFIG_XFS_FS
	./scripts/config --file $BUILD/.config --enable CONFIG_FAT_FS
	./scripts/config --file $BUILD/.config --enable CONFIG_VFAT_FS
	./scripts/config --file $BUILD/.config --enable CONFIG_VIRTIO_BLK
	./scripts/config --file $BUILD/.config --enable CONFIG_SCSI_VIRTIO
	./scripts/config --file $BUILD/.config --enable CONFIG_VIRTIO_PCI

	make O=$BUILD olddefconfig
	echo 0
	exit 0
fi
