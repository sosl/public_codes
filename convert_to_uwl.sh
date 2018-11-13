#!/bin/bash
# written by Stefan Oslowski for P958

set -o nounset
set -o errexit

if [ $# -ne 2 ]
then
  echo usage: $0 input_schedule output_schedule
  echo e.g.,: $0 P958_bpsr.sch P958_medusa_converted.sch
  exit
fi

input=$1
output=$2

awk -F";" '{if (NR==1) print "# This was automatically converted. Needs DMs, search for XXX"; if (substr($1, 1, 1)=="#") print $0; else if (NF>1) {printf("%s ;%s ;", $1,$2); for (i=3; i < NF; i++) {sub(/^[ \t]+/, "", $i); key=substr($i, 1, 3); if (key=="d4_" || key=="CA_" || key=="tob" || key=="rcv" || key == "mod" || key == "cal" || key =="cfr" || key=="fdm" || key =="fda") printf("%s ;", $i)}; print "MED_PROC SRCH; MED_SUB 15; MED_BIT 8; MED_POL 4; MED_SMP 64; MED_CHAN 256; MED_DM XXX"} }' $input | sed 's/MULTI/UWL/g' | sed 's/BPSR/MEDUSA/g' > $output
