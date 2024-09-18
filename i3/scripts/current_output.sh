#!/bin/bash

if [ "1" = "$(pactl info | grep Sink | grep Logitech | wc -l)" ]; then 
    echo ": Headphones"
else
    echo ": Speakers  "
fi

# print red on mute
if [ "$(pactl get-sink-mute @DEFAULT_SINK@)" = "Mute: yes" ]; then
	echo ""
	echo '#BF616A'
fi
