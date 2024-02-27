#!/bin/bash

if [ "2" = "$(pactl info | grep Logitech | wc -l)" ]; then 
    echo ": Headphones"
else
    echo ": Speakers  "
fi

