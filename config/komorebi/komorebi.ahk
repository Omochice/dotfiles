#SingleInstance Force

; Enable hot reloading of changes to this file
Run, komorebic.exe watch-configuration enable, , Hide

; Disable border
Run, komorebic.exe active-window-border disable, , Hide

; Enable focus follows mouse
Run, komorebic.exe focus-follows-mouse disable, , Hide

; Ensure there are 5 workspaces on each monitor
; NOTE: 80 = SM_CMONITORS
SysGet, N_MONITOR, 80
Loop, %N_MONITOR% {
    m = A_Index - 1
    Run, komorebic.exe ensure-workspaces %m% 5, , Hide
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
Run, komorebic.exe float-rule title "Microsoft Teams", , Hide
Run, komorebic.exe float-rule title "DevTools", , Hide
Run, komorebic.exe float-rule class TaskManagerWindow, , Hide


;; KEY BINDS
; Move focus with Super + hjkl
#h::
Run, komorebic.exe focus left, , Hide
return

#j::
Run, komorebic.exe focus down, , Hide
return

#k::
Run, komorebic.exe focus up, , Hide
return

#l::
Run, komorebic.exe focus right, , Hide
return

; Move focused window with Super + Shift + hjkl
#+h::
Run, komorebic.exe move left, , Hide
return

#+j::
Run, komorebic.exe move down, , Hide
return

#+k::
Run, komorebic.exe move up, , Hide
return

#+l::
Run, komorebic.exe move right, , Hide
return

#f::
Run, komorebic.exe toggle-maximize, , Hide
return

#s::
Run, komorebic.exe flip-layout horizontal, , Hide
return

#v::
Run, komorebic.exe flip-layout vertical, , Hide
return

; Float the focused window, Alt + T
#Space::
Run, komorebic.exe toggle-float, , Hide
return

; Reload ~/komorebi.ahk, Alt + O
#+c::
Run, komorebic.exe reload-configuration, , Hide
return

; Switch to workspace
#1::
Run, komorebic.exe focus-workspace 0, , Hide
return

#2::
Run, komorebic.exe focus-workspace 1, , Hide
return

#3::
Run, komorebic.exe focus-workspace 2, , Hide
return

#4::
Run, komorebic.exe focus-workspace 3, , Hide
return

#5::
Run, komorebic.exe focus-workspace 4, , Hide
return

; Move window to workspace
#+1::
Run, komorebic.exe move-to-workspace 0, , Hide
return

#+2::
Run, komorebic.exe move-to-workspace 1, , Hide
return

#+3::
Run, komorebic.exe move-to-workspace 2, , Hide
return

#+4::
Run, komorebic.exe move-to-workspace 3, , Hide
return

#+5::
Run, komorebic.exe move-to-workspace 4, , Hide
return
