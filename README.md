# ge-fan
Nvidia fan automation for linux.

Simple bash script for assigning custom fan curves to your Nvidia cards. You need the nvidia-settings application in order for this to work.

## Examples
Run in foreground, use Ctrl + C to stop
    ./ge-fan.sh
   
You can play with the curve in curve.txt, each line represents the fan percentage, the line number is degrees celsius, from 0.
