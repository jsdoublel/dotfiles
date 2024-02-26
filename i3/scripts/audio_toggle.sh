#!/bin/bash
current="$(pactl info | grep Sink: | cut -d " " -f 3)"
if [ "$current" = "alsa_output.pci-0000_05_00.0.5.analog-stereo" ]; then 
    pactl set-default-sink 42163
else
    pactl set-default-sink 42161 
fi

