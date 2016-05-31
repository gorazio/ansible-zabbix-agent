#!/bin/bash
### DESCRIPTION
# $1 - user
# $2 - password
# $3 - port
# $4 - metric


### OPTIONS VERIFICATION
[[ $# -lt 4 ]] && { echo "FATAL: some parameters not specified"; exit 1; }

### PARAMETERS
USER="$1"
PASSWORD="$2"
PORT="$3"
METRIC="$4"

CACHETTL="10" # cache time in seconds
CACHE="/tmp/gameserver-session"
CURL=$(which curl)

### RUN
## Cache check:
# time of cache creation, 0 if no cache file or its size is zero
if [ -s "$CACHE" ]; then
    TIMECACHE=`/usr/bin/stat -c"%Z" "$CACHE"`
else
    TIMECACHE=0
fi

# current time
TIMENOW=`/bin/date '+%s'`

# If cache too old - update it
if [ "$(($TIMENOW - $TIMECACHE))" -gt "$CACHETTL" ]; then
    ACCESSKEY=`$CURL -s -X POST -u "$USER:$PASSWORD" 127.0.0.1:$PORT/api/slots.auth | jq .response.accessKey | sed -e 's/^"//'  -e 's/"$//'`
    $CURL -s --insecure "127.0.0.1:$PORT/api/slots.getSessionsCount?accessKey=$ACCESSKEY" > $CACHE || exit 1
fi

## get metrcs from cache:
/bin/cat $CACHE | jq .response.$METRIC

exit 0
