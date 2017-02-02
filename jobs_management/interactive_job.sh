#!/bin/bash

default_queue=example_queue
account=example_account

if [ $# -lt 1 ] || [ $# -gt 4 ]
then
	echo usage: `basename $0` hours [queue] [ppn] [gpus]
	echo 'default values: queue = sstar; ppn = 32; gpus = 0'
	exit
fi
if [ $# -ge 2 ]
then 
	queue=$2
	if [ $# -ge 3 ]
	then
		ppn=$3
	else
		ppn=32
	fi
	if [ $# -eq 4 ]
	then
            if [ $4 -gt 0 ]
            then
		gpus=":gpus=$4"
            else
                gpus=""
            fi
	else
		gpus=""
	fi
else
	queue=${default_queue}
	ppn=1
	gpus=""
fi
hours=$1
if [ $hours -lt 10 ]
then
    hours=0$hours
fi

echo qsub -I -q $queue -A ${example_account} -l walltime=00:${hours}:00:00 -l nodes=1:ppn=$ppn$gpus
qsub -I -q $queue -A ${example_account} -l walltime=00:${hours}:00:00 -l nodes=1:ppn=$ppn$gpus
