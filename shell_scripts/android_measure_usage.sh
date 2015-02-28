#!/bin/bash
#
# script to measure CPU usage of ThermalProfiler
#
# usage: $ android_measure_usage.sh [time]
#
# optional:
# [time]    time interval (seconds) to sample CPU usage (defaults to 5 sec)
#

SLEEP_TIME="5"
if [ -n "$1" ]; then
  SLEEP_TIME="$1"
fi

# get PID of ThermalProfiler app
ANDROID_PS=$(adb shell ps | grep "com.testbed.peaclab.thermalprofiler")
THERMAL_PROF_PID=$(echo "$ANDROID_PS" | awk '{print $2}')

################################################################################
function GET_TP_CPU_TIMES()
{
  # copy in /proc/stat
  ANDROID_STAT=$(adb shell "cat /proc/stat" | head -n 1)

  # sum up all values
  CPU_TIME_TOTAL="0"
  for TOK in `seq 2 11`; do
    CPU_TIME=$(echo "$ANDROID_STAT" | awk -v tok="$TOK" '{print $tok}')
    let "CPU_TIME_TOTAL = $CPU_TIME_TOTAL + $CPU_TIME"
  done
  
  # copy in /proc/<PID>/stat
  THERMAL_PROF_STAT=$(adb shell "cat /proc/${THERMAL_PROF_PID}/stat")

  TP_UTIME=$(echo "$THERMAL_PROF_STAT" | awk '{print $14}')
  TP_STIME=$(echo "$THERMAL_PROF_STAT" | awk '{print $15}')
  let "TP_TIME_TOTAL = $TP_UTIME + $TP_STIME"
}
################################################################################

echo "sleep  : $SLEEP_TIME sec"
echo "PID    : $THERMAL_PROF_PID"

# get CPU time stats
GET_TP_CPU_TIMES
CPU_TIME_1=$CPU_TIME_TOTAL
TP_TIME_1=$TP_TIME_TOTAL

####################
# sleep for a while
####################
sleep ${SLEEP_TIME}

# get CPU stats again
GET_TP_CPU_TIMES
CPU_TIME_2=$CPU_TIME_TOTAL
TP_TIME_2=$TP_TIME_TOTAL

###################

echo "before : $TP_TIME_1 / $CPU_TIME_1"
echo "after  : $TP_TIME_2 / $CPU_TIME_2"

let "CPU_DELTA = $CPU_TIME_2 - $CPU_TIME_1"
let "TP_DELTA = $TP_TIME_2 - $TP_TIME_1"

echo "delta  : $TP_DELTA / $CPU_DELTA"

TP_USAGE=$(bc <<< "scale=4; ${TP_DELTA} * 100.0 / ${CPU_DELTA}")
echo "usage  : $TP_USAGE %"