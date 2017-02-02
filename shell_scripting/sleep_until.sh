#!/bin/bash

current_epoch=$(date +%s)
target_epoch=$(date -d '11/01/2014 00:17' +%s)

sleep_seconds=$(( $target_epoch - $current_epoch ))

echo sleep $sleep_seconds
