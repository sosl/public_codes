#!/bin/bash

if [ $# -ne 2 ]
then
	echo usage: delete_jobs.sh first_id count 
	exit
fi

first=$1
count=$2

for x in `seq -f '%.0f' $first $(( first + count - 1 ))`
do
	qdel $x
done
