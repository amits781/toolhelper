@echo off
setlocal

:: Join all arguments and wrap them correctly
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0toolhelper.ps1" %*

endlocal
