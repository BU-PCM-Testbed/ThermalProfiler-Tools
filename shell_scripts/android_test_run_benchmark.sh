#/bin/bash

RUN_LOG_DIR='C:\Users\devivero\Dropbox\BU\Research\Testbed\agilent_capture\lu_137'
echo $RUN_LOG_DIR

#CORES="4"
for CORES in `seq 3 4`; do
  for i in 594 810 1026 1242; do

    echo " "
    echo "RUNNING TEST CASE: ${CORES} cores, ${i} MHz"
    echo "==========================="
    echo " "

    # setup number of cores
    ./android_activate_cores.sh ${CORES}
    ./android_thermal_profiler.sh threads ${CORES}

    # set the frequency
    ./android_frequency.sh ${i}

    # generate a tag for this test run
    TEST_ID="c${CORES}_${i}M"
    echo $TEST_ID

    # start recording
    echo "Start recording ... "
    ./android_thermal_profiler.sh record

    # wait for 90 seconds while temperature settles
    sleep 90

    # start benchmark
    echo "Start benchmark ... "
    ./android_thermal_profiler.sh benchmark

    # nominal test run is 3.0 minutes. sleep until end of test
    sleep 180

    # stop recording
    echo "Stop recording ... "
    ./android_thermal_profiler.sh record

    # wait a few seconds while data is saved.
    # retrieve the android data file.
    sleep 2
    echo "Retrieve data ... "
    adb pull /sdcard/Download/stat.csv "${RUN_LOG_DIR}\stat_${TEST_ID}.csv"
    sleep 2
    
  done
  
  #echo "-----------------------------------"
  #echo "- CHANGING ACTIVE CORES ..."
  #echo "-----------------------------------"
  #echo " "
  #sleep 240
done
