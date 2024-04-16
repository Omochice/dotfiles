. (Join-Path -Path $PSScriptRoot -ChildPath "functions.ps1")

## change to administer mode
# NOTE: powershell dont allow make symlink as normal user
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs; exit
}

$DotDir = ([System.IO.FileInfo]$PSScriptRoot).Directory.FullName
$UserProfile = $env:USERPROFILE
$MyAppDir = (Join-Path -Path $HOME -ChildPath "apps")
$Shell = New-Object -ComObject Shell.Application

New-Item $MyAppDir -Type Directory -Force

Write-Host -ForegoundColor Cyan "---setting by registry---"
# {{{
## show extention
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d "0" /f

## Disable sound by notification
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notitications\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_NOTIFICATION_SOUND" /t REG_DWORD /d "0" /f

## Disable hints
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d "0" /f
# NOTE: Software and SOFTWARE is same ?
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d "0" /f
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338388Enabled" /t REG_DWORD /d "0" /f
# disable hint at lock
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338387Enabled" /t REG_DWORD /d "0" /f
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d "0" /f
# NOTE: WHAT THE NUMBERS????

## Disable notification when switch ime mode
reg add "HKCU\Software\Microsoft\IME\15.0\IMEJP\MSIME" /v "ShowImeModeNotification" /t REG_DWORD /d "0" /f
# NOTE: HKCU is HKEY_CURRENT_USER ?

## Hide searchbox by taskbar
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "0" /f

## Hide taskview by taskbar
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowTaskViewButton" /t REG_DWORD /d "0" /f

## Disable cortana
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AlloaCortana" /t REG_DWORD /d "0" /f
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCortanaButton" /t REG_DWORD /d "0" /f

## Disable feeds
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v "EnableFeeds" /t REG_DWORD /d "0" /f


reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsDisableLastAccessUpdate" /t REG_DWORD "1" /f

## Remap keylayout
## caps(003A) to left-ctrl(001D)
## hiragana/katakana(0070) to left-win(E05B)
## muhenkan(007B) to esc(0001)
$maps = $(
            "0000000000000000"
            "05000000" # num of remap + 1
            "1d003a00" # caps to ctrl
            "5be07000" # kana to win
            "01007b00" # muhenkan to esc
            "00000000" # terminater
        )
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout" /v "Scancode Map" /t REG_BINARY /d ($maps -join "") /f

# disable whether news
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Feeds" /v "ShellFeedsTaskViewMode" /t REG_DWORD /d "2" /f

# DONT EXECUTE UNEXPECTED SHOTCUTS
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DisabledHotkeys" /t REG_SZ /d "ABCEFHIJKNOPQRSTUVXZ,.;+-:" /f

# DISABLE BING
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "DisableSearchBoxSuggestions" /t REG_DWORD /d "1" /f
reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d "0" /f

# DISABLE SUPER + L TO USE LOCK
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\system" /v "DisableLockWorkstation" /t REG_DWORD /d "1" /f
# }}}

Write-Host "---Link powershell shetting---" -ForegoundColor Cyan
New-Item -ItemType SymbolicLink -Path (Join-Path -Path $PSHOME -ChildPath "Profile.ps1") -Target (Join-Path -Path $DotDir -ChildPath "config" | Join-Path -ChildPath "powershell" | Join-Path -ChildPath "profile.ps1") -Force

Write-Host -ForegoundColor Cyan "---install scoop---"
## install scoop {{{
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
scoop bucket add extras
## }}}

Write-Host -ForegoundColor Cyan "---install font---"
# {{{
$tempDir = Join-Path -Path $env:SystemRoot -ChildPath "Windows" | Join-Path -ChildPath "Temp" | Join-Path -ChildPath "Fonts"
New-Item $tempDir -Type Directory -Force
$fontReleaseInfo = Invoke-RestMethod -uri "https://api.github.com/repos/yuru7/Firge/releases/latest"
$fontReleaseInfo.assets | ForEach {
    $outFile = (Join-Path -Path $UserProfile -ChildPath "downloads" | Join-Path -ChildPath $_.name)
    Invoke-WebRequest -Uri $_.browser_download_url -OutFile $outFile
    Expand-Archive -LiteralPath $outFile -Destination $tempDir
    Remove-Item $outFile -Recurse
}

$destination = $Shell.Namespace(0x14)
Get-ChildItem -Path $tempDir -Include "*.ttf" -Recurse | ForEach {
    if (-not(Test-Path (Join-Path $UserProfile -ChildPath "AppData" |`
                                     Join-Path -ChildPath "Local" |`
                                     Join-Path -ChildPath "Microsoft" |`
                                     Join-Path -ChildPath "Windows" |`
                                     Join-Path -ChildPath "Fonts" |`
                                     Join-Path -ChildPath $_.Name `
                                     ))) {
        $destination.CopyHere($_.FullName, 0x10)
    }
}
Remove-Item $tempDir -Recurse
# }}}

Write-Host "install wezterm" -ForegoundColor Cyan
# wezterm
if ($null -eq (Get-Command "wezterm.exe" -ErrorAction SilentlyContinue)) {
    scoop install wezterm
}
Get-ChildItem -Path (Join-Path -Path $DotDir -ChildPath "config/wezterm") | ForEach-Object {
    New-Item -ItemType SymbolicLink -Path (Join-Path -Path (scoop prefix wezterm) -ChildPath (Join-Path -ChildPath $_.Name)) -Target $_.FullName -Force
}

Write-Host "install browsers"

# {{{
## Vivaldi
if ($null -eq (Get-Command (Join-Path -Path $UserProfile -ChildPath "AppData/Local/Vivaldi/application/vivaldi.exe") -ErrorAction SilentlyContinue)) {
    scoop install vivaldi
}

## Chrome
if ($null -eq (Get-Command (Join-Path -Path $env:ProgramW6432 -ChildPath "Google/Chrome/application/chrome.exe") -ErrorAction SilentlyContinue)) {
    scoop install googlechrome
}

## Firefox
if ($null -eq (Get-Command (Join-Path -Path $env:ProgramW6432 -ChildPath "Mozilla Firefox/firefox.exe") -ErrorAction SilentlyContinue)) {
    scoop install firefox
}
## }}}

## vscode
if ($null -eq (Get-Command "code" -ErrorAction SilentlyContinue)) {
    scoop install vscode
}

## flow-launcher
scoop install flow-launcher

## autohotkey
scoop install autohotkey


## nushell
if ($null -eq (Get-Command "nu" -ErrorAction SilentlyContinue)) {
    scoop install nushell
}

# glazewm {{{
scoop install glazewm
Create-ShortCut -Source (Join-Path -Path $DotDir -ChildPath "config/autohotkey/mod.ahk") `
                -Destination ($Shell.Namespace("shell:startup").Self.Path) `
                -WindowStyle 0
# }}}

# Envs {{{
$paths = @(
    (Join-Path -Path $Env:ProgramW6432 -ChildPath "AutoHotKey")
    )
$orginalPath = $Env:PATH
foreach ($p in $paths) {
    # if $p is include PATH already, remove it.
    $orginalPath = $orginalPath.Replace($p + ";", "")
    # add it
    $orginalPath = $orginalPath + $p + ";"
}
[Environment]::SetEnvironmentVariable("PATH", $orginalPath, [EnvironmentVariableTarget]::Machine)
# }}}

# stop while user input
Read-Host "DONE!!"
