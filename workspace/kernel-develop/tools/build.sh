#!/bin/bash

for i in `find . -name "env.sh"`; do
	. $i
done

$DEVELOP/tools/config.sh
cd $KERNEL_SOURCE

if test $1 = "pkg"; then
	make -j`nproc` O=$BUILD bindeb-pkg
else
	make -j`nproc` O=$BUILD bzImage
fi
