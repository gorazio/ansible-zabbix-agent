#!/bin/bash
### DESCRIPTION
# $1 - access key
# $2 - port
# $3 - metric


### OPTIONS VERIFICATION
[[ $# -lt 3 ]] && { echo "FATAL: some parameters not specified"; exit 1; }

### PARAMETERS
ACCESSKEY="$1"
PORT="$2"
METRIC="$3"

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
    $CURL -s --insecure "127.0.0.1:$PORT/api/slots.getSessionsCount?accessKey=$ACCESSKEY" > $CACHE || exit 1
fi

## get metrcs from cache:
/bin/cat $CACHE | jq .response.$METRIC

exit 0
