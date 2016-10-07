#!/bin/bash

trap ctrl_c INT
trap term TERM

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
  exit 0
}

term(){
  echo "Terminating."
  finish
  exit 0
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

  new_fan="$((${CURVE[$temp]}))"
  new_fan=$(constrain $new_fan)
  nvidia-settings -a "[fan:$gpu_id]/GPUTargetFanSpeed=$new_fan" > /dev/null
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


