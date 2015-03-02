#!/bin/bash

# android_thermal_profiler.sh start|home|record|benchmark|debug|ambientplus|ambientminus|(ambient <temp>)|(threads <num>)
#
# arguments:
# start           starts the app
# home            goes to the Android home screen
# record          presses the Record button
# benchmark       presses the Benchmark button
# debug           presses the Debug button
# ambientplus     presses the Ambient Temperature (+) button
# ambientminus    presses the Ambient Temperature (-) button
# ambient <temp>  specify <temp> as a floating point number. defines Ambient Temperature, in Celsius
# threads <num>   specify <num> as 1, 2, 3, or 4. defines number of benchmark threads to execute
# 

TESTBED_PEACLAB_NAME="com.testbed.peaclab"

if [ "$1" == "start" ]; then
  adb shell am start -n ${TESTBED_PEACLAB_NAME}.thermalprofiler/.Executive
  
elif [ "$1" == "home" ]; then
  adb shell input keyevent 3
  
elif [ "$1" == "record" ]; then
  adb shell am broadcast -a ${TESTBED_PEACLAB_NAME}.action.TPROF_COMMAND --es command record
  
elif [ "$1" == "benchmark" ]; then
  adb shell am broadcast -a ${TESTBED_PEACLAB_NAME}.action.TPROF_COMMAND --es command benchmark
  
elif [ "$1" == "debug" ]; then
  adb shell am broadcast -a ${TESTBED_PEACLAB_NAME}.action.TPROF_COMMAND --es command debug
  
elif [ "$1" == "ambientplus" ]; then
  adb shell am broadcast -a ${TESTBED_PEACLAB_NAME}.action.TPROF_COMMAND --es command ambient_inc
  
elif [ "$1" == "ambientminus" ]; then
  adb shell am broadcast -a ${TESTBED_PEACLAB_NAME}.action.TPROF_COMMAND --es command ambient_dec
  
elif [ "$1" == "ambient" ] && [ -n "$2" ]; then
  adb shell am broadcast -a ${TESTBED_PEACLAB_NAME}.action.TPROF_COMMAND --ef ambient ${2}
  
elif [ "$1" == "threads" ] && [ -n "$2" ]; then
  adb shell am broadcast -a ${TESTBED_PEACLAB_NAME}.action.TPROF_COMMAND --ei threads ${2}
  
else
  echo "usage: `basename $0` start|home|record|benchmark|debug|ambientplus|ambientminus|(ambient <temp>)|(threads <num>)"
  echo " "
  echo "arguments:"
  echo "  start           starts the app"
  echo "  home            goes to the Android home screen"
  echo "  record          presses the Record button"
  echo "  benchmark       presses the Benchmark button"
  echo "  debug           presses the Debug button"
  echo "  ambientplus     presses the Ambient Temperature (+) button"
  echo "  ambientminus    presses the Ambient Temperature (-) button"
  echo "  ambient <temp>  specify <temp> as a floating point number. defines Ambient Temperature, in Celsius"
  echo "  threads <num>   specify <num> as 1, 2, 3, or 4. defines number of benchmark threads to execute"
  
fi
