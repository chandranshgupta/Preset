@echo off
rem Double-click it or run from cmd: install.cmd C:\path\to\repo  [extra install.ps1 switches]
rem Without an argument, it installs into the current folder.
if "%~1"=="" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" -Target "%CD%"
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" -Target "%~1" %2 %3 %4 %5 %6 %7 %8
)
if errorlevel 1 pause
