#/bin/bash
# android_test_run_idle.sh
#

RUN_LOG_DIR='C:\Users\Charlie\Dropbox\BU\Research\Testbed\agilent_capture\lu_202'
echo $RUN_LOG_DIR

TEST_LIST_FILE='test_list_steady_state.csv'
NUM_TESTS=`wc -l $TEST_LIST_FILE | awk '{print $1;}'`

START_IDX="1"
if [ -n "$1" ]; then
  START_IDX="$1"
  if [ "$START_IDX" -gt "$NUM_TESTS" ]; then
    echo "invalid start index"
    exit
  fi
fi

let "NUM_TESTS_TO_RUN = $NUM_TESTS - $START_IDX + 1"
echo "Running: $NUM_TESTS_TO_RUN tests ..."
echo " "

for IDX in `seq $START_IDX $NUM_TESTS`; do
  
  CORES=`head -n $IDX $TEST_LIST_FILE | tail -1 | awk -F',' '{print $1;}'`
  FREQ=`head -n $IDX $TEST_LIST_FILE | tail -1 | awk -F',' '{print $2;}'`
  
  echo "RUNNING TEST CASE: ${CORES} cores, ${FREQ} MHz"
  echo "====================================="

  # setup number of cores
  ./android_activate_cores.sh ${CORES}
  ./android_thermal_profiler.sh threads ${CORES}

  # set the frequency
  ./android_frequency.sh ${FREQ}

  # generate a tag for this test run
  TEST_ID="c${CORES}_${FREQ}M"
  echo "== Test ID: ${TEST_ID}"
  echo "===================="

  # start recording
  echo "Start recording ... "
  ./android_thermal_profiler.sh record

  # wait 5 seconds before benchmark start
  sleep 5
  
  # start benchmark
  echo "Start benchmark ... "
  ./android_thermal_profiler.sh benchmark

  # nominal test run is 5 minutes. sleep until end of test
  sleep 660
  
  # stop benchmark
  echo "Stop benchmark ... "
  ./android_thermal_profiler.sh benchmark
  
  sleep 4

  # stop recording
  echo "Stop recording ... "
  ./android_thermal_profiler.sh record
  
  # wait a few seconds while data is saved.
  # retrieve the android data file.
  sleep 2
  echo "Retrieve data ... "
  adb pull /sdcard/Download/stat.csv "${RUN_LOG_DIR}\stat_${TEST_ID}.csv"
  sleep 2
  echo " "

done
