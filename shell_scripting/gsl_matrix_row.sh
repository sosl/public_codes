#!/bin/bash

if [ $# -lt 2 ] && [ $# -gt 3 ]
then
	echo usage: $0 input row [size]
	echo default size is 1024
	echo row are counted from 1
	exit
elif [ $# -eq 2 ]
then
	row=$2
	size=1024
elif [ $# -eq 3 ]
then
	row=$2
	size=$3
fi

input=$1

awk '{if (NR>'$(( row - 1 )) '*'$size' && NR<'$row'*'$size') print $0; if (NR>'$row'*'$size') exit}' $input
