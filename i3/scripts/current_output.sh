#!/bin/bash

if [ "1" = "$(pactl info | grep Sink | grep Logitech | wc -l)" ]; then 
    echo "Headphones"
else
    echo " Speakers "
fi

# print red on mute
if [ "$(pactl get-sink-mute @DEFAULT_SINK@)" = "Mute: yes" ]; then
	echo ""
	echo '#FF0000'
	# echo '#BF616A'
else
	echo ""
	# echo '#00FF00'
fi
