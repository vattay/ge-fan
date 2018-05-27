#!/bin/bash
if [ -z ${SLOG+x} ]; then 
    SLOG_STD='/dev/null' 
    SLOG_ERR='/dev/null'
    echo "Logging disabled"
else 
    SLOG_STD=$SLOG/ge-fan.log 
    SLOG_ERR=$SLOG/ge-fan-err.log
    echo "Logging to '$LOGDIR'" 
fi

mkdir -p log
nohup ./ge-fan 1> $SLOG_STD 2> $SLOG_ERR &
