#!/bin/bash

if [ $# -gt 2 ] || [ $# -eq 0 ]
then
	echo "Usage: shuffle.sh input [output]"
	exit -1
fi

if [ $# -eq 1 ]
then
	output='/dev/stdout'
else
	output=$2
fi

awk 'BEGIN{srand () }{print rand() "\t" $0 }'  $1 | sort -n | cut -f2- > $output
