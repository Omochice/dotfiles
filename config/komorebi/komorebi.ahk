#SingleInstance Force

; Enable hot reloading of changes to this file
Run, komorebic.exe watch-configuration enable, , Hide

; Disable border
Run, komorebic.exe active-window-border disable, , Hide

; Enable focus follows mouse
Run, komorebic.exe focus-follows-mouse disable, , Hide

; Ensure there are 6 workspaces on each monitor
; NOTE: 80 = SM_CMONITORS
; FIXME: 初回評価時に固定されている
GetMonitorNr()
{
  SysGet, monitorNr, 80
  Loop, %monitorNr% {
      m = A_Index - 1
      Run, komorebic.exe ensure-workspaces %m% 6, , Hide
  }
  Return monitorNr
}

; NOTE: if process exists then return 1 else return 0

IsKomorebiRunning()
{
  Process, Exist, komorebi.exe
  pid = %ErrorLevel%
  Return pid > 0
}

; Set the layouts of different workspaces
Run, komorebic.exe workspace-layout 0 1 columns, , Hide

; Set the floaty layout to not tile any windows
Run, komorebic.exe workspace-tiling 0 4 disable, , Hide

; Always show chat apps on the second workspace
Run, komorebic.exe workspace-rule exe slack.exe 0 1, , Hide
Run, komorebic.exe workspace-rule exe Discord.exe 0 1, , Hide

; Floating rules
Run, komorebic.exe float-rule title "Control Panel", , Hide
Run, komorebic.exe float-rule exe "Teams.exe", , Hide
Run, komorebic.exe float-rule exe "Chrome.exe", , Hide
Run, komorebic.exe float-rule exe "Explorer.EXE", , Hide
Run, komorebic.exe float-rule class TaskManagerWindow, , Hide


;; KEY BINDS
; Move focus with Super + hjkl
#h::
{
  if IsKomorebiRunning() {
    Run, komorebic.exe focus left, , Hide
  } else {
    send, #h
  }
  return
}

#j::
{
  if IsKomorebiRunning() {
    Run, komorebic.exe focus down, , Hide
  } else {
    send, #j
  }
  return
}

#k::
{
  if IsKomorebiRunning() {
    Run, komorebic.exe focus up, , Hide
  } else {
    send, #k
  }
  return
}

#l::
{
  if IsKomorebiRunning() {
    Run, komorebic.exe focus right, , Hide
  } else {
    send, #l
  }
  return
}

; Move focused window with Super + Shift + hjkl
#+h::
{
  if IsKomorebiRunning() {
    Run, komorebic.exe move left, , Hide
  } else {
    send, #{Left}
  }
  return
}

#+j::
{
  if IsKomorebiRunning() {
    Run, komorebic.exe move down, , Hide
  } else {
    send, #{Down}
  }
  return
}

#+k::
{
  if IsKomorebiRunning() {
    Run, komorebic.exe move up, , Hide
  } else {
    send, #{Up}
  }
  return
}

#+l::
{
  if IsKomorebiRunning() {
    Run, komorebic.exe move right, , Hide
  } else {
    send, #{Right}
  }
  return
}

#f::
{
  if IsKomorebiRunning() {
    Run, komorebic.exe toggle-maximize, , Hide
  } else {
    ; TODO: toggle
    WinMaximize, A
  }
  return
}

#s::
Run, komorebic.exe flip-layout horizontal, , Hide
return

#v::
Run, komorebic.exe flip-layout vertical, , Hide
return

; Toggle focused window floatly, super + space
#Space::
Run, komorebic.exe toggle-float, , Hide
return

; DO NOT OPEN ONENOTE
#+n::
return

; Reload ~/komorebi.ahk, super + c
; NOTE: Maybe this not re-order virtual desktop?
#+c::
Run, komorebic.exe reload-configuration, , Hide
return

#n::
Run, komorebic.exe cycle-focus next, , Hide
return

; Switch to workspace
#1::
{
  if !IsKomorebiRunning() {
    send, #1
    return
  }
  n_monitor := GetMonitorNr()
  if (n_monitor = 1) {
      Run, komorebic.exe focus-workspace 0, , Hide
  } else if (n_monitor = 2) {
      Run, komorebic.exe focus-monitor-workspace 1 0, , Hide
  } else if (n_monitor = 3) {
      Run, komorebic.exe focus-monitor-workspace 2 0, , Hide
  }
  Run, komorebic.exe cycle-focus next, , Hide
  return
}

#2::
{
  if !IsKomorebiRunning() {
    send, #2
    return
  }
  n_monitor := GetMonitorNr()
  if (n_monitor = 1) {
      Run, komorebic.exe focus-workspace 1, , Hide
  } else if (n_monitor = 2) {
      Run, komorebic.exe focus-monitor-workspace 1 1, , Hide
  } else if (n_monitor = 3) {
      Run, komorebic.exe focus-monitor-workspace 2 1, , Hide
  }
  Run, komorebic.exe cycle-focus next, , Hide
  return
}

#3::
{
  if !IsKomorebiRunning() {
    send, #3
    return
  }
  n_monitor := GetMonitorNr()
  if (n_monitor = 1) {
      Run, komorebic.exe focus-workspace 2, , Hide
  } else if (n_monitor = 2) {
      Run, komorebic.exe focus-monitor-workspace 1 2, , Hide
  } else if (n_monitor = 3) {
      Run, komorebic.exe focus-monitor-workspace 1 0, , Hide
  }
  Run, komorebic.exe cycle-focus next, , Hide
  return
}

#4::
{
  if !IsKomorebiRunning() {
    send, #4
    return
  }
  n_monitor := GetMonitorNr()
  if (n_monitor = 1) {
      Run, komorebic.exe focus-workspace 3, , Hide
  } else if (n_monitor = 2) {
      Run, komorebic.exe focus-monitor-workspace 0 0, , Hide
  } else if (n_monitor = 3) {
      Run, komorebic.exe focus-monitor-workspace 1 1, , Hide
  }
  Run, komorebic.exe cycle-focus next, , Hide
  return
}

#5::
{
  if !IsKomorebiRunning() {
    send, #5
    return
  }
  n_monitor := GetMonitorNr()
  if (n_monitor = 1) {
      Run, komorebic.exe focus-workspace 4, , Hide
  } else if (n_monitor = 2) {
      Run, komorebic.exe focus-monitor-workspace 0 1, , Hide
  } else if (n_monitor = 3) {
      Run, komorebic.exe focus-monitor-workspace 0 0, , Hide
  }
  Run, komorebic.exe cycle-focus next, , Hide
  return
}

#6::
{
  if !IsKomorebiRunning() {
    send, #6
    return
  }
  n_monitor := GetMonitorNr()
  if (n_monitor = 1) {
      Run, komorebic.exe focus-workspace 5, , Hide
  } else if (n_monitor = 2) {
      Run, komorebic.exe focus-monitor-workspace 0 2, , Hide
  } else if (n_monitor = 3) {
      Run, komorebic.exe focus-monitor-workspace 0 1, , Hide
  }
  Run, komorebic.exe cycle-focus next, , Hide
  return
}

; Move window to workspace
#+1::
{
  if !IsKomorebiRunning() {
    send, #+1
    return
  }
  n_monitor := GetMonitorNr()
  if (n_monitor = 1) {
      Run, komorebic.exe move-to-workspace 0, , Hide
  } else if (n_monitor = 2) {
      Run, komorebic.exe send-to-monitor-workspace 1 0, , Hide
      Run, komorebic.exe focus-monitor-workspace 1 0, , Hide
  } else if (n_monitor = 3) {
      Run, komorebic.exe send-to-monitor-workspace 2 0, , Hide
      Run, komorebic.exe focus-monitor-workspace 2 0, , Hide
  }
  return
}

#+2::
{
  if !IsKomorebiRunning() {
    send, #+2
    return
  }
  n_monitor := GetMonitorNr()
  if (n_monitor = 1) {
      Run, komorebic.exe move-to-workspace 1, , Hide
  } else if (n_monitor = 2) {
      Run, komorebic.exe send-to-monitor-workspace 1 1, , Hide
      Run, komorebic.exe focus-monitor-workspace 1 1, , Hide
  } else if (n_monitor = 3) {
      Run, komorebic.exe send-to-monitor-workspace 2 1, , Hide
      Run, komorebic.exe focus-monitor-workspace 2 1, , Hide
  }
  return
}

#+3::
{
  if !IsKomorebiRunning() {
    send, #+3
    return
  }
  n_monitor := GetMonitorNr()
  if (n_monitor = 1) {
      Run, komorebic.exe move-to-workspace 2, , Hide
  } else if (n_monitor = 2) {
      Run, komorebic.exe send-to-monitor-workspace 1 2, , Hide
      Run, komorebic.exe focus-monitor-workspace 1 2, , Hide
  } else if (n_monitor = 3) {
      Run, komorebic.exe send-to-monitor-workspace 1 0, , Hide
      Run, komorebic.exe focus-monitor-workspace 1 0, , Hide
  }
  return
}

#+4::
{
  if !IsKomorebiRunning() {
    send, #+4
    return
  }
  n_monitor := GetMonitorNr()
  if (n_monitor = 1) {
      Run, komorebic.exe move-to-workspace 3, , Hide
  } else if (n_monitor = 2) {
      Run, komorebic.exe send-to-monitor-workspace 0 0, , Hide
      Run, komorebic.exe focus-monitor-workspace 0 0, , Hide
  } else if (n_monitor = 3) {
      Run, komorebic.exe send-to-monitor-workspace 1 1, , Hide
      Run, komorebic.exe focus-monitor-workspace 1 1, , Hide
  }
  return
}

#+5::
{
  if !IsKomorebiRunning() {
    send, #+5
    return
  }
  n_monitor := GetMonitorNr()
  if (n_monitor = 1) {
      Run, komorebic.exe move-to-workspace 4, , Hide
  } else if (n_monitor = 2) {
      Run, komorebic.exe send-to-monitor-workspace 0 1, , Hide
      Run, komorebic.exe focus-monitor-workspace 0 1, , Hide
  } else if (n_monitor = 3) {
      Run, komorebic.exe send-to-monitor-workspace 0 0, , Hide
      Run, komorebic.exe focus-monitor-workspace 0 0, , Hide
  }
  return
}

#+6::
{
  if !IsKomorebiRunning() {
    send, #+6
    return
  }
  n_monitor := GetMonitorNr()
  if (n_monitor = 1) {
      Run, komorebic.exe move-to-workspace 5, , Hide
  } else if (n_monitor = 2) {
      Run, komorebic.exe send-to-monitor-workspace 0 2, , Hide
      Run, komorebic.exe focus-monitor-workspace 0 2, , Hide
  } else if (n_monitor = 3) {
      Run, komorebic.exe send-to-monitor-workspace 0 1, , Hide
      Run, komorebic.exe focus-monitor-workspace 0 1, , Hide
  }
  return
}
