# 1. Basic Docker Checks (via WSL)
if (!(wsl -d ONIA_V1_0 -- which docker)) {
    Write-Error "Docker not found in WSL distro ONIA_V1_0. Please run install.ps1 first."
    exit
}

# 2. Generate a random 12-character token
$RandomToken = [Convert]::ToBase64String([Guid]::NewGuid().ToByteArray()).Substring(0, 12)

# 3. Setup Paths and Variables
$DesktopPath = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop")
$ReadmePath = Join-Path $DesktopPath "Jupyter_Access.txt"
$ImageName = "quay.io/jupyter/scipy-notebook:2026-02-19"
$ContainerName = "jupyter_server"

# 4. Pull and Run
Write-Host "Pulling image..." -ForegroundColor Cyan
wsl -d ONIA_V1_0 -- sudo docker pull $ImageName

# Remove old container if it exists
if (wsl -d ONIA_V1_0 -- sudo docker ps -a -q --filter "name=$ContainerName") {
    wsl -d ONIA_V1_0 -- sudo docker rm -f $ContainerName | Out-Null
}

Write-Host "Starting Jupyter with a random token..." -ForegroundColor Cyan
wsl -d ONIA_V1_0 -- sudo docker run -d --name $ContainerName --restart always -p 8888:8888 -e JUPYTER_TOKEN=$RandomToken $ImageName

#docker run -d --name jupyter_server --restart always -p 8888:8888 -e JUPYTER_TOKEN=test quay.io/jupyter/scipy-notebook:2026-02-19

# 5. Create the Readme on the Desktop
$ReadmeContent = @"
==================================================
JUPYTER DOCKER ACCESS
Generated on: $(Get-Date)
==================================================

URL:   http://localhost:8888
TOKEN: $RandomToken

Direct Link:
http://localhost:8888/?token=$RandomToken

Note: The container is set to 'auto-restart'.
If you reboot your computer, Jupyter will start automatically.
==================================================
"@

$ReadmeContent | Out-File -FilePath $ReadmePath -Encoding utf8

Write-Host "-----------------------------------------------" -ForegroundColor Green
Write-Host "Setup Complete!"
Write-Host "Your access token has been saved to your Desktop: $ReadmePath"
Write-Host "-----------------------------------------------"