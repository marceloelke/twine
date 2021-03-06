#!/bin/sh

# source twine config
. twine-config.sh

#
# Check whether any redis-server* is running
#
if [ `ps ax | grep redis-server | grep -v grep | wc -l` -gt 0 ]; then
  echo =============================
  echo "FAILED redis-server or partition is already running"
  echo "You must manually \"kill -9 PID\""
  echo perhaps: `ps ax | grep redis-server | grep -v grep | sed "s: .*::" | sed "s:^:kill -9 :"`
  echo "or run twine-stop.sh"
  echo "============================="
  ps ax | grep redis-server | grep -v grep
  echo "============================="
  exit -1
fi

echo "============================="
echo "Installing gcc and monit"
echo "============================="

if [ `uname -v | grep Ubuntu | wc -c` -gt 6 ]; then
  sudo apt-get install gcc monit
else # gross assumption yum, redhat, centos
  yum install gcc monit
fi

if ! [ -e ${REDISVERSION}.tar.gz ]; then
  echo "============================="
  echo "Downloading $REDISVERSION"
  echo "============================="

  wget http://redis.googlecode.com/files/${REDISVERSION}.tar.gz
fi


#
# Check whether this version of redis is already extracted
#
if [ -d $REDISVERSION ]; then
  echo "============================="
  echo "Already extracted $REDISVERSION"
  echo "============================="
else
  echo "============================="
  echo "Extracting $REDISVERSION"
  echo "============================="

  tar xf ${REDISVERSION}.tar.gz
fi

#
# Change to newly extracted directory
#
cd $REDISVERSION

if [ -e redis-server ]; then
  echo "============================="
  echo "Already compiled $REDISVERSION"
  echo "============================="
else
  echo "============================="
  echo "Compiling $REDISVERSION"
  echo "============================="

  make
fi

if [ -r test-server.log ]; then
  echo "============================="
  echo "Skipping test and benchmark"
  echo "============================="
else
  ./redis-server > test-server.log &

  echo "============================="
  echo "Running test"
  echo "============================="

echo make test

  echo "============================="
  echo "Running benchmark"
  echo "============================="

echo ./redis-benchmark 

# echo =============================
# echo Cleanup source, etc
# echo =============================
# 
# mkdir src
# mv -f 00* *.c *.h *.o *txt BUGS Changelog client-libraries COPYING design-documents doc Makefile README redis.conf redis-benchmark TODO utils redis.tcl test-redis.tcl src

  #
  # Kill the redis-server process
  #
  echo "============================="
  echo "Killing redis-server used in tests"
  ps ax | grep redis-server | grep -v grep | sed "s: [a-z].*::" | sed "s:^:kill -9 :" | sh
  if [ `ps ax | grep -v grep | grep [0-9]../redis-server | wc -l` -gt 0 ]; then
    echo "FAILED to kill process"
    echo "You must manually: kill -9 PID"
    echo perhaps: `ps ax | grep redis-server | grep -v grep | sed "s: [a-z].*::" | sed "s:^:kill -9 :"`
    echo "or run twine-stop.sh"
  fi
  echo "============================="
  rm -f dump.rdb
fi

#
# leave the redis directory
#
cd ..

echo "============================="
echo "Done"
echo "============================="
