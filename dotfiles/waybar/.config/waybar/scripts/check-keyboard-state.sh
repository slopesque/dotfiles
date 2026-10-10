#!/bin/sh

keyboard_app="wvkbd-mobintl"
display_color="inactive"

process_id=$(pgrep "$keyboard_app")

if [ -n "$process_id" ]; then
    display_color="active"
fi

printf '{ "class": "%s" }' \
    "$display_color"
