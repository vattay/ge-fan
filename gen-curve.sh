#!/bin/bash

for i in `seq 0 100`;
  do    
    fan=$(python -c "print(int(13.0/750.0 * $i**2 + (11.0/150.0) * $i - (84.0/5.0)))")
    if [ "$fan" -gt 100 ]
    then
      fan=100
    fi
    if [ "$fan" -lt 1 ]
    then
      fan=1
    fi
    echo "$fan"
  done

