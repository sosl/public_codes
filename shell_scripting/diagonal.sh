#!/bin/bash

if [ $# -eq 2 ]
then
	awk 'BEGIN{COUNT=1}{if ((NR-COUNT)%1024==0) {print COUNT,$1;NEXT=1} else if (NEXT==1) {NEXT=0; COUNT+=1}}' $1 > $2
elif [ $# -eq 3 ]
then
	awk 'BEGIN{COUNT=1}{if ((NR-COUNT)%'$1'==0) {print COUNT,$1;NEXT=1} else if (NEXT==1) {NEXT=0; COUNT+=1}}' $2 > $3
elif [ $# -eq 4 ]
then
	awk 'BEGIN{COUNT=1}{if ((NR-COUNT)%'$1'=='$2') {print COUNT,$1;NEXT=1} else if (NEXT==1) {NEXT=0; COUNT+=1}; if (COUNT+'$2'-1=='$1') exit 0}' $3 > $4
else
	echo usage $0 [size] [off] input output
	echo "this script prints out the diagonal of a square matrix with a side of size bins (by default 1024)"
	echo if off is given, the scrip will produce elements off the diagonal by off 
	exit
fi
