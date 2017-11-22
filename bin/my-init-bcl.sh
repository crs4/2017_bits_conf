#!/bin/sh
set -x
set -o errexit
set -o nounset

/home/cesco/dump/hadoop/bin/hdfs namenode -format
/home/cesco/dump/hadoop/sbin/start-dfs.sh
#/home/cesco/dump/hadoop/sbin/start-yarn.sh
#hadoop distcp file:///home/cesco/data/illumina.{tiny,small} /data/
/home/cesco/bin/mypsh "mkdir -p /tmp/flink-tasktmp"
/home/cesco/bin/mypsh "rsync -Pra /home/cesco/data/ref/ /tmp/ref/"
/home/cesco/dump/flink/bin/start-cluster.sh
