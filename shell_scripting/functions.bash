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
	threads=$1
	while [ "`jobs | wc -l | awk '{print $1}'`" -ge "$threads" ]
	do
		sleep 30
		jobs > /dev/null
	done
}

wait_until_jobs_finished() {
	while [ "`jobs | wc -l | awk '{print $1}'`" -gt "0" ]
	do
		sleep 120
		jobs > /dev/null
	done
}
