# source twine config
. twine-config.sh


if [ -r "${PARTDIR}" ]; then
  $FINDCMD ${PARTDIR} -name redis.pid|\
        sed s:redis.pid:stop.sh:|sed s:^:sh\ :|sh
fi
ps ax | grep redis-server | grep -v grep |\
        sed "s: [a-z].*::" | sed "s:^:kill -9 :" | sh

