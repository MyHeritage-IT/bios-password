@echo off
SetLocal EnableDelayedExpansion
set newpassword=%1

if %ERRORLEVEL% EQU 0 GOTO HP

wmic computersystem get manufacturer | findstr Dell > NUL
if %ERRORLEVEL% EQU 0 GOTO DELL

wmic computersystem get manufacturer | findstr Dell > NUL
if %ERRORLEVEL% EQU 0 GOTO LENOVO

wmic computersystem get manufacturer | findstr Hewlett-Packard > NUL
if %ERRORLEVEL% EQU 0 GOTO HP

goto ERROR

:DELL
echo Dell system detected
FOR /F %%i IN ('powershell .\dell_check.ps1') DO set R=%%i
if !R! == False (
	powershell -ExecutionPolicy Bypass .\dell-bios-password.ps1 -AdminSet -AdminPassword !newpassword!

	FOR /F %%i IN ('powershell .\dell_check.ps1') DO set R=%%i
	if !R! == False (echo Failed to set the password) else (echo New password set)
) else (
	echo password is already set
)
goto END

:LENOVO
echo Lenovo system detected
FOR /F %%i IN ('powershell "(Get-WmiObject -Namespace root\wmi -Class Lenovo_BiosPasswordSettings).PasswordState"') DO set R=%%i
if !R! == 0 (
	echo Lenovo not supported
REM	echo password is not set

REM	powershell -ExecutionPolicy Bypass .\lenovo-bios-password.ps1 -NoUserPrompt -SupervisorSet -SupervisorPassword !newpassword! -OldSupervisorPassword ""

REM	FOR /F %%i IN ('powershell "(Get-WmiObject -Namespace root\wmi -Class Lenovo_BiosPasswordSettings).PasswordState"') DO set R=%%i
REM	if !R! == 0 (echo Failed to set the password) else (echo New password set)
) else (
	echo password is already set
)
goto END

:HP
echo HP system detected
FOR /F %%i IN ('powershell .\hp_check.ps1') DO set R=%%i
if !R! == False (
	powershell -ExecutionPolicy Bypass .\dell-bios-password.ps1 -AdminSet -AdminPassword !newpassword!

	FOR /F %%i IN ('powershell .\hp_check.ps1') DO set R=%%i
	if !R! == False (echo Failed to set the password) else (echo New password set)
) else (
	echo password is already set
)
goto END

:ERROR
echo Unkown manufacturer. Aborting...

:END
