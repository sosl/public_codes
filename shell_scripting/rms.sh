#!/bin/bash

if [ $# -eq 2 ]
then
	mean=`mean.sh $1 $2`
	echo mean $mean
	awk '{RMS+=($'$2'-'$mean')*($'$2'-'$mean')}END{print "rms",sqrt(RMS/(NR-1))}' $1
elif [ $# -eq 3 ]
then
	awk '{WGT = 1.0/$'$3'/$'$3'; CHISQ += $'$2'*WGT*$'$2' ; SUM += WGT*$'$2'; SUMSQ += WGT*$'$2'*$'$2'; SUMWGT += WGT} END {print sqrt( (SUMSQ-SUM*SUM/SUMWGT)/SUMWGT ), CHISQ/(NR-1)}' $1
else
	echo usage: `basename $0` input column '(weight column)'
fi
