#!/bin/bash

pactl set-default-source $(pactl list sources short | grep "input" | grep "Logitech" | cut -d $'\t' -f 1)
pactl set-default-sink $(pactl list sinks short | grep "output" | grep "alsa_output.pci-0000_05" | cut -d $'\t' -f 1)

