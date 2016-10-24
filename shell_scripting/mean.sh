#!/bin/bash

if [ $# -eq 2 ]
then
	awk '{SUM+=$'$2';COUNT+=1}END{print SUM/COUNT}' $1
elif [ $# -eq 3 ]
then
	awk '{SUM+=$'$2'*$'$3';COUNT+=$'$3'}END{print SUM/COUNT}' $1
else
	echo usage: $0 input column '(weight_column)'
fi
