#SingleInstance Force

Home := EnvGet("USERPROFILE")

Run(Format("glazewm.exe --config {1}/dotfiles/config/glazewm/config.yaml", Home), , "Hide")

;; KEY BINDS

; kana to toggle ime
vk1C::vkF3

; Rwin+Tab to WindowSwitcher
RWin & Tab::AltTab

;; Super + 1~9 {{{
#1:: {
  Send("^{F11}")
  return
}

#2:: {
  Send("^{F12}")
  return
}

#3:: {
  Send("^{F13}")
  return
}

#4:: {
  Send("^{F14}")
  return
}

#5:: {
  Send("^{F15}")
  return
}

#6:: {
  Send("^{F16}")
  return
}

#7:: {
  Send("^{F17}")
  return
}

#8:: {
  Send("^{F18}")
  return
}

#9:: {
  Send("^{F19}")
  return
}
; }}}
;; Super + Shift + 1~9 {{{
#+1:: {
  Send("+{F11}")
  return
}

#+2:: {
  Send("+{F12}")
  return
}

#+3:: {
  Send("+{F13}")
  return
}

#+4:: {
  Send("+{F14}")
  return
}

#+5:: {
  Send("+{F15}")
  return
}

#+6:: {
  Send("+{F16}")
  return
}

#+7:: {
  Send("+{F17}")
  return
}

#+8:: {
  Send("+{F18}")
  return
}

#+9:: {
  Send("+{F19}")
  return
}
; }}}

#h:: {
  Send("{F13}")
  return
}

#j:: {
  Send("{F14}")
  return
}

#k:: {
  Send("{F15}")
  return
}

#l:: {
  Send("{F16}")
  return
}

#+h:: {
  Send("+{F13}")
  return
}

#+j:: {
  Send("+{F14}")
  return
}

#+k:: {
  Send("+{F15}")
  return
}

#+l:: {
  Send("+{F16}")
  return
}

#q:: {
  Send("{F24}")
  return
}

#f:: {
  Send("{F20}")
  return
}
