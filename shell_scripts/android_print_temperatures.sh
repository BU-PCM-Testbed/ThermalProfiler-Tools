#!/bin/bash

#
# arguments
# $1           enable: first enables the thermal zone sensors
#
#
# author: Charlie De Vivero
# date  : 2014-07-24
#

TEMPERATURES=""

for i in {0..12}; do
  
  if [ "$1" == "enable" ]; then
    echo "Enabling thermal zone ${i} ..."
    adb shell "su -c 'echo enabled > /sys/class/thermal/thermal_zone${i}/mode'"
  fi
  
  TEMP=`adb shell "cat /sys/class/thermal/thermal_zone${i}/temp"`
  
  TEMPERATURES="${TEMPERATURES}zone ${i} = ${TEMP}\n"
done

echo -e $TEMPERATURES

