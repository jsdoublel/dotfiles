#!/bin/bash
current="$(pactl info | grep Sink: | cut -d " " -f 3)"
if [ "1" = "$(pactl info | grep Sink: | grep Logitech | wc -l)" ]; then 
    echo "$(pactl list sinks short | grep "alsa_output.pci-0000_05" | cut -d $'\t' -f 1)"
    pactl set-default-sink "$(pactl list sinks short | grep "alsa_output.pci-0000_05" | cut -d $'\t' -f 1)"
    echo "Switched to speakers"
else
    echo "$(pactl list sinks short | grep "Logitech" | cut -d $'\t' -f 1)"
    pactl set-default-sink "$(pactl list sinks short | grep "Logitech" | cut -d $'\t' -f 1)"
    echo "Switched to headphones"
fi

