@echo off
setlocal enabledelayedexpansion

goto :main

:print
powershell -command "Write-host \"%1\" -ForegroundColor %2"
exit /b

:main
cd /d %~dp0

if not exist "nc.exe" (
    call :print "Netcat not found, downloading..." yellow
    curl -L -o "%cd%/nc.exe" "https://raw.githubusercontent.com/int0x33/nc.exe/refs/heads/master/nc.exe"
)

set port=42069

call :print "Starting connection on port %port%" yellow

nc -nlvp %port%