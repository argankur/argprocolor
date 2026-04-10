@echo off
setlocal
if "%~1"=="" (
  echo Usage: release.cmd [patch^|minor^|major] [all^|vscode^|cursor]
  echo Example: release.cmd patch all
  exit /b 1
)

set BUMP=%~1
set TARGET=%~2
if "%TARGET%"=="" set TARGET=all

powershell -ExecutionPolicy Bypass -File "%~dp0release.ps1" -Bump %BUMP% -Target %TARGET%
endlocal
