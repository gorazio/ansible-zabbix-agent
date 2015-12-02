#!/bin/bash
### DESCRIPTION
# $1 - имя слотсервера, он же путь
# $2 - измеряемая метрика

### OPTIONS VERIFICATION
if [[ -z "$1" || -z "$2" ]]; then
    exit 1
 fi

### PARAMETERS
SLOT="$1" # адрес nginx статистики
METRIC="$2"  # измеряемая метрика

CACHETTL="10" # Время действия кеша в секундах (чуть меньше чем период опроса элементов)
CACHE="/tmp/slotserver-stats-`echo $SLOT`.cache"
PATH="/opt/slotserver/bin/`echo $SLOT`/connections.txt"

if [ "$METRIC" = "alive" ]; then
    /bin/ps ax|/bin/grep -v grep|/bin/grep -c $SLOT
    exit 0
 fi
### RUN
## Проверка кеша:
# время создание кеша (или 0 есть файл кеша отсутствует или имеет нулевой размер)
if [ -s "$CACHE" ]; then
    TIMECACHE=`/usr/bin/stat -c"%Z" "$CACHE"`
 else
    TIMECACHE=0
 fi

# текущее время
TIMENOW=`/bin/date '+%s'`

# Если кеш неактуален, то обновить его (выход при ошибке)
if [ "$(($TIMENOW - $TIMECACHE))" -gt "$CACHETTL" ]; then
    /bin/cat $PATH  > $CACHE || exit 1
 fi

## Извлечение метрики:
if [ "$METRIC" = "connections" ]; then
    /bin/cat $CACHE | /usr/bin/cut -d' ' -f3
 else
  exit 0
 fi


exit 0
