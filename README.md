## ❗ DISCLAIMER ❗

This is malware, only run it on a virtual machine or if you know what you're doing.

## Introduction ##

`main.bat`
- reverse shell program
- disables windows security notifications, windows firewall and windows defender
- schedules the reverse shell client to run every minute if it isn't already

`connect.bat`
- convenience program to start the listener
- downloads netcat to attempt the connection if it isn't already available

`revsh.ps1`
- unobfuscated code of the reverse shell client that runs on the target machine