#/bin/bash

# show usage
show_usage() {
  echo -e "Usage: `basename $0` <log dir> [<test list> [index]] \n"
  echo -e "  arguments:"
  echo -e "  <log dir>         directory to save experiment data \n"
  echo -e "  optional:"
  echo -e "  <test list>       filename of test list to use"
  echo -e "  <index>           line number from <test list> to start from \n"
}

# exit if less than 1 argument
if [ "$#" -lt 1 ] ; then
  echo -e "Not enough arguments \n\n"
  show_usage
  exit

# show usage if help requested
elif [ "$1" == "-h" ] || [ "$1" == "--help" ] ; then
  show_usage
  exit
fi

#
# SET THE DIRECTORY TO SAVE TESTBED DATA
#
RUN_LOG_DIR='C:\Users\devivero\Dropbox\BU\Research\Testbed\agilent_capture\idle_400'
if [ -d "$1" ]; then
  RUN_LOG_DIR="$1"
else
  echo -e "Invalid directory: $1 \n\n"
  show_usage
  exit
fi

TEST_LIST_FILE='test_list_full_power_ramp.csv'
if [ -f "$2" ]; then
  TEST_LIST_FILE="$2"
else
  echo -e "!! Using default test list !! \n"
fi
NUM_TESTS=`wc -l $TEST_LIST_FILE | awk '{print $1;}'`

START_IDX="1"
if [ -n "$3" ]; then
  START_IDX="$3"
  if [ "$START_IDX" -gt "$NUM_TESTS" ] || [ "$START_IDX" -lt "1" ]; then
    echo -e "Invalid start index (min: 1, max: ${NUM_TESTS}) \n\n"
    show_usage
    exit
  fi
fi

let "NUM_TESTS_TO_RUN = $NUM_TESTS - $START_IDX + 1"

echo " "
echo "Log directory  :    ${RUN_LOG_DIR}"
echo "Test list      :    ${TEST_LIST_FILE}"
echo "Starting from  :    Test # ${START_IDX}"
echo "No. of tests   :    $NUM_TESTS_TO_RUN"
echo " "

for IDX in `seq $START_IDX $NUM_TESTS`; do
  
  CORES=`head -n $IDX $TEST_LIST_FILE | tail -1 | awk -F',' '{print $1;}'`
  FREQ=`head -n $IDX $TEST_LIST_FILE | tail -1 | awk -F',' '{print $2;}'`
  
  echo -e "\nRUNNING TEST CASE: ${CORES} cores, ${FREQ} MHz"
  echo -e "=========================== \n"

  # setup number of cores
  ./android_activate_cores.sh ${CORES}

  # set the frequency
  ./android_frequency.sh ${FREQ}

  # generate a tag for this test run
  TEST_ID="c${CORES}_${FREQ}M"
  echo $TEST_ID
  
  # wait for temperatures to settle
  echo "Waiting ..."
  sleep 120
  
  # start recording
  echo "Start recording ... "
  ./android_thermal_profiler.sh record

  # nominal test run is 2 minutes
  sleep 120
  
  # stop recording
  echo "Stop recording ..."
  ./android_thermal_profiler.sh record

  # wait a few seconds while data is saved.
  # retrieve the android data file.
  sleep 2
  echo "Retrieve data ... "
  adb pull /sdcard/Download/stat.csv "${RUN_LOG_DIR}\stat_${TEST_ID}.csv"
  sleep 2

done
