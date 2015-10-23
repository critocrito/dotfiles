#!/bin/sh

help()
{
    echo "Usage: $0 [left|right|off]" 1>&2
    exit 1
}

case $@ in
    left) OP="--right-of LVDS1 --primary --auto";;
    right) OP="--left-of LVDS1 --primary --auto";;
    off) OP="--off";;
    *) help;;
esac

TARGET=$(xrandr | awk '{ if ($1 != "LVDS1" &&
                            ($2 == "connected" ||
                            ($2 == "disconnected" && $3 == "primary"))) print $1; }')
xrandr --output LVDS1 --auto --output $TARGET $OP
