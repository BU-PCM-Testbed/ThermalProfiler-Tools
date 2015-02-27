#/bin/bash

#
# SET THE DIRECTORY TO SAVE TESTBED DATA
#
RUN_LOG_DIR='C:\Users\devivero\Dropbox\BU\Research\Testbed\agilent_capture\test_029'
echo $RUN_LOG_DIR

CORES='4'
#for CORES in `seq 2 4`; do
  for i in 384 594 810 1026 1242; do
  #for i in 384 486 594 702 810 918 1026 1134 1242; do
  
    echo "RUNNING TEST CASE: ${CORES} cores, ${i} MHz"
    echo '==========================='
    echo ' '

    # setup number of cores
    ./android_activate_cores.sh ${CORES}

    # set the frequency
    ./android_frequency.sh ${i}

    # generate a tag for this test run
    TEST_ID="c${CORES}_${i}M"
    echo "Tag: ${TEST_ID}"
    
    # wait for temperature to settle
    sleep 480

    # start recording
    echo "Start recording ... "
    ./android_thermal_profiler.sh record

    # nominal test run is 3 minute(s). sleep until end of test
    sleep 120

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
#done
