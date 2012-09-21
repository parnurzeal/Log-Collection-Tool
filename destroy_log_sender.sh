#!/bin/bash

CONFIG_FILE=$1
# check config_file parameter
if [ ! -f "$CONFIG_FILE" -o "$CONFIG_FILE" == "" ]; then
  echo " -bash: No configuration file"
  exit 1
fi

#read configuration file
. $CONFIG_FILE

printf "\n-------- start killing log_sender ---------\n"

for ((i=0;i<${#HOST[@]};i++))
do
  ssh ngsuser@${HOST[$i]} "ps x | grep 'loop.sh' | grep -v grep | awk '{printf \$1\" \"}'| xargs kill"
done

printf "\n------- finished kill ----------\n"

printf "\n------- delete all log collection tool on this server ------\n"

