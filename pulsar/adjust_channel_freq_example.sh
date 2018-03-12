#!/bin/bash
#
# Copyright (C) 2015 by Stefan Oslowski
# Licensed under the Academic Free License version 3.0
# Brief explanation of the license can be found here:
# http://rosenlaw.com/OSL3.0-explained.htm
# Full text:
# http://opensource.org/licenses/AFL-3.0
# or see the LICENSE in the top directory of the repo for the 
#
# Example script for modifying frequency channels

set -o errexit
set -o nounset

TMP=$(mktemp)
CWD=$(pwd)

trap "rm -f $TMP" EXIT 

if [ $# -ne 2 ]
then
  echo usage: $0 input output
  exit
fi

input=$1
output=$2

echo '#!/usr/bin/env psrsh' > $TMP
echo "load ${CWD}/${input}" >> $TMP

nchan=$(psredit -qQ -c nchan $input)

for ichan in $(seq 0 $((nchan-1)))
do
  newfreq=$(echo 1400 + 0.01*$ichan | bc -l)
  echo "edit int:freq[$ichan]=$newfreq" >> $TMP
done

echo "unload ${CWD}/${output}" >> $TMP

chmod +x $TMP

$TMP -n
