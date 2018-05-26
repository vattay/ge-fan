#!/bin/bash

mkdir log
nohup ./ge-fan 1 >> log/ge-fan.log 2> /dev/null &
