#!/usr/bin/env bash

## Author  : Aditya Shakya
## Mail    : adi1090x@gmail.com
## Github  : @adi1090x
## Twitter : @adi1090x

style="$($HOME/.config/rofi/applets/menu/style.sh)"

dir="$HOME/.config/rofi/applets/menu/configs/$style"
rofi_command="rofi -theme $dir/screenshot.rasi"

# Error msg
msg() {
    rofi -theme "$HOME/.config/rofi/applets/styles/message.rasi" -e "$1"
}

# Options
cancel="↩"
movie="🎞"
capture=""

# Variable passed to rofi
options="$cancel\n$movie\n$capture"

chosen="$(echo -e "$options" | $rofi_command -p "Say, 'Cheese' !" -dmenu -selected-row 0)"
case $chosen in
    $cancel) ;;

    $movie)
        if [ -x "$(command -v simplescreenrecorder)" ]; then
            command simplescreenrecorder
        else
            msg "simplescreenrecorder is not installed."
        fi
        ;;
    $capture)
        if [ -x "$(command -v gyazo)" ]; then
            gyazo
        else
            msg "gyazo is not installed."
        fi
        ;;
esac
