. (Join-Path -Path $PSScriptRoot -ChildPath "functions.ps1")

## change to administer mode
# NOTE: powershell dont allow make symlink as normal user
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs; exit
}

$DotDir = ([System.IO.FileInfo]$PSScriptRoot).Directory.FullName
$UserProfile = $env:USERPROFILE
$MyAppDir = (Join-Path -Path $HOME -ChildPath "apps")

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

Write-Host -ForegoundColor Cyan "---install winget via github-release---"
# {{{
$hasPackageManager = Get-AppPackage -name "Microsoft.DesktopAppInstaller"

if(!$hasPackageManager)
{
    $releases_url = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $releases = Invoke-RestMethod -uri "$($releases_url)"
    $latestRelease = $releases.assets | Where { $_.browser_download_url.EndsWith("msixbundle") } | Select -First 1

    Add-AppxPackage -Path $latestRelease.browser_download_url
}

### replace winget by from msstore
winget install --accept-package-agreements "App Installer" --source msstore

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

$destination = (New-Object -ComObject Shell.Application).Namespace(0x14)
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
    winget install --accept-package-agreements --exact --id Wez.WezTerm
}
Get-ChildItem -Path (Join-Path -Path $DotDir -ChildPath "config/wezterm") | ForEach-Object {
    New-Item -ItemType SymbolicLink -Path (Join-Path -Path $env:ProgramW6432 -ChildPath "WezTerm" | Join-Path -ChildPath $_.Name) -Target $_.FullName -Force
}

Write-Host "install browsers"

# {{{
## Vivaldi
if ($null -eq (Get-Command (Join-Path -Path $UserProfile -ChildPath "AppData/Local/Vivaldi/application/vivaldi.exe") -ErrorAction SilentlyContinue)) {
    winget install --accept-package-agreements --exact --id VivaldiTechnologies.Vivaldi
}

## Chrome
if ($null -eq (Get-Command (Join-Path -Path $env:ProgramW6432 -ChildPath "Google/Chrome/application/chrome.exe") -ErrorAction SilentlyContinue)) {
    winget install --accept-package-agreements --exact --id Google.Chrome
}

## Firefox
if ($null -eq (Get-Command (Join-Path -Path $env:ProgramW6432 -ChildPath "Mozilla Firefox/firefox.exe") -ErrorAction SilentlyContinue)) {
    winget install --accept-package-agreements --exact --id Mozilla.Firefox
}
## }}}

## vscode
if ($null -eq (Get-Command "code" -ErrorAction SilentlyContinue)) {
    winget install --accept-package-agreements --exact --id Microsoft.VisutalStudioCode
}

## powertoys
if ($null -eq (Get-Command (Join-Path -Path $env:ProgramW6432 -ChildPath "PowerToys" | Join-Path -ChildPath "PowerToys.exe") -ErrorAction SilentlyContinue)) {
    winget install --accept-package-agreements --exact --id Microsoft.PowerToys
}
Get-ChildItem -Path (Join-Path -Path $DotDir -ChildPath "win-config/PowerToys") -Recurse -File | ForEach-Object {
    New-Item `
        -ItemType SymbolicLink `
        -Path (`
            Join-Path -Path $UserProfile -ChildPath (`
                Join-Path -path "AppData/Local/Microsoft/PowerToys" -ChildPath (`
                    Join-Path -Path $_.Directory.Name -ChildPath $_.Name `
                )`
            )`
        )`
        -Target $_.FullName `
        -Force
}

## nushell
if ($null -eq (Get-Command "nu" -ErrorAction SilentlyContinue)) {
    winget install --accept-package-agreements --exact --id Nushell.Nushell
}

## Google IME
winget install --accept-package-agreements --exact --id Google.JapaneseIME

## komorebi
# {{{
winget install --accept-package-agreements --exact --id LGUG2Z.komorebi
# NOTE: komorebi add Path automatically

# registor as auto-start
Create-ShortCut -Source (Get-Command komorebic).Definition `
                -Arguments "start --await-configuration" `
                -Destination (Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders').StartUp `
                -WindowStyle 7
# }}}

# glazewm {{{
winget install --accept-package-agreements --exact --id lars-berger.GlazeWM
## NOTE: alias only work when installed by administer
## SEE: https://github.com/microsoft/winget-cli/issues/3437
Create-ShortCut -Source (Get-Command glazewm).Definition `
                -Arguments ("--config=" + (Join-Path $DotDir "config\glazewm\config.yaml")) `
                -Destination (Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders').StartUp `
                -WindowStyle 7
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
[Environment]::SetEnvironmentVariable("KOMOREBI_CONFIG_HOME", (Join-Path -Path $DotDir -ChildPath "config/komorebi"), [EnvironmentVariableTarget]::Machine)
# }}}

# stop while user input
Read-Host "DONE!!"
