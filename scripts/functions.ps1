function Create-ShortCut {
    param([string]$Source, [string[]]$Arguments, [string]$Destination)
    $WScriptShell = New-Object -ComObject WScript.Shell
    $executableName = Split-Path $Source -Leaf
    $name = $executableName.SubString(0, $executableName.LastIndexOf("."))
    $dst = Join-Path -Path (Resolve-Path -Path $Destination) -ChildPath ($name + ".lnk")
    $Shortcut = $WScriptShell.CreateShortcut($dst)
    $Shortcut.Targetpath = $Source
    if ($Arguments.count -gt 0){
        $Shortcut.Arguments = $Arguments
    }
    $Shortcut.Save()

    Write-Host "Generate shortcut as $dst"
}
