# 1. Basic Docker Checks
if (Get-Command "docker.exe" -ErrorAction SilentlyContinue) {
    Write-Host "Native Docker detected." -ForegroundColor Green
} else {
    Write-Error "Docker not found. Please run install.ps1 first."
    exit 1
}

# 2. Generate a random 12-character token
$RandomToken = [Convert]::ToBase64String([Guid]::NewGuid().ToByteArray()).Substring(0, 12)

# 3. Setup Paths and Variables
$DesktopPath = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop")
$OniaSource = Join-Path $PSScriptRoot "ONIA"
$OniaDest = Join-Path $DesktopPath "ONIA"
$ConnectionFile = Join-Path $OniaDest "jupyter_connection.txt"
$ImageName = "quay.io/jupyter/scipy-notebook:2026-02-19"
$ContainerName = "jupyter_server"

# 4. Copy ONIA Folder to Desktop and create Jupyter Connection File
if (Test-Path $OniaSource) {
    Write-Host "Copying ONIA folder to Desktop..." -ForegroundColor Cyan
    Copy-Item -Path $OniaSource -Destination $OniaDest -Recurse -Force
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

Write-Host "Starting Jupyter with a random token..." -ForegroundColor Cyan
docker run -d --name $ContainerName --restart always -p 8888:8888 -e JUPYTER_TOKEN=$RandomToken $ImageName

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
}

# 8. Final Message
Write-Host "-----------------------------------------------" -ForegroundColor Green
Write-Host "Setup Complete!"
Write-Host "The ONIA folder has been copied to your Desktop with connection info."
Write-Host "-----------------------------------------------"