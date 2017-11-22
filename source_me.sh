module load jdk1.8.0_144

export DUMP_DIR=~cesco/dump
echo "Adding "dump" bin directories to PATH"
export PATH="${DUMP_DIR}/bits_conf/bin:${DUMP_DIR}/hadoop/bin:${DUMP_DIR}/flink/bin:${DUMP_DIR}/kafka/bin:${DUMP_DIR}/hadoop/sbin:~cesco/bin:${PATH}"

#export HADOOP_CONF_DIR="${DUMP_DIR}/bits_conf/hadoop_conf"
