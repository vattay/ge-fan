#!/bin/bash

NDISP=''

if [ -z ${DISPLAY+x} ]; then
    NDISP=':0'
else 
    NDISP=$DISPLAY
fi

echo "Using DISPLAY $DISPLAY"


devices=$(nvidia-smi -L | awk '{print $2}' | sed 's/.$//' | tr '\n' ' ')

for i in $devices;
do
  echo $i
  nvidia-settings -c $NDISP -a "[gpu:$i]/GPUFanControlState=1" -t > /dev/null
  nvidia-settings -c $NDISP -a "[fan:$i]/GPUTargetFanSpeed=100" > /dev/null
done

