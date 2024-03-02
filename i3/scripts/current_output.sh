#!/bin/bash

if [ "1" = "$(pactl info | grep Sink | grep Logitech | wc -l)" ]; then 
    echo ": Headphones"
else
    echo ": Speakers  "
fi

