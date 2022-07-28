# from https://zenn.dev/t4t5u0/articles/windows-develop-setup
Import-Module PSReadLine

Set-PSReadLineOption -EditMode Emacs

Set-PSReadLineKeyHandler -Key "Tab" -Function MenuComplete
