#!/bin/bash

mkdir -p log
nohup ./ge-fan 1> log/ge-fan.log 2> log/ge-fan-err.log &
