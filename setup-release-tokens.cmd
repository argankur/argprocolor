@echo off
setlocal
powershell -ExecutionPolicy Bypass -File "%~dp0setup-release-tokens.ps1" %*
endlocal
