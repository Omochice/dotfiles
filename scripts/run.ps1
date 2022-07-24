## change to administer mode
# NOTE: powershell dont allow make symlink as normal user
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs; exit
}

$DotDir = ([System.IO.FileInfo]$PSScriptRoot).Directory.FullName
$UserProfile = $env:USERPROFILE

# setting by registry {{{
## show extention
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d "0" /f

## Disable sound by notification
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notitications\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_NOTIFICATION_SOUND" /t REG_DWORD /d "0" /f

## Disable hints
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d "0" /f

# }}}

## install winget via github-release {{{
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
winget install "App Installer" -s msstore

## }}}

## install font {{{
$tempDir = Join-Path -Path $env:SystemRoot -ChildPath "Windows" | Join-Path -ChildPath "Temp" | Join-Path -ChildPath "Fonts"
New-Item $tempDir -Type Directory -Force
$fontReleaseInfo = Invoke-RestMethod -uri "https://api.github.com/repos/yuru7/Firge/releases/latest"
$fontReleaseInfo.assets | ForEach {
    $outFile = (Join-Path -Path $UserProfile -ChildPath "downloads" | Join-Path -ChildPath $_.name)
    Invoke-WebRequest -Uri $_.browser_download_url -OutFile $outFile
    Expand-Archive -LiteralPath $outFile -Destination $tempDir
}

$destination = (New-Object -ComObject Shell.Application).Namespace(0x14)
Get-ChildItem -Path $tempDir -Include "*.ttf" -Recurse | ForEach {
    if (-not(Test-Path (Join-Path $UserProfile -ChildPath "AppData" |
                                     Join-Path -ChildPath "Local" |
                                     Join-Path -ChildPath "Microsoft" |
                                     Join-Path -ChildPath "Windows" |
                                     Join-Path -ChildPath "Fonts" |
                                     Join-Path -ChildPath $_.Name
                                     ))) {
        $destination.CopyHere($_.FullName, 0x10)
    }
}
Remove-Item $tempDir -Recurse
## }}}

## wezterm
if ($null -eq (Get-Command "wezterm.exe" -ErrorAction SilentlyContinue)) {
    winget install Wez.WezTerm
}
Get-ChildItem -Path (Join-Path -Path $DotDir -ChildPath config/wezterm) | ForEach-Object {
    New-Item -ItemType SymbolicLink -Path (Join-Path -Path $env:ProgramW6432 -ChildPath $_.Name) -Target $_.FullName -Force
}

## Browsers {{{

## Vivaldi
if ($null -eq (Get-Command (Join-Path -Path $UserProfile -ChildPath "AppData/Local/Vivaldi/application/vivaldi.exe") -ErrorAction SilentlyContinue)) {
    winget install VivaldiTechnologies.Vivaldi
}

## Chrome
if ($null -eq (Get-Command (Join-Path -Path $env:ProgramW6432 -ChildPath "Google/Chrome/application/chrome.exe") -ErrorAction SilentlyContinue)) {
    winget install VivaldiTechnologies.Vivaldi
}

## Firefox
if ($null -eq (Get-Command (Join-Path -Path $env:ProgramW6432 -ChildPath "Mozilla Firefox/firefox.exe") -ErrorAction SilentlyContinue)) {
    winget install VivaldiTechnologies.Vivaldi
}
## }}}

## vscode
if ($null -eq (Get-Command "code")) {
    winget install Microsoft.VisutalStudioCode
}

## powertoys
if ($null -eq (Get-Command (Join-Path -Path $env:ProgramW6432 -ChildPath "Google/Chrome/application/chrome.exe") -ErrorAction SilentlyContinue)) {
    winget install Google.Chrome
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
