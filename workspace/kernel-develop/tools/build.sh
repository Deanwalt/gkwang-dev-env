#!/bin/bash

for i in `find . -name "env.sh"`; do
	. $i
done

$DEVELOP/tools/config.sh $1
if test "$?" -eq "1"; then
	exit 1
fi

cd $KERNEL_SOURCE

if test $1 = "pkg"; then
	make -j`nproc` O=$BUILD bindeb-pkg
else
	make -j`nproc` O=$BUILD bzImage
fi
