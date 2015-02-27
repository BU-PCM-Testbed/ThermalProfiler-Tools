#!/bin/bash
#
# Enable 1, 2, 3, or 4 CPU cores. Remaining CPU cores are disabled.
#
# arguments:
# $1    number of cores [1-4]
#

NUM_CORES_ON=$1

if [ -z "$NUM_CORES_ON" ] || [ "$NUM_CORES_ON" -lt "1" ] || [ "$NUM_CORES_ON" -gt "4" ]; then
  echo "usage: `basename $0` <cores>"
  echo ""
  echo "  arguments:"
  echo "  <cores>         any number between 1 and 4, inclusive"
  exit
fi

# set up variables
let "FIRST_CORE_OFF = $NUM_CORES_ON + 1"
CPU_DIR_PREFIX="/sys/devices/system/cpu/cpu"
CPU_ACTIVATE="/online"

# Activate CPU cores
#-------------------------------------------------------------------------------
echo "* ENABLE CORES"
for i in `seq 1 $NUM_CORES_ON`; do
  let "CPU_NUM = $i - 1"
  CPU_FILE="${CPU_DIR_PREFIX}${CPU_NUM}${CPU_ACTIVATE}"
  echo "echo 1 > $CPU_FILE"
  adb shell "su -c 'echo 1 > $CPU_FILE'"
done

# Enable read/write permissions for all users
#-------------------------------------------------------------------------------
# on the activate cpu core file handles
echo "* SET PERMISSIONS"
CPU_DIR_PREFIX="/sys/devices/system/cpu/cpu"
CPU_ACTIVATE="/online"
for i in `seq 1 $NUM_CORES_ON`; do
  let "CPU_NUM = $i - 1"
  CPU_FILE="${CPU_DIR_PREFIX}${CPU_NUM}${CPU_ACTIVATE}"
  echo "chmod 666 $CPU_FILE"
  adb shell "su -c 'chmod 666 $CPU_FILE'"
done
# on the cpu frequency setting file handles
CPU_FREQUENCY="/cpufreq/scaling_setspeed"
for i in `seq 1 $NUM_CORES_ON`; do
  let "CPU_NUM = $i - 1"
  CPU_FILE="${CPU_DIR_PREFIX}${CPU_NUM}${CPU_FREQUENCY}"
  echo "chmod 666 $CPU_FILE"
  adb shell "su -c 'chmod 666 $CPU_FILE'"
done

# Deactivate remaining CPU cores
#-------------------------------------------------------------------------------
if [ "$FIRST_CORE_OFF" -le "4" ]; then
  echo "* DISABLE REMAINING CORES"
  for i in `seq $FIRST_CORE_OFF 4`; do
    let "CPU_NUM = $i - 1"
    CPU_FILE="${CPU_DIR_PREFIX}${CPU_NUM}${CPU_ACTIVATE}"
    echo "echo 0 > $CPU_FILE"
    adb shell "su -c 'echo 0 > $CPU_FILE'"
  done
fi
