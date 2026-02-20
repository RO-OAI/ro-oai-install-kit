# ==========================================================
# WSL2 + Ubuntu 24.04 + Docker (WSL) + VS Code
# Non-Interactive, Idempotent, Enterprise Safe
# Windows 10 2004+ & Windows 11
# ==========================================================

param(
    [string]$VSCodeVersion = "1.86.2"
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$LogFile = "C:\Temp\wsl-docker-vscode-install.log"

# Ensure logging directory exists
New-Item -ItemType Directory -Force -Path "C:\Temp" | Out-Null
Start-Transcript -Path $LogFile -Append

Write-Host "=== Starting idempotent WSL + Docker + VS Code installation ===" -ForegroundColor Cyan

# ----------------------------------------------------------
# 1. Ensure Admin
# ----------------------------------------------------------
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Error "Must run as Administrator."
    exit 1
}

# ----------------------------------------------------------
# Check if Docker is already installed in Windows
# ----------------------------------------------------------
$NativeDocker = Get-Command "docker.exe" -ErrorAction SilentlyContinue
if ($NativeDocker) {
    Write-Host "Docker is already installed in Windows ($($NativeDocker.Source)). Skipping WSL Docker setup." -ForegroundColor Green
} else {
    Write-Host "Docker not found in Windows. Proceeding with WSL Docker setup." -ForegroundColor Yellow
}

# ----------------------------------------------------------
# 2. Enable WSL Features if not enabled
# ----------------------------------------------------------
if (-not $NativeDocker) {
    Write-Host "Checking WSL features..." -ForegroundColor Yellow
    
    # Check WSL version (systemd requires 1.0.0+)
    try {
        $WslVersionInfo = wsl --version | Out-String
        if ($WslVersionInfo -match "WSL version:\s+(\d+\.\d+\.\d+)") {
            $WslVer = [version]$Matches[1]
            if ($WslVer -lt [version]"1.0.0") {
                Write-Warning "Your WSL version ($WslVer) might be too old for systemd. Consider running 'wsl --update'."
            }
        }
    } catch {
        Write-Warning "Could not determine WSL version. If systemd fails, run 'wsl --update'."
    }

    $wslFeature = (dism /online /Get-FeatureInfo /FeatureName:Microsoft-Windows-Subsystem-Linux) -match "State\s+:\s+Enabled"
    $vmFeature = (dism /online /Get-FeatureInfo /FeatureName:VirtualMachinePlatform) -match "State\s+:\s+Enabled"

    if (-not $wslFeature) {
        Write-Host "Enabling WSL feature..."
        dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    } else { Write-Host "WSL already enabled" }

    if (-not $vmFeature) {
        Write-Host "Enabling Virtual Machine Platform feature..."
        dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    } else { Write-Host "Virtual Machine Platform already enabled" }

    wsl --set-default-version 2
} else {
    Write-Host "Skipping WSL and Virtualization checks because native Docker is present." -ForegroundColor Cyan
}

# ----------------------------------------------------------
# 3. Install Ubuntu if not present
# ----------------------------------------------------------
if (-not $NativeDocker) {
    $DistroName = "ONIA_V1_0"
    $InstalledDistros = wsl --list --quiet

    if ($InstalledDistros -contains $DistroName) {
        Write-Host "$DistroName already installed" -ForegroundColor Green
    } else {
        Write-Host "Installing $DistroName..." -ForegroundColor Yellow
        $InstallDir = "C:\WSL\$DistroName"
        New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

    # Download official Ubuntu rootfs (Noble 24.04)
        $Tarball = "$env:TEMP\ubuntu-24.04-wsl-rootfs.tar.gz"
        Invoke-WebRequest -Uri "https://cloud-images.ubuntu.com/wsl/releases/24.04/20240423/ubuntu-noble-wsl-amd64-24.04lts.rootfs.tar.gz" -OutFile $Tarball

    # Import into WSL
        wsl --import $DistroName $InstallDir $Tarball --version 2

    # Set default distro
        wsl --set-default $DistroName
        wsl -d $DistroName -- echo "$DistroName installed"
    }

    # ----------------------------------------------------------
    # 4. Install Docker inside WSL if not installed
    # ----------------------------------------------------------
    $DockerCheck = wsl -d $DistroName -- which docker
    if ($DockerCheck) {
        Write-Host "Docker already installed inside WSL" -ForegroundColor Green
    } else {
        Write-Host "Installing Docker inside WSL (with systemd attempt)..." -ForegroundColor Yellow

        # 1) Enable systemd in the distro
        $WslEnableSystemdScript = (Join-Path $PSScriptRoot "scripts\enable-systemd.sh").Replace('C:\', '/mnt/c/').Replace('\', '/')
        Write-Host "Running enable-systemd.sh in WSL..." -ForegroundColor Cyan
        wsl -d $DistroName -- bash -lc "bash $WslEnableSystemdScript"

        # 2) Restart WSL so systemd actually takes effect
        Write-Host "Restarting WSL to apply systemd setting..." -ForegroundColor Yellow
        wsl --terminate $DistroName
        
        # Verify it actually stopped (loop briefly)
        $Timeout = 10
        while ((wsl --list --running --quiet) -contains $DistroName -and $Timeout -gt 0) {
            Start-Sleep -Seconds 1
            $Timeout--
        }

        # Small delay and a dummy command to ensure the distro is fully initialized again
        Start-Sleep -Seconds 5
        wsl -d $DistroName -- echo "Distro restarted"

        # 3) Install Docker Engine
        $WslInstallDockerScript = (Join-Path $PSScriptRoot "scripts\install-docker.sh").Replace('C:\', '/mnt/c/').Replace('\', '/')
        Write-Host "Running install-docker.sh in WSL..." -ForegroundColor Cyan
        wsl -d $DistroName -- bash -lc "bash $WslInstallDockerScript"

        Write-Host "Docker installed. Note: you may need to close/reopen the WSL session for docker group membership to apply." -ForegroundColor Green
    }
}

# ----------------------------------------------------------
# 5. Install VS Code if not installed
# ----------------------------------------------------------
$VSCodePath = "$env:ProgramFiles\Microsoft VS Code\Code.exe"

if (Test-Path $VSCodePath) {
    Write-Host "VS Code already installed" -ForegroundColor Green
} else {
    Write-Host "Installing VS Code $VSCodeVersion..." -ForegroundColor Yellow
    $VSCodeURL = "https://update.code.visualstudio.com/$VSCodeVersion/win32-x64/stable"
    $VSCodeInstaller = "$env:TEMP\VSCodeSetup.exe"
    Invoke-WebRequest -Uri $VSCodeURL -OutFile $VSCodeInstaller
    Start-Process -FilePath $VSCodeInstaller -ArgumentList "/VERYSILENT /NORESTART /MERGETASKS=!runcode" -Wait
}

# ----------------------------------------------------------
# 6. Install VS Code WSL Extension if missing
# ----------------------------------------------------------
$CodeCmd = "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd"
if (Test-Path $CodeCmd) {
    $Extensions = & $CodeCmd --list-extensions
    if ($Extensions -notcontains "ms-vscode-remote.remote-wsl") {
        Write-Host "Installing VS Code WSL extension..." -ForegroundColor Yellow
        & $CodeCmd --install-extension ms-vscode-remote.remote-wsl --force
    } else {
        Write-Host "VS Code WSL extension already installed" -ForegroundColor Green
    }
}

# ----------------------------------------------------------
# 7. Create PowerShell Aliases for Docker
# ----------------------------------------------------------
# Determine correct profile path for current PowerShell session
if ($PSVersionTable.PSVersion.Major -ge 6) {
    # PowerShell 7+
    $ProfilePath = $PROFILE.CurrentUserCurrentHost
} else {
    # Windows PowerShell 5.1
    $ProfilePath = [Environment]::ExpandEnvironmentVariables("$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1")
}

# Ensure directory exists
$ProfileDir = Split-Path $ProfilePath
if (-not (Test-Path $ProfileDir)) { New-Item -ItemType Directory -Force -Path $ProfileDir | Out-Null }

# Ensure the profile file exists
if (-not (Test-Path $ProfilePath)) { New-Item -ItemType File -Force -Path $ProfilePath | Out-Null }

# Read current content safely (if empty, set to empty string)
$ProfileContent = ""
if ((Get-Item $ProfilePath).Length -gt 0) {
    $ProfileContent = Get-Content $ProfilePath -Raw
}

# Add docker alias if missing
if (-not $NativeDocker -and $ProfileContent -notmatch "function docker") {
    Add-Content $ProfilePath "`nfunction docker { wsl docker `$args }`n"
    Write-Host "Added docker function to PowerShell profile"
} elseif ($NativeDocker) {
    Write-Host "Skipping docker PowerShell function because native Docker is present"
}

Write-Host "PowerShell profile updated at $ProfilePath"

Write-Host "=== Installation complete. REBOOT REQUIRED ===" -ForegroundColor Red

Stop-Transcript
exit 0