#my commonly used bash functions:

#split a file into a number of input files
split_input_file() {
	file_list=$1
	copies=$2
	
	lines=`wc -l $file_list | awk '{print $1}'`
	lines=`echo $lines"/"$(( copies )) | bc`
	lines=$(( lines + 1 ))

	chars=`echo $copies | wc -c`
	chars=$(( chars - 1 ))

	prefix=`echo $file_list | awk -F. '{print $1"_"}'`

	split -d -a $chars -l $lines $file_list $prefix

	for x in `seq 2 10`
	do
		if [ $x -gt $chars ]
		then
			break
		fi
		get_rid=0
		if [ $x -gt 2 ]
		then
			for xx in `seq 2 $(( x - 1 ))`
			do
				get_rid="$get_rid"0
			done
		fi
		rename _$get_rid _ ${prefix}${get_rid}[0-9]
	done
}

wait_until_cpu_available() {
	if [ $# -eq 2 ]
	then
		threads=$1
		sleep_time=$2
	elif [ $# -eq 1 ]
	then
		threads=$1
		sleep_time=10
	else
		echo usage: wait_until_cpu_available threads [sleep time]
		exit
	fi
	while [ "`jobs | wc -l | awk '{print $1}'`" -ge "$threads" ]
	do
		sleep $sleep_time
		jobs > /dev/null
	done
}

wait_until_jobs_finished() {
	if [ $# -eq 1 ]
	then
		sleep_time=$1
	else
		sleep_time=20
	fi
	while [ "`jobs | wc -l | awk '{print $1}'`" -gt "0" ]
	do
		sleep $sleep_time
		jobs > /dev/null
	done
}

wait_until_job_finished_with_timeout() {
	if [ $# -ne 3 ]
	then
		echo wrong usage of wait_until_jobs_finished_with_timeout
		echo must provide sleep_time steps pid
		exit
	fi
	sleep_time=$1
	steps=$2
	PID=$3
	PID_MINUS_ONE=$(( $PID - 1 ))
	job_finished_gracefully=0
	for i in `seq 1 $steps`
	do
		sleep $sleep_time
		jobs > /dev/null
		#jobs | wc -l | awk '{print $1}'
		if [ "`jobs | wc -l | awk '{print $1}'`" -eq 0 ]
		then 
			job_finished_gracefully=1
			break
		fi
	done
	# if the job hasn't finished yet then we just kill it:
	if [ "$job_finished_gracefully" -eq 0 ]
	then
		echo killing `cat /proc/$PID/cmdline` 1>&2 
		kill -9 $PID
		echo killing `cat /proc/$PID_MINUS_ONE/cmdline` 1>&2 
		kill -9 $PID_MINUS_ONE
	fi
}
