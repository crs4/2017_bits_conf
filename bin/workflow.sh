#!/bin/bash

set -o errexit
set -o nounset

OutputBase="."
NumNodes=-1
# The reference must exist on each slave node
Reference="/tmp/ref/ucsc.hg19.fasta"
SampleSheetsDir="/u/cesco/dump/sample_sheets"


# inside BITSCONF directory
Header="ucsc19_cram_header"
Properties="bclconverter.properties"

function timestamp() {
  date +"%Y:%m:%d-%H:%M:%S"
  return 0
}

function log() {
  echo $(timestamp) -- "${@}" >&2
  return 0
}

function error() {
  if [ $# -gt 0 ] ; then
    log "${@}"
  else
    log "There was an error, but I don't know what happened"
  fi
  exit 1
}
  
function usage_error() {
  echo "USAGE: $0 { run_dir_path }+" >&2
  exit 1
}

########### main ###########

if [ $# -le 0 ]; then
  usage_error
fi

if [ -z "${BITSCONF:-}" ]; then
  error "BITSCONF environment variable undefined.  You must source 'source_me.sh' before running this workflow"
fi

if [ ! -d "${BITSCONF:-}" ]; then
  error "BITSCONF environment variable doesn't point to a directory (${BITSCONF})"
fi

for run_dir in "${@}"; do
  if [ ! -d "${run_dir}" -o ! -d "${run_dir}/raw" ]; then
    error "Path ${run_dir} doesn't seem to be one of our run directories"
  fi
  SampleSheetFile="${SampleSheetsDir}/$(basename ${run_dir}).csv"
  if [ ! -f "${SampleSheetFile}" ]; then
    error "Missing sample sheet file ${SampleSheetFile}"
  fi
done

if [ "${NumNodes}" -le 0 ]; then
  NumNodes=$(cat ${BITSCONF}/slaves | wc -l)
  if [ "${NumNodes}" -le 0 ]; then # if NumNodes isn't an integer bash should generate an error
    error "Couldn't get number of slave nodes"
  fi
fi

HeaderFull="${BITSCONF}/${Header}"
if [ ! -f "${HeaderFull}" ]; then
  error "Missing header file ${HeaderFull}"
fi

PropertiesFull="${BITSCONF}/${Properties}"
if [ ! -f "${PropertiesFull}" ]; then
  error "Missing properties file ${PropertiesFull}"
fi

LogFile="workflow_log.start_$(timestamp)"

# See all output (stdout and stderr) to tee which will also write it to the log file
exec > >(tee "${LogFile}") 2>&1

log "Running workflow on $# run directories"

for run_dir in "${@}"; do
  log "Starting with ${run_dir}"
  SampleSheetFile="${SampleSheetsDir}/$(basename ${run_dir}).csv"
  log "Using sample sheet ${SampleSheetFile}"
  time flink_pipe  "${run_dir}/raw" "${OutputBase}/$(basename "${run_dir}").cram" ${NumNodes} "${HeaderFull}" "${Reference}" "${PropertiesFull}" "${SampleSheetFile}"
  log "Finished ${run_dir}"
done
