@echo off
rem run.bat - the one way to run this project on Windows (prime directive P8).
rem   run.bat              arrow-key menu       run.bat run | trace | test | diagnose | report | repair | ports | logs
rem   run.bat --rebuild    delete .venv first, then recreate it
rem   flags --plain (no colour)  --yes (never prompt)
rem This file only finds Python and builds .venv; launcher.py does everything else.
setlocal EnableExtensions
cd /d "%~dp0"
chcp 65001 >nul
set "PYTHONUTF8=1"
set "PYTHONIOENCODING=utf-8"
set "PY_MIN=3.10"
set "VPY=.venv\Scripts\python.exe"

echo %* | findstr /i /c:"--rebuild" >nul && if exist ".venv" (
  echo   [HEAL] --rebuild: removing .venv
  rmdir /s /q ".venv"
)

if exist "%VPY%" (
  "%VPY%" -c "import sys; sys.exit(0 if sys.version_info >= tuple(map(int, '%PY_MIN%'.split('.'))) else 1)" >nul 2>&1
  if errorlevel 1 (
    echo   [HEAL] .venv is stale or from another machine - rebuilding it
    rmdir /s /q ".venv"
  )
)

if exist "%VPY%" goto launch

set "PY="
call :try python
if not defined PY call :try py -3
if not defined PY for /d %%D in ("%LOCALAPPDATA%\Programs\Python\Python3*" "%ProgramFiles%\Python3*") do if not defined PY call :try "%%D\python.exe"
if not defined PY (
  echo.
  echo   [FAIL] Python %PY_MIN%+ was not found.
  echo   How to fix:
  echo     1. Install Python %PY_MIN%+ from https://www.python.org/downloads/
  echo        or run:  winget install Python.Python.3.12 --scope user
  echo     2. Tick "Add python.exe to PATH" in the installer.
  echo     3. Open a new terminal and run run.bat again.
  echo.
  pause
  exit /b 1
)
echo   [HEAL] creating .venv with %PY%
%PY% -m venv .venv
if errorlevel 1 (
  echo   [FAIL] could not create .venv. Try:  %PY% -m venv .venv
  pause
  exit /b 1
)

:launch
"%VPY%" launcher.py %*
exit /b %ERRORLEVEL%

:try
rem Accept an interpreter only if it runs and meets PY_MIN (this rejects the Microsoft Store stub).
%* -c "import sys; sys.exit(0 if sys.version_info >= tuple(map(int, '%PY_MIN%'.split('.'))) else 1)" >nul 2>&1 && set "PY=%*"
exit /b 0
