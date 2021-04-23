# Alacritty

1. alacrittyをビルドする
 どうやら`yay`で入れたやつでは微妙にできないことが合ったりするらしい。
1. 設定ファイルのリンク
 ```console
 $ ln -snf $PWD/config/alacritty $HOME/.config/
 $ ln -snf $HOME/.config/alacritty/alacritty.desktop $HOME/.config/autostart/
 ```
