#!/bin/bash

trap ctrl_c INT

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

IFS=$'\r\n' GLOBIGNORE='*' command eval  'CURVE=($(cat $DIR/curve.txt))'

ctrl_c(){
  echo "Finishing up."
  finish
  exit 1
}

constrain(){
  local result=$1
  if [ "$1" -gt 100 ]
  then
    result=100
  elif [ "$1" -lt 0 ]
  then
    result="0"
  fi
  echo "$result"
}

init(){
  for i in `seq 0 1`;
  do
    nvidia-settings -a "[gpu:$i]/GPUFanControlState=1" -t > /dev/null
  done
}

finish(){
  for i in `seq 0 1`;
  do
    nvidia-settings -a "[fan:$i]/GPUTargetFanSpeed=0" -t > /dev/null
    nvidia-settings -a "[gpu:$i]/GPUFanControlState=0" -t > /dev/null
  done
}

adjust_fan(){
  gpu_id=$1
  temp=$2

  current_fan=$(nvidia-settings -q "[fan:1]/GPUCurrentFanSpeed" -t)
  #echo "GPU:$gpu_id current fan = $current_fan"

  #new_fan=$(python -c "print(int(13.0/750.0 * $temp**2 + 11.0/150.0 - 16.80))")
  #new_fan=$(python -c "print(int(13.0/750.0 * $temp**2 + (11.0/150.0) * $temp - (84.0/5.0)))")
  #new_fan=$(python -c "print(int(-0.0323 * $temp**2 + 5.537 * $temp -136.0))")
  new_fan="$((${CURVE[$temp]}))"
  echo "GPU:$gpu_id pre-fan $new_fan"
  new_fan=$(constrain $new_fan)
  if [ "$new_fan" -ne "$current_fan" ]
  then
    echo "GPU:$gpu_id temp = $temp new fan = $new_fan"
    nvidia-settings -a "[fan:$gpu_id]/GPUTargetFanSpeed=$new_fan" > /dev/null
  fi
}

sample(){
for i in `seq 0 1`;
do
  temp=$(nvidia-settings -q "[gpu:$i]/GPUCoreTemp" -t)
  #echo "GPU:$i temp = $temp" 
  #t_delta="$(($temp-$TARGET_TEMP))"
  adjust_fan $i $temp
done
}

init;
echo "Press [Ctrl+C] to stop."
while true
do 
  sample;
  sleep 3
done


