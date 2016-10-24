#!/bin/bash

if [ $# -lt 2 ] || [ $# -gt 3 ]
then
	echo usage: $0 input column [size]
	echo default size is 1024
	echo columns are counted from 1
	exit
elif [ $# -eq 2 ]
then
	column=$2
	size=1024
elif [ $# -eq 3 ]
then
	column=$2
	size=$3
fi

input=$1
echo producing column $column from matrix in $input of rank $size 1>&2

awk '{if (NR%'$size'=='$column') print $0}' $input
