#!/bin/sh

keyboard_app="wvkbd-mobintl"
launch_args="-L 240px"

process_id=$(pgrep "$keyboard_app")

if [ -n "$process_id" ]; then
    kill "$process_id"
    exit 0
fi

$keyboard_app $launch_args &
