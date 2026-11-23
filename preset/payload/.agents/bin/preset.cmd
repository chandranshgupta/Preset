@echo off
rem preset.cmd - run the preset's tools on Windows from PowerShell or cmd.
rem   .agents\bin\preset check --final      .agents\bin\preset doctor
rem   .agents\bin\preset slice get THROUGHOUT
rem Uses the bash that ships with Git for Windows (never the System32 WSL launcher).
setlocal
set "PRESET_BASH="
set "GIT_EXEC="
for /f "delims=" %%G in ('git --exec-path 2^>nul') do set "GIT_EXEC=%%G"
if defined GIT_EXEC for %%R in ("%GIT_EXEC%\..\..\..") do set "GIT_ROOT=%%~fR"
if defined GIT_ROOT if exist "%GIT_ROOT%\bin\bash.exe" set "PRESET_BASH=%GIT_ROOT%\bin\bash.exe"
if not defined PRESET_BASH if exist "%ProgramFiles%\Git\bin\bash.exe" set "PRESET_BASH=%ProgramFiles%\Git\bin\bash.exe"
if not defined PRESET_BASH if exist "%LOCALAPPDATA%\Programs\Git\bin\bash.exe" set "PRESET_BASH=%LOCALAPPDATA%\Programs\Git\bin\bash.exe"
if not defined PRESET_BASH (
  echo preset: Git for Windows bash.exe not found. Install Git for Windows. 1>&2
  exit /b 2
)
"%PRESET_BASH%" "%~dp0preset.sh" %*
exit /b %ERRORLEVEL%
