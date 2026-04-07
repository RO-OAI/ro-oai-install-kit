@echo off
setlocal ENABLEDELAYEDEXPANSION

:: Set proxy server and exception
set "proxyServer=proxy.olimpiada-ai.ro:3128"
set "exceptions=localhost;127.0.0.1;*.olimpiada-ai.ro*"

:: Check if ProxySettingsPerUser is set to 0 in Policies (forces HKLM)
set "regRoot=HKCU"
reg query "HKLM\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxySettingsPerUser 2>nul | find "0x0" >nul
if %errorlevel% equ 0 set "regRoot=HKLM"

echo Using registry root: %regRoot%

:: Optional: proxy authentication (leave empty if proxy has no auth)
set "proxyUser="
set "proxyPass="

:: Define IP ranges
set ipRanges= 8.8.8.8/32 8.8.4.4/32 91.99.208.14/32 46.225.232.213/32

:: Meniu interactiv
choice /M "Selecteaza y pentru Blocare sau n pentru Deblocare"
if errorlevel 2 goto :unblock
if errorlevel 1 goto :block

goto :eof

:block
if exist "C:\Windows\System32\drivers\etc\rules.wfw" (
    echo Deja blocat.
    echo Daca nu ai rulat tu deja scriptul de blocare, ruleaza intai deblocarea si apoi blocarea din nou.
    pause
    goto :eof
)
echo Blocking...
netsh advfirewall export "C:\Windows\System32\drivers\etc\rules.wfw"
netsh advfirewall firewall set rule all new enable=no
netsh advfirewall firewall set rule group="Core Networking" new enable=yes
netsh advfirewall set allprofiles firewallpolicy blockinbound,blockoutbound
netsh advfirewall firewall add rule name="AllowDNS" program="%SystemRoot%\System32\svchost.exe" dir=out action=allow protocol=UDP remoteport=53

for %%i in (%ipRanges%) do (
    netsh advfirewall firewall add rule name="Allow_%%i" dir=out action=allow remoteip=%%i enable=yes
)

REG ADD "%regRoot%\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f
REG ADD "%regRoot%\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /t REG_SZ /d %proxyServer% /f
REG ADD "%regRoot%\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /t REG_SZ /d %exceptions% /f
REG ADD "%regRoot%\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoDetect /t REG_DWORD /d 0 /f
if defined proxyUser (
    REG ADD "%regRoot%\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyUser /t REG_SZ /d "!proxyUser!" /f
    REG ADD "%regRoot%\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyPass /t REG_SZ /d "!proxyPass!" /f
)
pause
goto :eof

:unblock
echo Unblocking...
netsh advfirewall set allprofiles firewallpolicy blockinbound,allowoutbound

if exist "C:\Windows\System32\drivers\etc\rules.wfw" (
    netsh advfirewall firewall del rule all
    netsh advfirewall import "C:\Windows\System32\drivers\etc\rules.wfw"
    del /f "C:\Windows\System32\drivers\etc\rules.wfw"
) else (
    netsh advfirewall firewall del rule name="AllowDNS"
    for %%i in (%ipRanges%) do (
        netsh advfirewall firewall del rule name="Allow_%%i"
    )
    netsh advfirewall firewall set rule all new enable=yes
)

REG ADD "%regRoot%\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f
REG ADD "%regRoot%\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /t REG_SZ /d %proxyServer% /f
REG ADD "%regRoot%\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /t REG_SZ /d %exceptions% /f
REG DELETE "%regRoot%\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyUser /f 2>nul
REG DELETE "%regRoot%\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyPass /f 2>nul
pause
