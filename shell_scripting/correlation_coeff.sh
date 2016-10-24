#!/bin/bash

#usage: correlation_coeff.sh input_file xcolumn ycolumn

if [ $# -eq 3 ]
then
	xx=$2
	yy=$3
	input=$1
elif [ $# -eq 2 ]
then
	echo no columns given, assuming first and second, and zero lag
	xx=1
	yy=2
else
	echo usage: $0 input_file [xcolumn ycolumn]
	exit -1
fi

xmean=`awk '{SUM+=$'$xx';COUNT+=1}END{print SUM/COUNT}' $input`
ymean=`awk '{SUM+=$'$yy';COUNT+=1}END{print SUM/COUNT}' $input`
echo xmean = $xmean ymean = $ymean

awk '{COUNT+=1;EXPX=($'$xx'-('$xmean'));EXPY=($'$yy'-('$ymean'));SIGX+=($'$xx'-('$xmean'))*($'$xx'-('$xmean'));SIGY+=($'$yy'-('$ymean'))*($'$yy'-('$ymean'));EXPXY+=EXPX*EXPY}END{print "COUNT="COUNT, "xmean="EXPX/COUNT, "ymean="EXPY/COUNT, "R="EXPXY/sqrt(SIGX*SIGY)}' $input
