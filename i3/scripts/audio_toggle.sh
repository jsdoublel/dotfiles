#!/bin/bash
current="$(pactl info | grep Sink: | cut -d " " -f 3)"
if [ "$current" = "alsa_output.pci-0000_05_00.0.5.analog-stereo" ]; then 
    pactl set-default-sink "$(pactl list sinks short | grep "Logitech" | cut -d $'\t' -f 1)"
    echo "Switched to headphones"
else
    pactl set-default-sink "$(pactl list sinks short | grep "alsa_output.pci-0000_05_00.0.5.analog-stereo" | cut -d $'\t' -f 1)"
    echo "Switched to speakers"
fi

