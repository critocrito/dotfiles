#!/bin/bash

## WARNING: No guarantees. This might eat your mail in the case that
## it wrongly detects that offlineimap is not running and runs it
## again. (although offlineimap will also try to catch that case)

# -o run only once
# -f specify folders
# -u choose interface to be quit except in case of errors
# -l log to ~/.offlineimap.log

longcommand="offlineimap -o -u quiet"
shortcommand="offlineimap -o -f INBOX -u quiet"
# Time in seconds between long syncs:
longsyncdiff=1800 # 30 Minutes

# Check connection status
if ! ping -c1 www.google.com > /dev/null 2>&1; then
    # Ping could be firewalled ...
    # '-O -' will redirect the actual html to stdout and thus to /dev/null
    if ! wget -O - www.google.com > /dev/null 2>&1; then
        # Both tests failed. We are probably offline
        # (or google is offline, i.e. the end has come)
        exit 1;
    fi
fi

# Check if offlineimap is running:
pid=$(pgrep -f "/usr/bin/offlineimap")
if [[ ${pid} -gt 0 ]] ; then
    echo "Offlineimap is running with pid ${pid}"
    exit 1
fi

# Now we determine what to do based on the last time we did things:
curtime=$(date +%s)
if [ -e ~/.mail_lastlongsync ] ; then
    # Last sync file exists
    lastlongsync=$(<~/.mail_lastlongsync) >/dev/null # The unix time of the last long sync
    timediff=$(( curtime - lastlongsync ))
    if [ ${timediff} -gt ${longsyncdiff} ]; then
        echo ${curtime} > ~/.mail_lastlongsync
        exec ${longcommand}
    else
        exec ${shortcommand}
    fi
else
    # Do the long sync
    echo ${curtime} > ~/.mail_lastlongsync
    exec ${longcommand}
fi
