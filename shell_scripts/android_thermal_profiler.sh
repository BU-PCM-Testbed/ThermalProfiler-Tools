#!/bin/bash

if [ "$1" == "start" ]; then
  adb shell am start -n com.testbed.thermalprofiler/.MainActivity
  
elif [ "$1" == "home" ]; then
  adb shell input keyevent 3
  
elif [ "$1" == "record" ]; then
  adb shell input tap 1200 200
  
elif [ "$1" == "benchmark" ]; then
  adb shell input tap 1200 450
  
#elif [ "$1" == "utilization" ]; then
#  adb shell input tap 478 126
  
elif [ "$1" == "debug" ]; then
  adb shell input tap 310 700

elif [ "$1" == "ambientplus" ]; then
  adb shell input tap 570 200

elif [ "$1" == "ambientminus" ]; then
  adb shell input tap 620 200
  
elif [ "$1" == "threads" ]; then
  if [ "$2" -eq "1" ]; then
    adb shell input tap 168 162
    
  elif [ "$2" -eq "2" ]; then
    adb shell input tap 322 162
    
  elif [ "$2" -eq "3" ]; then
    adb shell input tap 474 162
    
  elif [ "$2" -eq "4" ]; then
    adb shell input tap 623 162
  fi
  
else
  echo "usage: `basename $0` [start|home|record|benchmark|utilization|debug|[cores 1|2|3|4]]"
fi
