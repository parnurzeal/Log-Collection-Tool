#!/bin/bash

# set parameters
OPTION=$1
LOG_LOCATION=$2
TEMP_FOLDER=$3
NEW_LOG_NAME=$4
SEND_BACK_SERVER=$5
SEND_BACK_LOCATION=$6


if [ "$OPTION" == 'start' ]; then
	echo "create TEMP_FOLDER and start tail..."
	# create folder for temp log
	mkdir -p $TEMP_FOLDER
	# get into script directory
	cd $TEMP_FOLDER
	# create local log_file
	tail -fn0 $LOG_LOCATION | tee "$NEW_LOG_NAME" &
elif [ "$OPTION" == 'stop' ]; then
	echo "Kill all process (tail, tee)..."
	ps x | grep 'tail' | grep -v grep | awk '{printf $1" "}' | xargs kill
	echo "Finished..."
else
	echo "wrong option."
fi
