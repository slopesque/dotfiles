#/bin/sh

FOCUS_MODE_FILE=/tmp/.focus-mode-state
FOCUS_MODE_ALLOWED_APPS=~/.config/hypr/utils/focus-mode-apps.txt

focus_mode_on=0
rofi_args=""

notify_error() {
    notify-send -u critical $1
}

get_locker_state() {
    if [ '!' -f "$FOCUS_MODE_FILE" ]; then
        notify_error "Focus mode apps database not found."
        return
    fi

    focus_mode_state="$(cat $FOCUS_MODE_FILE)"

    if [ -z "$focus_mode_state" ]; then
        notify_error "No app found. Please set some."
    fi

    if [ "$focus_mode_state" -eq 1 ]; then
        focus_mode_on=1
    fi
}

get_locker_state

if [ "$focus_mode_on" -eq 1 ]; then
    cat "$FOCUS_MODE_ALLOWED_APPS" \
        | rofi -dmenu -p "Focus Mode Active" \
        | xargs hyprctl dispatch exec
else
    rofi -show drun -terminal kitty
fi
