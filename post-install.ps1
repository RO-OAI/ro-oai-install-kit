# 1. Basic Docker Checks
if (Get-Command "docker.exe" -ErrorAction SilentlyContinue) {
    Write-Host "Native Docker detected." -ForegroundColor Green
} else {
    Write-Error "Docker not found. Please run install.ps1 first."
    exit 1
}

# 2. Generate a random 32-character alphanumeric token
$RandomToken = -join ([char[]]((48..57) + (65..90) + (97..122) | Get-Random -Count 32))

# 3. Setup Paths and Variables
$DesktopPath = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop")
$OniaSource = Join-Path $PSScriptRoot "ONIA"
$OniaDest = Join-Path $DesktopPath "ONIA"
$ConnectionFile = Join-Path $OniaDest "jupyter_connection.txt"
$ImageName = "ghcr.io/ro-oai/ro-oai-install-kit-image:sha-a758602"
$ContainerName = "jupyter_server"

# 4. Copy ONIA Folder to Desktop and create Jupyter Connection File
if (Test-Path $OniaSource) {
    Write-Host "Copying ONIA folder to Desktop..." -ForegroundColor Cyan
    if (-not (Test-Path $OniaDest)) {
        New-Item -ItemType Directory -Path $OniaDest -Force | Out-Null
    }
    Copy-Item -Path (Join-Path $OniaSource "*") -Destination $OniaDest -Recurse -Force
} else {
    Write-Warning "ONIA source folder not found at $OniaSource"
}

# 5. Pull and Run
Write-Host "Pulling image..." -ForegroundColor Cyan
docker pull $ImageName

# Remove old container if it exists
if (docker ps -a -q --filter "name=$ContainerName") {
    docker rm -f $ContainerName | Out-Null
}

Write-Host "Starting Jupyter with a random token and mapped volume..." -ForegroundColor Cyan
docker run -d --name $ContainerName --restart always -p 8888:8888 -v "${OniaDest}:/home/jovyan/work" -w /home/jovyan/work -e JUPYTER_TOKEN=$RandomToken $ImageName

# 6. Create Jupyter Connection File in the copied folder
if (Test-Path $OniaDest) {
    $JupyterUrl = "http://localhost:8888/?token=$RandomToken"
    $ConnectionContent = @"
==================================================
JUPYTER CONNECTION INFO
==================================================
URL:   http://localhost:8888
TOKEN: $RandomToken
Direct Link: $JupyterUrl
==================================================
"@
    $ConnectionContent | Out-File -FilePath $ConnectionFile -Encoding utf8
    Write-Host "Jupyter connection file created at $ConnectionFile" -ForegroundColor Green

    # Create an Internet Shortcut (.url) file to open Jupyter directly
    $ShortcutFile = Join-Path $OniaDest "Open_Jupyter.url"
    $ShortcutContent = @"
[InternetShortcut]
URL=$JupyterUrl
"@
    $ShortcutContent | Out-File -FilePath $ShortcutFile -Encoding utf8
    Write-Host "Jupyter shortcut created at $ShortcutFile" -ForegroundColor Green
}

# 8. Final Message
Write-Host "-----------------------------------------------" -ForegroundColor Green
Write-Host "Setup Complete!"
Write-Host "The ONIA folder has been copied to your Desktop with connection info."
Write-Host "-----------------------------------------------"