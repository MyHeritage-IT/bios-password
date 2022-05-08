@echo off
SetLocal EnableDelayedExpansion
set newpassword=%1

if [%newpassword%]==[] goto HELP

wmic computersystem get manufacturer | findstr Dell > NUL
if %ERRORLEVEL% EQU 0 GOTO DELL

wmic computersystem get manufacturer | findstr LENOVO > NUL
if %ERRORLEVEL% EQU 0 GOTO LENOVO

wmic computersystem get manufacturer | findstr Hewlett-Packard > NUL
if %ERRORLEVEL% EQU 0 GOTO HP

goto ERROR

:DELL
echo %COMPUTERNAME% Dell system detected
FOR /F %%i IN ('powershell -ExecutionPolicy Bypass .\dell_check.ps1') DO set R=%%i
if !R! == False (
	powershell -ExecutionPolicy Bypass .\dell-bios-password.ps1 -NoUserPrompt -AdminSet -AdminPassword !newpassword!

	FOR /F %%i IN ('powershell -ExecutionPolicy Bypass .\dell_check.ps1') DO set R=%%i
	if !R! == False (echo %COMPUTERNAME% Failed to set the password) else (echo %COMPUTERNAME% New password set)
) else (
	echo %COMPUTERNAME% password is already set
)
goto END

:LENOVO
echo %COMPUTERNAME% Lenovo system detected. Lenovo doesn't support setting a new password for the first time.
FOR /F %%i IN ('powershell "(Get-WmiObject -Namespace root\wmi -Class Lenovo_BiosPasswordSettings).PasswordState"') DO set R=%%i
if !R! == 0 (
	echo %COMPUTERNAME% password is not set

	powershell -ExecutionPolicy Bypass .\lenovo-bios-password.ps1 -NoUserPrompt -SupervisorSet -SupervisorPassword !newpassword! -OldSupervisorPassword ""

	FOR /F %%i IN ('powershell "(Get-WmiObject -Namespace root\wmi -Class Lenovo_BiosPasswordSettings).PasswordState"') DO set R=%%i
	if !R! == 0 (echo %COMPUTERNAME% Failed to set the password) else (echo %COMPUTERNAME% New password set)
) else (
	echo %COMPUTERNAME% password is already set
)
goto END

:HP
echo %COMPUTERNAME% HP system detected
FOR /F %%i IN ('powershell -ExecutionPolicy Bypass .\hp_check.ps1') DO set R=%%i
if !R! == 0 (
	powershell -ExecutionPolicy Bypass .\hp-bios-password.ps1 -NoUserPrompt -SetupSet -SetupPassword !newpassword!

	FOR /F %%i IN ('powershell -ExecutionPolicy Bypass .\hp_check.ps1') DO set R=%%i
	if !R! == 0 (echo %COMPUTERNAME% Failed to set the password) else (echo %COMPUTERNAME% New password set)
) else (
	echo %COMPUTERNAME% password is already set
)
goto END

:HELP
echo Usage: password.cmd NEW-PASSWORD
goto END

:ERROR
echo %COMPUTERNAME% Unkown manufacturer. Aborting...

:END
