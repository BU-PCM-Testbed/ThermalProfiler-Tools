#!/bin/bash

#
# arguments
# $1           file to log temperature data
#
#
# author: Charlie De Vivero
# date  : 2014-07-24
#

# create/overwrite log file
if [ -n "$1" ]; then
  echo "Saving date to: $1"
  > $1
fi

# get start time
START_TIME=`date +%s`

while true; do

  # get time
  CURRENT_TIME=`date +%s`
  let "TIME_ELAPSED = $CURRENT_TIME - $START_TIME"

  # get temperature
  TEMPERATURE=`adb shell "cat /sys/class/thermal/thermal_zone7/temp"`

  # record time and temperature
  if [ -n "$1" ]; then
    echo "$TIME_ELAPSED, $TEMPERATURE" >> $1
  else
    echo "$TIME_ELAPSED, $TEMPERATURE"
  fi

  sleep 1

done

exit
