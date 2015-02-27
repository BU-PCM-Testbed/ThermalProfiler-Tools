#!/bin/bash
#
# Run this script once every time you boot the IFC6410. This script will:
#
# * Disable *mpdecision*
# * Disable *thermald*
# * Activate all 4 cores
# * Set CPU core governors to *userspace*
# * Enable all thermal sensors
# * Set system time to current time
#
#

# stop mpdecision (multiprocessor management)
adb shell "su -c 'stop mpdecision'"
echo "Service stopped: mpdecision"

# stop thermal daemon (temperature management)
adb shell "su -c 'stop thermald'"
echo "Service stopped: thermald"

# mount system
# -- i don't think this is necessary anymore --
#adb shell "su -c 'mount -o rw,remount /system'"

# turn on all the cores so we can change their governors
./android_activate_cores.sh 4

# set userspace governor
for i in `seq 0 3`; do
  FREQ_DIR="/sys/devices/system/cpu/cpu${i}/cpufreq/"
  GOV_FILE="${FREQ_DIR}scaling_governor"
  
  # only set it if the CPU is active
  DIR_EXISTS=`adb shell "cd $FREQ_DIR"`
  if [ -z "$DIR_EXISTS" ]; then
    adb shell "su -c 'echo userspace > ${GOV_FILE}'"
    
    # verify governor was set
    GOVERNOR=`adb shell "su -c 'cat ${GOV_FILE}'"`
    echo "CPU${i} governor set to: ${GOVERNOR}"
  else
    echo "CPU${i} is inactive"
  fi
  
done

# enable all temperature sensors
for i in {0..12}; do
  echo "Enabling thermal zone ${i} ..."
  adb shell "su -c 'echo enabled > /sys/class/thermal/thermal_zone${i}/mode'"
done

# set the current date/time
CURRENT_SECOND=`date +%S`
while [ "$CURRENT_SECOND" -eq "`date +%S`" ]; do
  :
done

SYSTEM_TIME=`date +%Y%m%d.%H%M%S`
adb shell "su -c 'date -s ${SYSTEM_TIME}'"
