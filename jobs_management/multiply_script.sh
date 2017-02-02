#!/bin/bash

if [ $# -gt 3 ] || [ $# -lt 2 ]
then
	echo usage: multiply_script.sh input_file copies [file_list]
	echo $# arguments were provided
	exit 0
fi

inputfile=$1
copies=$2

if [ ! -f "$inputfile" ]
then
	echo multiply_script.sh $inputfile the input file does not exist
	exit -2
fi

echo creating $copies copies of $inputfile

for x in `seq 1 $copies`
do
  outputfile=`echo $inputfile | sed -e 's/_0/_'$x'/g'`
  cat $inputfile | sed -e 's/_0/_'$x'/g' > $outputfile
done

#preparing file lists for each job

if [ $# -eq 3 ]
then
	file_list=$3
	lines=`wc -l $file_list | awk '{print $1}'`
	lines=`echo $lines"/"$(( copies + 1 )) | bc`
	lines=$(( lines + 1 ))

	chars=`echo $copies | wc -c`
	chars=$(( chars - 1 ))

	prefix_dir=`dirname $file_list`
	prefix=`basename $file_list | awk -F. '{print $1"_"}'` 

	split -d -a $chars -l $lines $file_list ${prefix_dir}/$prefix

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
		rename _$get_rid _ ${prefix_dir}/${prefix}${get_rid}[0-9]
	done
fi
