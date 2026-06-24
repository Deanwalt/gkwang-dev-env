#!/bin/bash

OUTPUT=/tmp/srcindex

while true; do
	sleep 180
	is_alive=`ps -aux | grep -E "ctags|cscope" | grep -v grep`
	test -n "$is_alive" && continue

	rm -rf $OUTPUT
	mkdir $OUTPUT

	while read one_dir; do
		if test -e $one_dir; then
			is_busy=`lsof $one_dir 2>/dev/null`
			test -n "$is_busy" && break

			cd $one_dir
			ctags -R -o $OUTPUT/tags
			cscope -Rbkq -f $OUTPUT/cscope
			cd $OUTPUT

			is_busy=`lsof $one_dir 2>/dev/null`
			test -n "$is_busy" && break

			for i in `ls`; do
				if test "$i" = "tags"; then
					mv $i $one_dir/
				else
					mv $i $one_dir/$i.out
				fi
			done

			rm -rf $OUTPUT/*
		fi
	done < /etc/srcindex.conf
done
