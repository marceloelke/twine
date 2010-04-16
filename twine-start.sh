#!/bin/bash

SERVERSUFFIX=redis-server-1.2.6
USE_HOST=$1

# source twine config
. twine-config.sh

# if no arguments, then we must be sure
# there is only one host in the partitions directory
if [ $# -eq 0 ]; then
  USE_HOST=_BOGUS_DIRECTORY_
  if [ `ls ${PARTDIR}|wc -l` -eq 1 ]; then
    if [ -r ${PARTDIR}/`ls ${PARTDIR}` ]; then 
      USE_HOST=`ls ${PARTDIR}`
    fi
  fi
fi

if ! [ -r ${PARTDIR}/$USE_HOST ]; then
  echo usage: twine-start HOST
  ls ${PARTDIR}
  exit 1
fi

cd ${PARTDIR}/${USE_HOST}
for server in `find -mindepth 1 -maxdepth 1 -type d`; do
  if [ -r ${server}/start.sh ]; then
    cd $server
    sh start.sh
    cd ..
  fi
done;
cd ../..

exit 0
