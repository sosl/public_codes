#!/bin/bash

user=example_user
headnode=example.headnode

if [ "`hostname`" != "$headnode" ]
then
	echo must be run on $headnode
	exit -1
fi

if [ $# -ne 3 ]
then
	echo usage: submit_after_all_finished.sh current_job_name path next_job_name
	echo ; echo current jobs are:
	for current in `qstat -u ${example_user} | awk '{if (NR>5) print $4}' | sed 's/_[0-9]\{1,\}//g' | sort | uniq`
	do
		count=`qstat -u ${example_user} | awk '{if (NR>5) print $4}' | grep ^${current} | wc -l`
		echo $current $count
	done
	echo ;
	exit -1
fi


name=$1
path=$2
job_file=$3

#check if the job script exists and set the flag 
if [ ! -f "${path}/${job_file}.sh" ]
then
	echo the job script ${job_file}.sh does not exist in $path
	exit -1
fi

#wait for previous to finish
run_count=1
while [ "$run_count" -ne 0 ]
do
	#check the job $job
		run_count=`qstat -u ${example_user} | awk '{if (NR>5) print $4}' | grep ^${name} | wc -l | awk '{print $1}'`
	#wait one minute 
	sleep 60
done

cd $path
qsub ${job_file}.sh
echo started ${name} at `date` 
