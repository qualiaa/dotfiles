[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx

: '
if [ -n $DISPLAY ]; then
    if command -v xrandr; then
        if [ -n $(xrandr | grep "HDMI-1 connected") ]; then
            xrandr --output HDMI-1 --mode 1920x1200 --left-of eDP-1
            feh --bg-fil --randomize "$HOME/.wallpapers"
        fi
    fi
fi
'
[ -f ~/.exports ] && source ~/.exports
