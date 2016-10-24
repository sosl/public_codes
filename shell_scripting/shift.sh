#!/bin/bash

if [ $# -eq 2 ]
then
	input=$1
	output=$2
	nbin=1024
	column=1
elif [ $# -eq 3 ]
then
	column=$1
	input=$2
	output=$3
	nbin=1024
elif [ $# -eq 4 ]
then
	column=$1
	nbin=$2
	input=$3
	output=$4
elif [ $# -eq 5 ]
then
	column=$1
	nbin=$2
	shift=$3
	input=$4
	output=$5
else 
	echo usage : $0 [column] [nbin] [shift] input output
	echo this script will rotate an ascii profile in the specified column of the input file
	echo if no column is specified, then the script assumes the first column to contain the ascii
	echo if no number of bins is given, the script will asume that the profile has 1024 bins
	echo if no number of shifts is give the script will assume that the shift is half the number of bins
	exit
fi

if [ $# -ne 5 ]
then
	shift=`echo $nbin "/2" | bc`
fi

echo awk '{profile[NR]=$'$column'}END{for (i=1;i<'$nbin'+1; i++) {j=(i+'$shift'-1)%'$nbin';print profile[j+1]}}' $input > $output
awk '{profile[NR]=$'$column'}END{for (i=1;i<'$nbin'+1; i++) {j=(i+'$shift'-1)%'$nbin';print profile[j+1]}}' $input > $output
