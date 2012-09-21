#!/bin/bash

### Global Variables ###
DATE_TIME=`date '+%m%d_%H%M%S'`
### Parameters ###
OPTION=$1
ASSIGNED_HOST=$2
ASSIGNED_COMPONENT_ID=$3
CONFIG_FILE=$4
JOB_NAME=$5
BUILD_NUMBER=$6
FQN=$7

function start_func {
if [ "$CONFIG_FILE" == "" ] || [ "$ASSIGNED_HOST" == "" ] || [ "$ASSIGNED_COMPONENT_ID" == "" ] || [ "$JOB_NAME" == "" ] || [ "$BUILD_NUMBER" == "" ] || [ "$FQN" == "" ]; then
  echo "-bash: wrong usage"
  echo "log_collector.sh start <assigned_host> <assigned_component_id> <config_file> <job_name> <build_number> <fqn>"
  exit 1
fi

# check config_file parameter
if [ ! -f "$CONFIG_FILE" -o "$CONFIG_FILE" == "" ]; then
  echo "-bash: No configuration file"
  exit 1
fi

#read configuration file
. $CONFIG_FILE

#check all variable in configuration file
printf "\n[-------------------- LOG COLLECTION TOOL --------------------]\n"
for ((i=0;i<${#HOST[@]};i++))
do
  if [ "${HOST[$i]}" == "$ASSIGNED_HOST" ] && [ "${COMPONENT_ID[$i]}" == "$ASSIGNED_COMPONENT_ID" ] ; then
    printf "%-12s:%-10s:%s\n" ${COMPONENT_ID[$i]} ${HOST[$i]} ${COMPONENT_LOG[$i]}
    INDEX=$i
    break
  fi
done

if [ -z "$INDEX" ]; then
  echo "[ERROR] NO COMPATIBLE HOST PROFILE FOR $ASSIGNED_COMPONENT_ID IN $ASSIGNED_HOST"
  echo "----------------------------------------------------------------------"
  exit
fi

# create log folder in test server
mkdir -p $TEST_SERVER_LOG_LOCATION/${JOB_NAME}_${BUILD_NUMBER}/$FQN
echo "Create a new folder on test server: $TEST_SERVER_LOG_LOCATION/${JOB_NAME}_${BUILD_NUMBER}/$FQN"

# run script in component server
echo "Start running log_sender.sh in ${HOST[$INDEX]} for ${COMPONENT_ID[$INDEX]}"
NEW_LOG_NAME=`basename ${COMPONENT_LOG[$INDEX]}`
ssh ngsuser@${HOST[$INDEX]} "nohup bash /home/ngsuser/work/log-collection/log_sender.sh start ${COMPONENT_LOG[$INDEX]} ${TEMP_FOLDER[$INDEX]} $NEW_LOG_NAME > foo.out 2> foo.err < /dev/null &"
printf "[---------------------------------------------------------------]\n\n"

}

function stop_func {
if [ "$ASSIGNED_HOST" == "" ] || [ "$ASSIGNED_COMPONENT_ID" == "" ]; then
  echo "-bash: wrong usage"
  echo "log_collector.sh stop <assigned_host> <assigned_component_id>"
  exit 1
fi

#check all variable in configuration file
printf "\n[-------------------- LOG COLLECTION TOOL --------------------]\n"

echo "Killing all tails from log_sender.sh in $ASSIGNED_HOST for $ASSIGNED_COMPONENT_ID"
ssh ngsuser@$ASSIGNED_HOST "nohup bash /home/ngsuser/work/log-collection/log_sender.sh stop > foo.out 2> foo.err < /dev/null &"
printf "[---------------------------------------------------------------]\n\n"

}

function copy_func {
  echo "COPY"
if [ "$CONFIG_FILE" == "" ] || [ "$ASSIGNED_HOST" == "" ] || [ "$ASSIGNED_COMPONENT_ID" == "" ] || [ "$JOB_NAME" == "" ] || [ "$BUILD_NUMBER" == "" ] || [ "$FQN" == "" ]; then
  echo "-bash: wrong usage"
  echo "log_collector.sh copy <assigned_host> <assigned_component_id> <config_file> <job_name> <build_number> <fqn>"
  exit 1
fi

# check config_file parameter
if [ ! -f "$CONFIG_FILE" -o "$CONFIG_FILE" == "" ]; then
  echo "-bash: No configuration file"
  exit 1
fi

#read configuration file
. $CONFIG_FILE

#check all variable in configuration file
printf "\n[-------------------- LOG COLLECTION TOOL --------------------]\n"
for ((i=0;i<${#HOST[@]};i++))
do
  if [ "${HOST[$i]}" == "$ASSIGNED_HOST" ] && [ "${COMPONENT_ID[$i]}" == "$ASSIGNED_COMPONENT_ID" ] ; then
    printf "%-12s:%-10s:%s\n" ${COMPONENT_ID[$i]} ${HOST[$i]} ${COMPONENT_LOG[$i]}
    INDEX=$i
    break
  fi
done

if [ -z "$INDEX" ]; then
  echo "[ERROR] NO COMPATIBLE HOST PROFILE FOR $ASSIGNED_COMPONENT_ID IN $ASSIGNED_HOST"
  echo "----------------------------------------------------------------------"
  exit
fi

# create log folder in test server
mkdir -p $TEST_SERVER_LOG_LOCATION/${JOB_NAME}_${BUILD_NUMBER}/$FQN
echo "Create a new folder on test server: $TEST_SERVER_LOG_LOCATION/${JOB_NAME}_${BUILD_NUMBER}/$FQN"

# run script in component server
NEW_LOG_NAME=`basename ${COMPONENT_LOG[$INDEX]}`
echo "Start copying ${TEMP_FOLDER[$INDEX]}/$NEW_LOG_NAME from ${HOST[$INDEX]}"
scp ngsuser@${HOST[$INDEX]}:"${TEMP_FOLDER[$INDEX]}/$NEW_LOG_NAME" "${TEST_SERVER_LOG_LOCATION}/${JOB_NAME}_${BUILD_NUMBER}/$FQN" 
printf "[---------------------------------------------------------------]\n\n"
}

if [ "$OPTION" == "start" ]; then
  start_func
elif [ "$OPTION" == "stop" ]; then
  stop_func
elif [ "$OPTION" == "copy" ]; then
  copy_func
else
  echo "wrong option (start/stop/copy)"
fi

