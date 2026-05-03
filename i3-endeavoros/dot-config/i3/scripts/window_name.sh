#!/usr/bin/env bash
# James Willson
# 2025-10-03

MAX_LEN=40

trunc() {
	(( ${#1} >= MAX_LEN )) && echo "$(echo "$1" | head -c $MAX_LEN)..." || echo "$1"
}

# wid=$(xdotool getwindowfocus 2>/dev/null)
# [[ -z $wid || $wid == 0 ]] && exit 0

# name=$(xdotool getwindowname "$wid" 2>/dev/null | iconv -f UTF-8 -t ASCII -c)
# class=$(xdotool getwindowclassname "$wid" 2>/dev/null | iconv -f UTF-8 -t ASCII -c)
name=$(i3-msg -t get_tree | jq -r '.. | objects | select(.focused? == true) | .name' | iconv -f UTF-8 -t ASCII -c)
class=$(i3-msg -t get_tree | jq -r '.. | objects | select(.focused? == true) | .window_properties.class' | iconv -f UTF-8 -t ASCII -c)
[[ -z $name && -z $class ]] && exit 0

[[ -n $class && "${name^^}" == *"${class^^}" ]] && name=${name% -*}
if [[ -n $class && ${class^^} != "NULL" ]]; then
	printf '%s' "${class^^}"
	[[ "${name^^}" != "${class^^}" && -n $name ]] && printf ' [%s]' "$(trunc "$name")"
fi
printf '\n'
