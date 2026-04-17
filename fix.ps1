$DesktopPath = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop")
$OniaDest = Join-Path $DesktopPath "ONIA"
$VSCodePath = "$env:ProgramFiles\Microsoft VS Code\Code.exe"

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut((Join-Path $OniaDest "Open_in_VSCode.lnk"))
$Shortcut.TargetPath = $VSCodePath
$Shortcut.Arguments = "`"$OniaDest`""
$Shortcut.WorkingDirectory = $OniaDest
$Shortcut.Description = "Open ONIA folder in VS Code"
$Shortcut.Save()
Write-Host "VS Code shortcut created in ONIA folder." -ForegroundColor Green
