#!/bin/bash

if [ $# -lt 2 ] || [ $# -gt 3 ]
then
	echo usage: $0 input column [weight column]
	exit
fi

input=$1
column=$2
weight=$3

if [ $# -eq 2 ]
then
	awk '{SUM+=$'${column}'}END{print SUM}' $input
else
	awk '{SUM+=$'${column}'*$'${weight}'}END{print SUM}' $input
fi
