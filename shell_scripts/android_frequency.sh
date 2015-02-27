#!/bin/bash
#
# script to set up CPU frequency
#
# arguments:
# $1    frequency in MHz
#

if [ -z "$1" ]; then
  echo "usage: `basename $0` <speed (in MHz)>"
  echo ""
  echo "  arguments:"
  echo "  <frequency>     specify 384, 486, 594, 702, 810, 918, 1026, 1134, or 1242"
  exit
fi

FREQUENCY="${1}000"

# set CPU frequencies
for i in `seq 0 3`; do
  FREQ_DIR="/sys/devices/system/cpu/cpu${i}/cpufreq/"
  FREQ_FILE="${FREQ_DIR}scaling_setspeed"
  
  # only set it if the CPU is active
  DIR_EXISTS=`adb shell "cd $FREQ_DIR"`
  if [ -z "$DIR_EXISTS" ]; then
    adb shell "su -c 'echo ${FREQUENCY} > ${FREQ_FILE}'"
    
    # verify governor was set
    CUR_FREQ=`adb shell "su -c 'cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq'"`
    echo "CPU${i} frequency set to: ${CUR_FREQ}"
  else
    echo "CPU${i} is inactive"
  fi
  
done
