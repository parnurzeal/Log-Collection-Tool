#!/bin/bash
clear

### Global Variables ###
#CurrentDirectory=`pwd`
DATE_TIME=`date '+%m%d_%H%M%S'`

NewLogDirectory="/home/ngsuser/myPlayGround/log-collection/log/$DATE_TIME"

ZookeeperLog="/home/ngsuser/var/log/zookeeper/zookeeper-1/zookeeper.log"
SolrLog8985="/home/ngsuser/var/log/solr/solr-rps_product_cluster1_1/8985/solr.log"
SolrLog8983="/home/ngsuser/var/log/solr/solr-rps_product_cluster1_1/8983/solr.log"
HttpgatewayLog="/home/ngsuser/var/log/httpgateway/httpgateway-1/httpgateway.log"
IndexerLog="/home/ngsuser/var/log/indexer/indexer-rps_product_cluster1_1/indexer.log"
CassandraLog="/home/ngsuser/var/log/cassandra/node0/system.log"
CatalinaLog="/home/ngsuser/var/log/searchapi/searchapi-rps_product_cluster1_1/catalina.out"
#SearchapiLog="/home/ngsuser/var/log/searchapi/searchapi-rps_product_cluster1_1/SearchAPI/access.log.`date '+%Y-%m-%d'`"
 
### Log File Function ###
log_it()
{
 file="$NewLogDirectory/$1";
 log="$2";
 echo $log >> $file
}

log_component()
{
  NewLogName=$1;
  ComponentLog=$2;
  echo $ComponentLog
  tail -fn0 $ComponentLog | while read line ; do
    echo "$line" > grep ""
    if [ $?=0 ]; then
	log_it "$NewLogName.log" "$line"
    fi
  done &
}


### Main Process ###
mkdir $NewLogDirectory
cd $NewLogDirectory

log_component "zookeeper" $ZookeeperLog
log_component "solr8985" $SolrLog8985
log_component "solr8983" $SolrLog8983
log_component "httpgateway" $HttpgatewayLog
log_component "indexer" $IndexerLog
log_component "catalina" $CatalinaLog
log_component "cassandra" $CassandraLog

#cd $CurrentDirectory
