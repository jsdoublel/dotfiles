#!/bin/bash

if [ "$(pactl get-sink-mute @DEFAULT_SINK@)" = "Mute: yes" ]; then
	mute="(M)"
else
	mute="(*)"
fi

if [ "1" = "$(pactl info | grep Sink | grep Logitech | wc -l)" ]; then 
    echo " $mute: Headphones"
else
    echo " $mute: Speakers  "
fi

