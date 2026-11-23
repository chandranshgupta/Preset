#Requires -Version 5.1
<#
.SYNOPSIS
    Install (or uninstall) the project preset in a git repository on Windows.

.DESCRIPTION
    Runs install.sh / uninstall.sh through the bash that ships with Git for Windows, so Windows,
    Linux and macOS installs come from the same code and cannot drift apart. The hooks and gate
    need that same bash at commit time, so nothing extra is required.

    Safe to re-run: the AGENTS.md block is replaced in place, standards and project-owned files
    are kept, and preset-owned files refresh only with -Force.

.PARAMETER Target            Repository to install into. Default: the current directory.
.PARAMETER Force             Refresh preset-owned files (scripts, skills, workflows, hooks, templates).
.PARAMETER UpgradeStandard   Also replace PROJECT.xml and modules/, keeping a .bak of each.
.PARAMETER NoHooks           Place the files but leave core.hooksPath alone.
.PARAMETER NoMemory          Do not create PROJECT_BRAIN.md, FLOW.md, DECISION.md.
.PARAMETER NoAdapters        Do not create CLAUDE.md, GEMINI.md, .agent/ aliases, .claude/skills stubs.
.PARAMETER NoVendored        Skip the vendored third-party skills (lean install).
.PARAMETER WithCi            Also add .github/workflows/preset-gate.yml.
.PARAMETER SkillsFrom        Also import every skill folder under this path into .agents/skills/.
.PARAMETER Only              With -SkillsFrom, import only these skill names (comma separated).
.PARAMETER Uninstall         Remove the preset instead (keeps the memory triad and constitution).
.PARAMETER Purge             With -Uninstall, also remove profile.xml and allow.
.PARAMETER Yes               With -Uninstall, do not ask for confirmation.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\install.ps1 -Target C:\code\my-project

.EXAMPLE
    .\install.ps1 -Target . -SkillsFrom $HOME\.gemini\config\skills -Only api-design-principles,docker-expert

.EXAMPLE
    .\install.ps1 -Target C:\code\my-project -Uninstall
#>
[CmdletBinding()]
param(
    [string]$Target = ".",
    [switch]$Force,
    [switch]$UpgradeStandard,
    [switch]$NoHooks,
    [switch]$NoMemory,
    [switch]$NoAdapters,
    [switch]$NoVendored,
    [switch]$WithCi,
    [string]$SkillsFrom = "",
    [string]$Only = "",
    [switch]$Uninstall,
    [switch]$Purge,
    [switch]$Yes
)

$ErrorActionPreference = "Stop"

function Fail([string]$Message) {
    Write-Host "install: $Message" -ForegroundColor Red
    exit 2
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Fail "git is not on PATH (install Git for Windows)" }

# Use the bash from Git for Windows. Never the System32 WSL launcher: it maps paths differently
# and would install with wrong line endings and permissions.
$bash = $null
$execPath = (& git --exec-path 2>$null)
if ($execPath) {
    $gitRoot = (Resolve-Path (Join-Path $execPath "..\..\..") -ErrorAction SilentlyContinue)
    foreach ($candidate in @("bin\bash.exe", "usr\bin\bash.exe")) {
        if ($gitRoot -and (Test-Path (Join-Path $gitRoot $candidate))) { $bash = Join-Path $gitRoot $candidate; break }
    }
}
if (-not $bash) {
    foreach ($candidate in @("$env:ProgramFiles\Git\bin\bash.exe", "${env:ProgramFiles(x86)}\Git\bin\bash.exe", "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe")) {
        if ($candidate -and (Test-Path $candidate)) { $bash = $candidate; break }
    }
}
if (-not $bash) { Fail "Git for Windows bash.exe not found. Install Git for Windows, or run install.sh from Git Bash." }

function To-Posix([string]$Path) {
    $full = (Resolve-Path -LiteralPath $Path -ErrorAction Stop).ProviderPath
    return ($full -replace '\\', '/')
}

if (-not (Test-Path -LiteralPath $Target)) { Fail "$Target does not exist" }

if ($Uninstall) {
    $arguments = @((To-Posix (Join-Path $PSScriptRoot "uninstall.sh")), "--target", (To-Posix $Target))
    if ($Purge) { $arguments += "--purge" }
    if ($Yes)   { $arguments += "--yes" }
} else {
    $arguments = @((To-Posix (Join-Path $PSScriptRoot "install.sh")), "--target", (To-Posix $Target))
    if ($Force)           { $arguments += "--force" }
    if ($UpgradeStandard) { $arguments += "--upgrade-standard" }
    if ($NoHooks)         { $arguments += "--no-hooks" }
    if ($NoMemory)        { $arguments += "--no-memory" }
    if ($NoAdapters)      { $arguments += "--no-adapters" }
    if ($NoVendored)      { $arguments += "--no-vendored" }
    if ($WithCi)          { $arguments += "--with-ci" }
    if ($SkillsFrom)      { $arguments += @("--skills-from", (To-Posix $SkillsFrom)) }
    if ($Only)            { $arguments += @("--only", $Only) }
}

& $bash @arguments
exit $LASTEXITCODE
