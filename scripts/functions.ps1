function Create-ShortCut {
    param([string]$Source, [string[]]$Arguments, [string]$Destination, [int]$WindowStyle)
    $WScriptShell = New-Object -ComObject WScript.Shell
    $executableName = Split-Path $Source -Leaf
    $name = $executableName.SubString(0, $executableName.LastIndexOf("."))
    $dst = Join-Path -Path (Resolve-Path -Path $Destination) -ChildPath ($name + ".lnk")
    $Shortcut = $WScriptShell.CreateShortcut($dst)
    $Shortcut.Targetpath = $Source
    if ($Arguments.count -gt 0) {
        $Shortcut.Arguments = $Arguments -join " "
    }
    if ($WindowStyle -gt 0) {
        # 1: normal
        # 3: maximize
        # 7: minimize
        $Shortcut.WindowStyle = $WindowStyle
    }
    $Shortcut.Save()

    Write-Host "Generate shortcut as $dst"
}
