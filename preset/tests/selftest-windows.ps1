#Requires -Version 5.1
<#
.SYNOPSIS
    Windows-native self-test for the project preset: install.ps1, install.cmd, preset.cmd and the
    run.bat launcher kit, run from PowerShell and cmd. Complements tests/selftest.sh (Git Bash).

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tests\selftest-windows.ps1
    pwsh -File tests\selftest-windows.ps1
#>
$ErrorActionPreference = "Continue"
$preset = Split-Path -Parent $PSScriptRoot
$work = Join-Path ([IO.Path]::GetTempPath()) ("pp-" + [guid]::NewGuid().ToString("N").Substring(0, 8))
New-Item -ItemType Directory $work | Out-Null
$env:GIT_AUTHOR_NAME = "selftest"; $env:GIT_AUTHOR_EMAIL = "selftest@example.invalid"
$env:GIT_COMMITTER_NAME = "selftest"; $env:GIT_COMMITTER_EMAIL = "selftest@example.invalid"
$env:NO_COLOR = "1"; $env:PYTHONPYCACHEPREFIX = Join-Path $work "pycache"
$script:pass = 0; $script:fail = 0

function Ok([string]$m) { $script:pass++; Write-Host "  pass  $m" }
function Bad([string]$m, [string]$detail = "") {
    $script:fail++; Write-Host "  FAIL  $m" -ForegroundColor Red
    if ($detail) { $detail.Split("`n") | Select-Object -First 15 | ForEach-Object { Write-Host "        | $_" } }
}
function Check([string]$m, [bool]$cond, [string]$detail = "") { if ($cond) { Ok $m } else { Bad $m $detail } }
function NewRepo([string]$path) {
    New-Item -ItemType Directory -Force $path | Out-Null
    & git -c init.defaultBranch=main init -q $path | Out-Null
    & git -C $path config commit.gpgsign false
}
function TreeHash([string]$root) {
    Get-ChildItem -LiteralPath $root -Recurse -File -Force |
        Where-Object { $_.FullName -notmatch '\\\.git\\' } |
        ForEach-Object { $_.FullName.Substring($root.Length) + " " + (Get-FileHash -LiteralPath $_.FullName).Hash } |
        Sort-Object
}

Write-Host ("project-preset Windows selftest - PowerShell {0} - {1}" -f $PSVersionTable.PSVersion, (& git --version))

Write-Host "`n== install.ps1 into a path with spaces and Devanagari"
$repoPs = Join-Path $work "my project परियोजना"
NewRepo $repoPs
$out = & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $preset "install.ps1") -Target $repoPs 2>&1 | Out-String
Check "Windows PowerShell 5.1 runs install.ps1 (exit 0)" ($LASTEXITCODE -eq 0) $out
Check "files installed" (Test-Path -LiteralPath (Join-Path $repoPs ".agents\PROJECT.xml")) $out
Check "core.hooksPath set" ((& git -C $repoPs config core.hooksPath) -eq ".githooks")

if (Get-Command pwsh -ErrorAction SilentlyContinue) {
    $repoPwsh = Join-Path $work "pwsh repo"
    NewRepo $repoPwsh
    $out = & pwsh -NoProfile -File (Join-Path $preset "install.ps1") -Target $repoPwsh 2>&1 | Out-String
    Check "PowerShell 7 runs install.ps1 (exit 0)" ($LASTEXITCODE -eq 0) $out
} else { Write-Host "  skip  PowerShell 7 not installed" }

Write-Host "`n== install.cmd, and identical results from every entry point"
$repoCmd = Join-Path $work "cmd repo"
NewRepo $repoCmd
$out = & cmd /c "`"$(Join-Path $preset 'install.cmd')`" `"$repoCmd`"" 2>&1 | Out-String
Check "install.cmd (exit 0)" ($LASTEXITCODE -eq 0) $out
$repoSh = Join-Path $work "bash repo"
NewRepo $repoSh
$bash = Join-Path (Resolve-Path (Join-Path (& git --exec-path) "..\..\..")) "bin\bash.exe"
& $bash (Join-Path $preset "install.sh").Replace('\', '/') --target $repoSh.Replace('\', '/') | Out-Null
$diff = Compare-Object (TreeHash $repoSh) (TreeHash $repoCmd)
Check "bash and cmd installs are byte-identical" ($null -eq $diff) ($diff | Out-String)
$diff = Compare-Object (TreeHash $repoSh) (TreeHash $repoPs)
Check "bash and PowerShell installs are byte-identical" ($null -eq $diff) ($diff | Out-String)

Write-Host "`n== preset.cmd from PowerShell and cmd (no sh on PATH needed)"
Push-Location -LiteralPath $repoPs
$out = & .\.agents\bin\preset.cmd doctor 2>&1 | Out-String
Check "PowerShell: .agents\bin\preset doctor (exit 0)" ($LASTEXITCODE -eq 0) $out
$out = & cmd /c ".agents\bin\preset check --all" 2>&1 | Out-String
Check "cmd: .agents\bin\preset check --all runs the gate" ($out -match "precheck - all") $out
$out = & .\.agents\bin\preset.cmd slice get P9 2>&1 | Out-String
Check "preset slice get P9" ($out -match "Pervasive observability") $out
& git add -A 2>$null; & git commit -q -m "chore: install project preset" 2>&1 | Out-Null
Check "commit through the hook from PowerShell" ((& git rev-list --count HEAD) -eq "1")
Set-Content -LiteralPath "leak.py" -Value ('k = "AKIA' + 'ABCDEFGHIJKLMNOP"') -Encoding ascii
& git add leak.py; & git commit -q -m "feat: add key" 2>&1 | Out-Null
Check "secret blocked from PowerShell, commit not created" ((& git rev-list --count HEAD) -eq "1")
& git rm -q --cached leak.py; Remove-Item leak.py
Pop-Location

Write-Host "`n== run.bat launcher kit (direct modes through cmd)"
$app = Join-Path $work "launcher app"
New-Item -ItemType Directory (Join-Path $app "app") -Force | Out-Null
$kit = Join-Path $preset "payload\.agents\skills\self-healing-launcher\templates"
Copy-Item (Join-Path $kit "launcher.py"), (Join-Path $kit "preflight.py") $app
$bat = [IO.File]::ReadAllText((Join-Path $kit "run.bat")) -replace "(?<!`r)`n", "`r`n"
[IO.File]::WriteAllText((Join-Path $app "run.bat"), $bat)
Copy-Item (Join-Path $preset "payload\.agents\skills\observability-tracing\templates\trace_kit.py") (Join-Path $app "app")
Set-Content (Join-Path $app "app\__init__.py") "" -Encoding ascii
Set-Content (Join-Path $app "app\main.py") "from app.trace_kit import traced`n@traced`ndef f(x):`n    return x * 2`nprint(f(21))" -Encoding ascii
Set-Content (Join-Path $app ".env.example") "API_KEY=" -Encoding ascii
Push-Location -LiteralPath $app
$out = & cmd /c ".\run.bat diagnose --yes" 2>&1 | Out-String
Check "run.bat bootstraps .venv and runs diagnose" ((Test-Path ".venv\Scripts\python.exe") -and $out -match "Getting ready") $out
Check "blank .env value stops the run (exit 1)" ($LASTEXITCODE -eq 1 -and $out -match "no value for: API_KEY") $out
Set-Content ".env" "API_KEY=abc" -Encoding ascii
$out = & cmd /c ".\run.bat run --yes" 2>&1 | Out-String
Check "run.bat run (exit 0, app output, trace file)" ($LASTEXITCODE -eq 0 -and $out -match "42" -and (Get-ChildItem "logs\trace\*.jsonl").Count -ge 1) $out
$out = & cmd /c ".\run.bat trace --yes" 2>&1 | Out-String
Check "run.bat trace prints the report with lines executed" ($LASTEXITCODE -eq 0 -and $out -match "lines executed") $out
$out = & cmd /c ".\run.bat report --yes" 2>&1 | Out-String
Check "run.bat report" ($LASTEXITCODE -eq 0 -and $out -match "trace report") $out
$out = & cmd /c ".\run.bat nonsense --yes" 2>&1 | Out-String
Check "unknown mode exits 2" ($LASTEXITCODE -eq 2) $out
$out = & cmd /c ".\run.bat diagnose --rebuild --yes" 2>&1 | Out-String
Check "run.bat --rebuild recreates .venv" ($LASTEXITCODE -eq 0 -and $out -match "removing .venv") $out
Pop-Location

Write-Host "`n== uninstall through install.ps1"
$out = & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $preset "install.ps1") -Target $repoCmd -Uninstall -Yes 2>&1 | Out-String
Check "install.ps1 -Uninstall -Yes (exit 0)" ($LASTEXITCODE -eq 0) $out
Check "preset removed, triad kept" ((-not (Test-Path (Join-Path $repoCmd ".agents\bin"))) -and (Test-Path (Join-Path $repoCmd "FLOW.md"))) $out

Remove-Item -Recurse -Force -LiteralPath $work -ErrorAction SilentlyContinue
Write-Host ("`n{0} passed, {1} failed" -f $script:pass, $script:fail)
if ($script:fail -gt 0) { exit 1 } else { exit 0 }
