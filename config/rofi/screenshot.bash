#!/usr/bin/env bash

## Author  : Aditya Shakya
## Mail    : adi1090x@gmail.com
## Github  : @adi1090x
## Twitter : @adi1090x

# modified by Omochice

here=$(dirname $(readlink -f ${BASH_SOURCE[0]}))

rofi_command="rofi -theme $here/screen-shooter.rasi"

# Error msg
msg() {
    rofi -theme $here/message.rasi -e "$1"
}

# Options
cancel="↩"
movie="🎞"
capture=""
dcapture="D"

# Variable passed to rofi
options="$cancel\n$movie\n$capture\n$dcapture"

chosen="$(echo -e "$options" | $rofi_command -p "" -dmenu -selected-row 0)"
case $chosen in
    $cancel) ;;

    $movie)
        c="$(echo -e "3\n5\n10" | $rofi_command -p "" -dmenu -selected-row 0)"
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
            msg "saved at ~/Videos/out.gif"
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
    $dcapture)
        if [ -x "$(command -v gyazo)" ]; then
            # よくわからんけど`gyazo | sed ~ | xsel`すると無限ループっぽい動作をするのでファイルに書き出す
            command gyazo >/tmp/gyazo.log
            # 単に`cat | sed | xsel`だと改行がついてくるので色々挟んでる
            command echo $(cat /tmp/gyazo.log) | sed -r -e "s@(gyazo\.com)@i\.\1@" -e "s@\$@\.png@" -z -e "s@\n@@" | xsel --clipboard --input
            msg "share url is copyed in clipboard"
        else
            msg "gyazo is not installed."
        fi
        ;;
esac
