#!/bin/bash

#rsync -zvr /home/parnurzeal/workspace/log-collection3/ $DIRECTORY

CONFIG_FILE=$1

# check config_file parameter
if [ ! -f "$CONFIG_FILE" -o "$CONFIG_FILE" == "" ]; then
  echo "-bash: No configuration file"
  exit 1
fi

#read configuration file

. $CONFIG_FILE

#check all variable in configuration file
echo "Start deploy..."
for ((i=0;i<${#HOST[@]};i++))
do
  ssh ngsuser@${HOST[$i]} "mkdir -p /home/ngsuser/work/log-collection/"
  scp ./log_sender.sh ngsuser@${HOST[$i]}:/home/ngsuser/work/log-collection/
done



