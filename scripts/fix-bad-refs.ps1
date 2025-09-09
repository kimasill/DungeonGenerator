Param(
  [string]$RepoPath = (Resolve-Path "$PSScriptRoot/.."),
  [switch]$NoPush
)

$ErrorActionPreference = 'Continue'
Set-Location -LiteralPath $RepoPath

function Write-Section([string]$t){ Write-Host "`n==== $t ====\n" -ForegroundColor Cyan }
function Try-DeleteRef([string]$ref){
  if (-not $ref) { return }
  git update-ref -d $ref 2>$null | Out-Null
  $path = Join-Path ".git" ($ref -replace '^refs/','refs/')
  if (Test-Path -LiteralPath $path) { Remove-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue }
}

Write-Section "Detect bad refs"
$refs = git for-each-ref --format="%(refname) %(objectname)" 2>$null
$bad = @()
foreach($line in $refs){
  if (-not $line) { continue }
  $parts = $line -split "\s+"
  if ($parts.Count -lt 2) { continue }
  $name = $parts[0]; $obj = $parts[1]
  if (-not $obj) { $bad += $name; continue }
  & git cat-file -e $obj 2>$null
  if ($LASTEXITCODE -ne 0) { $bad += $name }
}
$bad | ForEach-Object { Write-Host "BAD: $_" -ForegroundColor Yellow }

# Always remove feature/dynamic-layout family
$targets = @(
  'refs/heads/feature/dynamic-layout',
  'refs/remotes/origin/feature/dynamic-layout'
) + $bad
$targets = $targets | Sort-Object -Unique

Write-Section "Delete targeted refs"
$targets | ForEach-Object { Try-DeleteRef $_ }

# Clean packed-refs
$packed = ".git/packed-refs"
if (Test-Path -LiteralPath $packed){
  $bk = ".git/packed-refs.bak-" + (Get-Date -Format 'yyyyMMdd-HHmmss')
  Move-Item -LiteralPath $packed -Destination $bk -Force -ErrorAction SilentlyContinue
}
git pack-refs --all --prune 2>&1 | Write-Host

# Remove push refspecs referencing the feature branch
Write-Section "Clean remote.origin.push refspecs"
$pushSpecs = git config --get-all remote.origin.push 2>$null
if ($pushSpecs){
  foreach($ps in $pushSpecs){ if ($ps -match 'feature/dynamic-layout'){ git config --unset remote.origin.push $ps } }
}

# Remote HEAD 정리(잘못된 origin/HEAD로 인한 오류 방지)
Write-Section "Fix remote HEAD"
git update-ref -d refs/remotes/origin/HEAD 2>&1 | Write-Host
if (Test-Path -LiteralPath ".git/refs/remotes/origin/HEAD") {
  Remove-Item -LiteralPath ".git/refs/remotes/origin/HEAD" -Force -ErrorAction SilentlyContinue
}
git remote set-head origin -d 2>&1 | Write-Host

# Housekeeping
Write-Section "Repack/GC/FSCK"
git reflog expire --expire=now --all 2>&1 | Write-Host
git repack -ad 2>&1 | Write-Host
git gc --prune=now --aggressive 2>&1 | Write-Host
git fsck --full --no-reflogs 2>&1 | Write-Host

if (-not $NoPush){
  Write-Section "Push deletions to origin"
  git push origin :feature/dynamic-layout 2>&1 | Write-Host
  # 최신 원격 정보 동기화
  Write-Section "Fetch origin (prune)"
  git fetch --prune origin +refs/heads/*:refs/remotes/origin/* 2>&1 | Write-Host
  # origin/main이 있으면 로컬 main을 재설정
  $hasOriginMain = git show-ref --verify refs/remotes/origin/main 2>$null
  if ($hasOriginMain) {
    Write-Section "Reset local main to origin/main"
    git checkout -B main refs/remotes/origin/main 2>&1 | Write-Host
    git symbolic-ref HEAD refs/heads/main 2>&1 | Write-Host
  }
  Write-Section "Push main"
  git push origin main 2>&1 | Write-Host
  Write-Section "LFS push (all)"
  git lfs push --all origin main 2>&1 | Write-Host
  Write-Section "Verify heads"
  $remote = (git ls-remote --heads origin main 2>$null | Select-Object -First 1)
  $remoteSha = if ($remote) { ($remote -split '\s+')[0] } else { '' }
  $localSha = (git rev-parse HEAD 2>$null).Trim()
  Write-Host ("REMOTE origin/main = {0}" -f $remoteSha)
  Write-Host ("LOCAL  main      = {0}" -f $localSha)
}

Write-Host "\nDone." -ForegroundColor Green
