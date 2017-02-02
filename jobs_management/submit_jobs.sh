#!/bin/bash

if [ $# -lt 2 ] || [ $# -gt 3 ]
then
	echo usage: submit_jobs.sh name_prefix last [first]
	exit
fi

name=$1
count=$2

if [ $# -eq 3 ]
then
	first=$3
else
	first=0
fi

for x in `seq $first $count`
do
	qsub ${name}_${x}.sh
done
