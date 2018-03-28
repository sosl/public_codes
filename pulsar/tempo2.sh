#!/bin/bash

# Copyright (C) 2018 by Stefan Oslowski
# Licensed under the Academic Free License version 3.0
# Brief explanation of the license can be found here:
# http://rosenlaw.com/OSL3.0-explained.htm
# Full text:
# http://opensource.org/licenses/AFL-3.0
# or see the LICENSE file in the top directory of the repo
# for the full text of the license

set -o errexit
set -o nounset

if [[ $# -eq 0 ]]
then
  echo usage: $0 tempo2_args
  exit
fi

par_count=0
tim_count=0
pars=()
tims=()
longest_tim=0
args=()

for x in $@
do
  if [[ "${x: -4}" == ".tim" ]]
  then
    let tim_count+=1
    tims+=("$x")
    args+=("$x")
    length=$(wc -l $x | awk '{print $1}')
    if [[ $length -gt $longest_tim ]]
    then
      longest_tim=$length
    fi
  elif [[ "${x: -4}" == ".par" ]]
  then
    let par_count+=1
    pars+=("$x")
    args+=("-f $x")
  elif [[ "${x}" == "-f" ]]
  then
    echo -n ""
  else
    args+=("$x")
  fi
done

echo found $par_count par files and $tim_count tim files of which longest had $longest_tim ToAs

adjusted_length=$(echo $longest_tim '*1.2' | bc -l | awk -F. '{print $1}')

echo Running:
echo tempo2 -npsr $par_count -nobs $adjusted_length ${args[@]}
tempo2 -npsr $par_count -nobs $adjusted_length ${args[@]}
