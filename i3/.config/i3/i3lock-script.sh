#!/bin/bash
ICON=~/.config/i3/icon.png
TMPBG=/tmp/screenshot-for-lock.png
import -window root $TMPBG
convert $TMPBG -scale 10% -scale 1000% $TMPBG
convert $TMPBG $ICON -gravity center -composite -matte $TMPBG
i3lock -u -i $TMPBG
rm $TMPBG

