#!/bin/bash

user=example_user
if [ $# -ne 4 ]
then
	echo usage: submit_after_finished.sh current_job_name how_many path next_job_name
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
want=$2
path=$3
job_file=$4

submitted=0
#check if the job script exists and set the flag 
for job in `seq 0 $want`
do
	if [ ! -f "${path}/${job_file}_${job}.sh" ]
	then
		echo the job script ${job_file}_${job}.sh does not exist in $path
		exit -1
	fi
	job_submitted[job]=0
done

#run until all jobs are submitted
while [ "$submitted" -ne "$want" ]
do
	#check the job $job
	for job in `seq 0 $want`
	do
		#only process if not submitted yet
		if [ "${job_submitted[job]}" -ne 1 ]
		then
			#is the previous job still running
			run_count=`qstat -u ${example_user} | awk '{if (NR>5) print $4}' | grep ^${name}_${job} | wc -l | awk '{print $1}'`
			# if not, submit the new one and set the flag
			if [ "$run_count" -eq 0 ]
			then
				cd $path
				qsub ${job_file}_${job}.sh
				submitted=$(( submitted + 1 ))
				job_submitted[$job]=1
				echo started ${job_file}_${job} at `date` ; echo submitted $submitted out of $want jobs
			fi
		fi
	done
	#wait one minute unless done
	if [ "$submitted" -ne "$want" ]
	then
		sleep 60
	fi
done

