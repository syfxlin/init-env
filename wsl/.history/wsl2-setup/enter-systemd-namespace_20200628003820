#!/bin/bash --norc

if [ "$LOGNAME" != "root" ]; then
    echo "You need to run $0 through sudo"
    exit 1
fi

if [ -x /usr/sbin/daemonize ]; then
    DAEMONIZE=/usr/sbin/daemonize
elif [ -x /usr/bin/daemonize ]; then
    DAEMONIZE=/usr/bin/daemonize
else
    echo "Cannot execute daemonize to start systemd."
    exit 1
fi

if ! command -v /lib/systemd/systemd > /dev/null; then
    echo "Cannot execute /lib/systemd/systemd."
    exit 1
fi

if ! command -v /usr/bin/unshare > /dev/null; then
    echo "Cannot execute /usr/bin/unshare."
    exit 1
fi

SYSTEMD_EXE="/lib/systemd/systemd --system-unit=basic.target"
SYSTEMD_PID="$(ps -eo pid=,args= | awk '$2" "$3=="'"$SYSTEMD_EXE"'" {print $1}')"
if [ -z "$SYSTEMD_PID" ]; then
    "$DAEMONIZE" /usr/bin/unshare --fork --pid --mount-proc bash -c 'export container=wsl; mount -t binfmt_misc binfmt_misc /proc/sys/fs/binfmt_misc; exec '"$SYSTEMD_EXE"
    while [ -z "$SYSTEMD_PID" ]; do
        echo "Sleeping for 1 second to let systemd settle"
        sleep 1
        SYSTEMD_PID="$(ps -eo pid=,args= | awk '$2" "$3=="'"$SYSTEMD_EXE"'" {print $1}')"
    done
fi
