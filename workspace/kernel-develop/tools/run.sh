#!/bin/bash

for i in `find . -name "env.sh"`; do
	. $i
done

cd $TEST
./start-vm.sh $*
