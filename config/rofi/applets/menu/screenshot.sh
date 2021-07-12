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
        c="$(echo -e "3\n5\n10" | $rofi_command -dmenu -selected-row 0)"
        case $c in
            "3")
                timer=3
                ;;
            "5")
                timer=5
                ;;
            "10")
                timer=10
                ;;
        esac
        if [ -x "$(command -v giph)" ]; then
            command giph -f 5 -s -l -c 1,1,1,0.5 -p -5 -t $timer ~/Videos/out.gif
            # command gyazo-cli ~/Videos/out.gif | pbcopy
            msg "saved"
        else
            msg "giph is not installed."
        fi
        ;;
    $capture)
        if [ -x "$(command -v gyazo)" ]; then
            command gyazo
            msg "share url is copyed in clipboard"
        else
            msg "gyazo is not installed."
        fi
        ;;
esac
