#!/bin/bash

### Global Variables ###
DATE_TIME=`date '+%m%d_%H%M%S'`
### Parameters ###
CONFIG_FILE=$1

# check config_file parameter
if [ ! -f "$CONFIG_FILE" -o "$CONFIG_FILE" == "" ]; then
  echo "-bash: No configuration file"
  exit 1
fi

#read configuration file
. $CONFIG_FILE

#check all variable in configuration file
printf "\n[-------------------- ALL HOST PROFILE --------------------]\n"
for ((i=0;i<${#HOST[@]};i++))
do
  printf "%-12s:%-10s:%s\n" ${COMPONENT_NAME[$i]} ${HOST[$i]} ${COMPONENT_LOG[$i]}
done
printf "[----------------------------------------------------------]\n\n"

#start log_receiver script
bash log_updater.sh

mkdir -p $TEST_SERVER_LOG_LOCATION/$TEST_NAME/$DATE_TIME
echo "Create a new folder on test server: $TEST_SERVER_LOG_LOCATION/$TEST_NAME/$DATE_TIME"

#send script to designated component server
for ((i=0;i<${#HOST[@]};i++))
do
  ssh ngsuser@${HOST[$i]} "mkdir -p ${TEMP_FOLDER[$i]}" 
  scp $CSCRIPT_NAME ngsuser@${HOST[$i]}:${TEMP_FOLDER[$i]} 
  scp $CONFIG_FILE ngsuser@${HOST[$i]}:${TEMP_FOLDER[$i]}
## start the loop
  scp "loop.sh" ngsuser@${HOST[$i]}:${TEMP_FOLDER[$i]}
  ssh ngsuser@${HOST[$i]} "nohup bash ${TEMP_FOLDER[$i]}/loop.sh > foo.out 2> foo.err < /dev/null &"
  echo "start loop.sh"
## run script in that component
  ssh ngsuser@${HOST[$i]} "nohup bash ${TEMP_FOLDER[$i]}/$CSCRIPT_NAME ${TEMP_FOLDER[$i]}/$CONFIG_FILE $i $DATE_TIME > foo.out 2> foo.err < /dev/null &"
done

