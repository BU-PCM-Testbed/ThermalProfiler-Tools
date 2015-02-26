#/bin/bash
# android_test_run_idle.sh
#

RUN_LOG_DIR='C:\Users\devivero\Dropbox\BU\Research\Testbed\agilent_capture\test_019'
echo $RUN_LOG_DIR

TEST_LIST_FILE='test_list_full_power_ramp.csv'
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

# start recording
echo "Start recording ... "
./android_thermal_profiler.sh record

for IDX in `seq $START_IDX $NUM_TESTS`; do
  
  CORES=`head -n $IDX $TEST_LIST_FILE | tail -1 | awk -F',' '{print $1;}'`
  FREQ=`head -n $IDX $TEST_LIST_FILE | tail -1 | awk -F',' '{print $2;}'`
  
  echo "RUNNING TEST CASE: ${CORES} cores, ${FREQ} MHz"
  echo '==========================='
  echo ' '

  # setup number of cores
  ./android_activate_cores.sh ${CORES}
  #./android_thermal_profiler.sh cores ${CORES}

  # set the frequency
  ./android_frequency.sh ${FREQ}

  # generate a tag for this test run
  TEST_ID="c${CORES}_${FREQ}M"
  echo $TEST_ID

  # nominal test run is 2 minute. sleep until end of test
  sleep 120

done

# stop recording
echo "Stop recording ... wait 3 minutes."
./android_thermal_profiler.sh record

# wait a few seconds while data is saved.
# retrieve the android data file.
sleep 180
echo "Retrieve data ... "
#adb pull /sdcard/Download/stat.csv "${RUN_LOG_DIR}\stat_${TEST_ID}.csv"
adb pull /sdcard/Download/stat.csv "${RUN_LOG_DIR}\stat.csv"
sleep 2