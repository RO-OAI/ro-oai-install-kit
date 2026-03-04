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
$ReadmeFile = Join-Path $OniaDest "README.md"
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

# 6. Create Jupyter README File in the copied folder
if (Test-Path $OniaDest) {
    $JupyterUrl = "http://localhost:8888/?token=$RandomToken"
    $PlatformUrl = "https://platform.olimpiada-ai.ro/ro"
    $ReadmeContent = @"
# Informații Conectare Jupyter

Aceasta este folderul tău de lucru (ONIA). Mai jos găsești datele necesare pentru a accesa mediul Jupyter Notebook și link-ul către platforma concursului.

### 🌐 Platforma Concursului
Poți accesa platforma direct prin acest link sau folosind scurtătura **"Platforma_OAI.url"** din acest folder:
**Link:** [$PlatformUrl]($PlatformUrl)

### 🔗 Link de Conectare Jupyter
Poti accesa Jupyter folosind scurtătura **"Open_Jupyter.url"** din acest folder sau direct prin acest link:
**Link:** [$JupyterUrl]($JupyterUrl)

### 🔑 Token de Acces
Dacă ți se cere un token pentru autentificare, folosește codul de mai jos:
**Token:** `$RandomToken`

---

### ⚠️ Depanare: Docker Desktop nu rulează?
Dacă Jupyter nu se încarcă sau primești o eroare de conexiune, verifică dacă **Docker Desktop** este pornit:
1. Caută **Docker Desktop** în meniul Start.
2. Lansează aplicația și așteaptă până când pictograma din bara de sistem (lângă ceas) arată că Docker este "running" (verde).
3. După ce Docker a pornit, reîncearcă să deschizi link-ul de mai sus.

---
"@
    $ReadmeContent | Out-File -FilePath $ReadmeFile -Encoding utf8
    Write-Host "Jupyter README file created at $ReadmeFile" -ForegroundColor Green

    # Create an Internet Shortcut (.url) file to open Jupyter directly
    $ShortcutFile = Join-Path $OniaDest "Open_Jupyter.url"
    $ShortcutContent = @"
[InternetShortcut]
URL=$JupyterUrl
"@
    $ShortcutContent | Out-File -FilePath $ShortcutFile -Encoding utf8
    Write-Host "Jupyter shortcut created at $ShortcutFile" -ForegroundColor Green

    # Create an Internet Shortcut (.url) file for the Platform
    $PlatformShortcutFile = Join-Path $OniaDest "Platforma_OAI.url"
    $PlatformShortcutContent = @"
[InternetShortcut]
URL=$PlatformUrl
"@
    $PlatformShortcutContent | Out-File -FilePath $PlatformShortcutFile -Encoding utf8
    Write-Host "Platform shortcut created at $PlatformShortcutFile" -ForegroundColor Green
}

# 8. Final Message
Write-Host "-----------------------------------------------" -ForegroundColor Green
Write-Host "Setup Complete!"
Write-Host "The ONIA folder has been copied to your Desktop with connection info."
Write-Host "-----------------------------------------------"