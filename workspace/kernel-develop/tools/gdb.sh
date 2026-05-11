#!/bin/bash

env=`find . -name "env.sh"`
for i in $env; do 
	. $i
done

gdb $BUILD/vmlinux -ex "source $KERNEL_SOURCE/scripts/gdb/vmlinux-gdb.py" -ex "target remote :1234" -ex "directory $KERNEL_SOURCE" -ex "continue"
