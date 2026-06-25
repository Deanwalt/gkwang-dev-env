#!/bin/bash

OUTPUT_DIR_TEMPLATE=/tmp/srcindex
STATUS_FILE_TEMPLATE=.srcindex.copy

function src_monitor() {
	# arg1: 源码目录

	one_dir=$1
	is_change=0
	OUTPUT_DIR=$OUTPUT_DIR_TEMPLATE.`basename $one_dir`
	STATUS_FILE=$STATUS_FILE_TEMPLATE.`basename $one_dir`
	rm -rf $STATUS_FILE
	test ! -e "$OUTPUT_DIR" && mkdir $OUTPUT_DIR
	grep "$one_dir" /etc/srcindex.conf > $STATUS_FILE
	echo "srcindex status:0" >> $STATUS_FILE
	echo "heart beat:`date +%s`" >> $STATUS_FILE

	while true; do
		if test ! -e $one_dir; then
			break
		fi

		is_change=`grep "srcindex status:" $STATUS_FILE | awk -F ":" '{print $2}'`

		if test "$is_change" -eq 0; then
			# 源码没有发生变动，开始监视
			# 下面注释的命令，由于管道符，会创建子进程运行，子进程中修改is_change，对循环外的is_change不生效；
			# inotifywait -r -e modify -e create -e delete -e move -t 60 --format '%w%f' $one_dir | while read FILE; do  is_change=1;  break; done
			while read FILE; do
				is_change=1;
				break;
			done < <(inotifywait -r -e modify -e create -e delete -e move -t 60 --format '%w%f' $one_dir)

			sed -i "/srcindex status:/d" $STATUS_FILE
			echo "srcindex status:$is_change" >> $STATUS_FILE
			sed -i "/heart beat:/d" $STATUS_FILE
			echo "heart beat:`date +%s`" >> $STATUS_FILE
			continue
		fi

		is_busy=`lsof $one_dir 2>/dev/null | grep -vE 'COMMAND|bash|less|more|cat|vim|lsof|grep'`
		test -n "$is_busy" && sleep 2 && continue

		cd $one_dir
		ctags -R -o $OUTPUT_DIR/tags
		cscope -Rbkq -f $OUTPUT_DIR/cscope
		cd $OUTPUT_DIR

		is_busy=`lsof $one_dir 2>/dev/null | grep -vE 'COMMAND|bash|less|more|cat|vim|lsof|grep'`
		test -n "$is_busy" && sleep 2 && continue # 需要回到前面重新生成索引，因为忙碌的这个时刻，源码可能已经发行变化了

		for i in `ls`; do
			if test "$i" = "tags"; then
				mv $i $one_dir/
			else
				mv $i $one_dir/$i.out
			fi
		done
		sed -i "/srcindex status:/d" $STATUS_FILE
		echo "srcindex status:0" >> $STATUS_FILE
		sed -i "/heart beat:/d" $STATUS_FILE
		echo "heart beat:`date +%s`" >> $STATUS_FILE

		rm -rf $OUTPUT_DIR/*
	done

	exit 0
}

identification="gkwang_src_index_ident"
if test "$1" = "$identification"; then
	src_monitor $2
	exit 0
fi

is_alive=`ps -aux | grep -E "ctags|cscope -dl -f|inotifywait" | grep -v grep`
test -n "$is_alive" && exit 0

while true; do

	while read line; do
		if test ! -e "$line"; then
			continue
		fi
		# 检查子进程心跳，若已失效，则重新拉起
		STATUS_FILE=$STATUS_FILE_TEMPLATE.`basename $line`
		heartbeat=`grep "heart beat:" $STATUS_FILE 2>/dev/null | awk -F ":" '{print $2}'`
		now=`date +%s`
		if test -z "$heartbeat" || test "$((now - heartbeat + 1))" -gt 120; then
			exec -a "src_monitor" bash -x $0 $identification $line 2>/dev/null &
		fi
	done < /etc/srcindex.conf

	sleep 180
done
