sudo pacman-mirrors --fasttrack


sudo pacman -Syyu

sudo pacman -S fcitx-im fcitx-mozc

sudo pacman -S xdg-user-dirs-gtk
LANG=C xdg-user0dirs-gtk-update

sudo pacman -S yay
sudo yay -S visual-studio-code-bin

sudo yay -S vivaldi

sudo sed -i "s/XKBOPTIONS.*/XKBOPTIONS=\"ctrl:nocaps\"/" /etc/default/keyboard

