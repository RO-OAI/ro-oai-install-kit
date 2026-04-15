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
$ImageName = "ghcr.io/ro-oai/ro-oai-install-kit-image:sha-ba14743"
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
    # Define special characters for diacritics
    $s_comma = [char]0x219  # ș
    $t_comma = [char]0x21B  # ț
    $a_breve = [char]0x103  # ă
    $i_hat = [char]0xee     # î
    $a_hat = [char]0xe2     # â

    $JupyterUrl = "http://localhost:8888/?token=$RandomToken"
    $PlatformUrl = "https://platform.olimpiada-ai.ro/ro"
    $ReadmeContent = "# Informa" + $t_comma + "ii Conectare Jupyter`n`nAceasta este folderul t" + $a_breve + "u de lucru (ONIA). Fi" + $s_comma + "ierele tale de lucru (precum notebook-urile) se afl" + $a_breve + " " + $i_hat + "n subfolderul **`work`**.`n`nMai jos g" + $a_breve + "se" + $s_comma + "ti datele necesare pentru a accesa mediul Jupyter Notebook " + $s_comma + "i link-ul c" + $a_breve + "tre platforma concursului.`n`n### " + [char]0xD83C + [char]0xDF10 + " Platforma Concursului`nPo" + $t_comma + "i accesa platforma direct prin acest link sau folosind scurt" + $a_breve + "tura **`"Platforma_OAI.url`"** din acest folder:`n**Link:** [" + $PlatformUrl + "](" + $PlatformUrl + ")`n`n### " + [char]0xD83D + [char]0xDD17 + " Link de Conectare Jupyter`nPoti accesa Jupyter folosind scurt" + $a_breve + "tura **`"Open_Jupyter.url`"** din acest folder sau direct prin acest link:`n**Link:** [" + $JupyterUrl + "](" + $JupyterUrl + ")`n`n### " + [char]0xD83D + [char]0xDD11 + " Token de Acces`nDac" + $a_breve + " " + $t_comma + "i se cere un token pentru autentificare, folose" + $s_comma + "te codul de mai jos:`n**Token:** ``" + $RandomToken + "```n`n---`n`n### " + [char]0xD83D + [char]0xDCBB + " Lucrul " + $i_hat + "n VS Code (Dev Containers)`nRecomand" + $a_breve + "m folosirea VS Code cu extensia Dev Containers pentru o experien" + $t_comma + $a_breve + " integrat" + $a_breve + ".`n`n1. Deschide scurt" + $a_breve + "tura **`"Open_in_VSCode.lnk`"** din acest folder.`n2. Dac" + $a_breve + " apare o notificare " + $i_hat + "n col" + $t_comma + "ul din dreapta-jos, apas" + $a_breve + " pe **Reopen in Container**.`n3. Dac" + $a_breve + " notificarea nu apare, apas" + $a_breve + " **F1** " + $s_comma + "i alege **Dev Containers: Reopen in Container**.`n`n---`n`n### " + [char]0x26A0 + [char]0xFE0F + " Depanare: Docker Desktop nu ruleaz" + $a_breve + "?`nDac" + $a_breve + " Jupyter nu se " + $i_hat + "ncarc" + $a_breve + " sau prime" + $s_comma + "ti o eroare de conexiune, verific" + $a_breve + " dac" + $a_breve + " **Docker Desktop** este pornit:`n1. Caut" + $a_breve + " **Docker Desktop** " + $i_hat + "n meniul Start.`n2. Lanseaz" + $a_breve + " aplica" + $t_comma + "ia " + $s_comma + "i a" + $s_comma + "teapt" + $a_breve + " p" + $a_hat + "n" + $a_breve + " c" + $a_hat + "nd pictograma din bara de sistem (l" + $a_hat + "ng" + $a_breve + " ceas) arat" + $a_breve + " c" + $a_breve + " Docker este `"running`" (verde).`n3. Dup" + $a_breve + " ce Docker a pornit, re" + $i_hat + "ncearc" + $a_breve + " s" + $a_breve + " deschizi link-ul de mai sus.`n`n---`n`n### " + [char]0xD83C + [char]0xDF10 + " Set" + $a_breve + "ri Proxy (Dac" + $a_breve + " nu ai acces la documentatie/dataset)`nDac" + $a_breve + " documentatia sau datasetul nu sunt accesibile, este posibil s" + $a_breve + " fie necesar" + $a_breve + " configurarea manual" + $a_breve + " a proxy-ului " + $i_hat + "n Windows (Settings > Network & Internet > Proxy):`n`n1. Activeaz" + $a_breve + " **`"Use a proxy server`"** .`n2. **Proxy Server:** ``proxy.olimpiada-ai.ro```n3. **Port:** ``3128```n4. **Exceptions (Nu se folose" + $s_comma + "te proxy pentru):** ``localhost;127.0.0.1;*.olimpiada-ai.ro*```n`n---`n"
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

    # 7. Create VS Code Shortcut to the ONIA folder
    $VSCodePath = "$env:ProgramFiles\Microsoft VS Code\Code.exe"
    if (Test-Path $VSCodePath) {
        # Calculate hex-encoded path for devcontainer URI
        # The URI format is: vscode-remote://dev-container+<hex_path><folder_inside_container>
        $Bytes = [System.Text.Encoding]::UTF8.GetBytes($OniaDest)
        $HexPath = ($Bytes | ForEach-Object { $_.ToString("x2") }) -join ""
        $DevContainerUri = "vscode-remote://dev-container+$HexPath/home/jovyan/work"

        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut((Join-Path $OniaDest "Open_in_VSCode.lnk"))
        $Shortcut.TargetPath = $VSCodePath
        $Shortcut.Arguments = "`"$OniaDest`""
        $Shortcut.WorkingDirectory = $OniaDest
        $Shortcut.Description = "Open ONIA folder in Dev Container"
        $Shortcut.Save()
        Write-Host "VS Code shortcut created in ONIA folder." -ForegroundColor Green
    } else {
        Write-Warning "VS Code not found at $VSCodePath. Skipping shortcut creation."
    }
}

# 8. Final Message
Write-Host "-----------------------------------------------" -ForegroundColor Green
Write-Host "Setup Complete!"
Write-Host "The ONIA folder has been copied to your Desktop with connection info."
Write-Host "-----------------------------------------------"
