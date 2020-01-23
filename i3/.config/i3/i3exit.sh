#!/bin/bash
############################################################
# 
############################################################

function lock {
    i3lock --ignore-empty-password --show-failed-attempts --image ~/Pictures/wallpapers/current-wallpaper.png
    #~/.config/i3/i3lock-script.sh;
}

case "$1" in
    lock)
        lock
        ;;
    logout)
        #i3-msg exit
        xfce4-session-logout --logout
        ;;
    suspend)
        systemctl suspend
        ;;
    reboot)
        systemctl reboot
        ;;
    poweroff)
        systemctl poweroff
        ;;
    *)
        echo "Usage: $0 {lock|logout|suspend|reboot|poweroff}"
        exit 2
esac

exit 0
