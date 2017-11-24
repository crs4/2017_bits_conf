#!/bin/sh
set -x
set -o errexit
set -o nounset

master="$(cat "${BITSCONF}/master")"

if [ "${HOSTNAME}" != "${master}" ]; then
  echo "This host '${HOSTNAME}' is not configured as master (currently ${master})." >&2
  echo "This script needs to be run from the master node" >&2
  exit 1
fi

hdfs namenode -format
start-dfs.sh
#start-yarn.sh
#/home/cesco/dump/hadoop/sbin/start-yarn.sh
#hadoop distcp file:///home/cesco/data/illumina.{tiny,small} /data/
#LP seems unused mypsh "mkdir -p /tmp/flink-tasktmp"
#mypsh "rsync -Pra /home/cesco/data/ref/ /tmp/ref/"
mypsh 'rsync -Pra /u/gmauro/data/references/ucsc/hg19/ucsc.hg19.* /tmp/ref/'
start-cluster.sh
