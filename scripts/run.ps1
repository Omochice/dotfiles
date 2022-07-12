## change to administer mode
# NOTE: powershell dont allow make symlink as normal user
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs; exit
}

$DotDir = ([System.IO.FileInfo]$PSScriptRoot).Directory.FullName
$UserProfile = $env:USERPROFILE

# show extention
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d "0" /f

## wezterm
if ($null -eq (Get-Command "wezterm.exe" -ErrorAction SilentlyContinue)) {
    winget install Wez.WezTerm
}
Get-ChildItem -Path (Join-Path -Path $DotDir -ChildPath config/wezterm) | ForEach-Object {
    New-Item -ItemType SymbolicLink -Path (Join-Path -Path $env:ProgramW6432 -ChildPath $_.Name) -Target $_.FullName -Force
}

## powertoys
if ($null -eq (Get-Command (Join-Path -Path $env:ProgramW6432 -ChildPath "PowerToys/PowerToys.exe") -ErrorAction SilentlyContinue)) {
    winget install Microsoft.PowerToys
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