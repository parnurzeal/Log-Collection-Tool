#!/bin/bash

# set parameters
CONFIG_FILE=$1
NUM=$2
DATE_TIME=$3

. $CONFIG_FILE

echo $TEST_NAME $TEST_SERVER $TEST_SERVER_LOG_LOCATION ${COMPONENT_LOG[$NUM]}

# get into script directory
cd ${TEMP_FOLDER[$NUM]}
# create local log_file
tail -fn0 ${COMPONENT_LOG[$NUM]} | tee "${COMPONENT_NAME[$NUM]}.log" &
while :
do
  sleep 1
  result=$(ps x| grep 'loop.sh' | grep -v grep |  wc -l)
  #echo "RESULT is $result"
  if [ $result -eq 0 ]; then
    ps x | grep 'tail' | grep -v grep | awk '{printf $1" "}' | xargs kill
    break
  fi
done

echo "Finished. Start sending ${COMPONENT_NAME[$NUM]}.log to $TEST_SERVER_LOG_LOCATION/$TEST_NAME/$DATE_TIME"
# send finished log file to test server
scp ${COMPONENT_NAME[$NUM]}.log $TEST_SERVER:$TEST_SERVER_LOG_LOCATION/$TEST_NAME/$DATE_TIME
echo "Finished sending file. now closing client script...."
#echo "Delete itself..."
#rm -rf $CSCRIPT_LOCATION
