# ==========================================================
# WSL2 + Ubuntu 24.04 + Docker (WSL) + VS Code
# Non-Interactive, Idempotent, Enterprise Safe
# Windows 10 2004+ & Windows 11
# ==========================================================

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

    Write-Host "Docker is already installed in Windows ($($NativeDocker.Source)). Skipping Docker Desktop setup." -ForegroundColor Green
} else {
    Write-Host "Docker not found in Windows. Proceeding with Docker setup." -ForegroundColor Yellow
}

# ----------------------------------------------------------
# 3. Install Docker Desktop if requested and not present
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

    wsl --update
    wsl --set-default-version 2

    Write-Host "Installing Docker Desktop..." -ForegroundColor Yellow
    $DockerDesktopURL = "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
    $DockerDesktopInstaller = "$env:TEMP\DockerDesktopInstaller.exe"

    if (-not (Test-Path $DockerDesktopInstaller)) {
        Write-Host "Downloading Docker Desktop Installer..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $DockerDesktopURL -OutFile $DockerDesktopInstaller
    }

    Write-Host "Running Docker Desktop Installer (silent)..." -ForegroundColor Cyan
    $Process = Start-Process -FilePath $DockerDesktopInstaller -ArgumentList "install", "--quiet", "--accept-license" -Wait -PassThru
    if ($Process.ExitCode -eq 0) {
        Write-Host "Docker Desktop installed successfully." -ForegroundColor Green
    } else {
        Write-Host "Docker Desktop installation failed with exit code $($Process.ExitCode)." -ForegroundColor Red
    }
    # Refresh PATH for current session
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# ----------------------------------------------------------
# 5. Install VS Code if not installed
# ----------------------------------------------------------
$VSCodePath = "$env:ProgramFiles\Microsoft VS Code\Code.exe"

if (Test-Path $VSCodePath) {
    Write-Host "VS Code already installed" -ForegroundColor Green
} else {
    Write-Host "Installing VS Code Latest..." -ForegroundColor Yellow
    $VSCodeURL = "https://vscode.download.prss.microsoft.com/dbazure/download/stable/560a9dba96f961efea7b1612916f89e5d5d4d679/VSCodeSetup-x64-1.116.0.exe"
    $VSCodeInstaller = "$env:TEMP\VSCodeSetup.exe"
    Invoke-WebRequest -Uri $VSCodeURL -OutFile $VSCodeInstaller
    Start-Process -FilePath $VSCodeInstaller -ArgumentList "/VERYSILENT /NORESTART /MERGETASKS=!runcode" -Wait
}

# ----------------------------------------------------------
# 6. Install VS Code Extensions (WSL, Python, Jupyter)
# ----------------------------------------------------------
$CodeCmd = "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd"
if (Test-Path $CodeCmd) {
    Write-Host "Checking VS Code extensions..." -ForegroundColor Cyan
    $Extensions = & $CodeCmd --list-extensions
    
    $TargetExtensions = @("ms-vscode-remote.remote-wsl", "ms-python.python", "ms-toolsai.jupyter", "ms-vscode-remote.remote-containers")
    foreach ($Ext in $TargetExtensions) {
        if ($Extensions -notcontains $Ext) {
            Write-Host "Installing VS Code extension: $Ext..." -ForegroundColor Yellow
            & $CodeCmd --install-extension $Ext --force
        } else {
            Write-Host "VS Code extension $Ext already installed" -ForegroundColor Green
        }
    }
}


Write-Host "=== Installation complete. REBOOT REQUIRED ===" -ForegroundColor Red

Stop-Transcript
exit 0