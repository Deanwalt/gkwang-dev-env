#!/bin/bash

debug_mode=0

for i in `find . -name "env.sh"`; do
	. $i
done

IMAGE=$TEST/image/trixie.img
KERNEL=$BUILD/arch/x86/boot/bzImage

if test $debug_mode -eq "0"; then
	qemu-system-x86_64 \
		-m $VM_SIZE \
		-smp $NR_CPU \
		-machine q35 \
		-cpu Nehalem-v2 \
		-kernel $BUILD/arch/x86/boot/bzImage \
		-drive file=$IMAGE,format=raw \
		-no-reboot \
		-append "console=ttyS0 root=/dev/sda rw nokaslr panic=-1" \
		-net user,host=10.0.2.10,hostfwd=tcp:127.0.0.1:10025-:22 \
		-net nic,model=e1000 \
		-nographic \
		-pidfile vm.pid \
		2>&1 | tee vm.log
else
	qemu-system-x86_64 \
		-m $VM_SIZE \
		-smp $NR_CPU \
		-machine q35 \
		-cpu Nehalem-v2 \
		-kernel $BUILD/arch/x86/boot/bzImage \
		-drive file=$IMAGE,format=raw \
		-no-reboot \
		-append "console=ttyS0 root=/dev/sda rw nokaslr panic=-1" \
		-net user,host=10.0.2.10,hostfwd=tcp:127.0.0.1:10025-:22 \
		-net nic,model=e1000 \
		-nographic \
		-pidfile vm.pid \
		-gdb tcp::1234 \
		-S \
		2>&1 | tee vm.log
fi
	# -net user,host=10.0.2.10,hostfwd=tcp:127.0.0.1:10025-:22 \
	# -net nic,model=e1000 \
	#
	# -device virtio-net-pci,netdev=net1,mq=on,vectors=12 \
	# -netdev tap,id=net1,ifname=tap1,queues=4 \
        # -drive if=pflash,format=raw,readonly=on,file=$IMAGE/OVMF_CODE.fd
exit 0
