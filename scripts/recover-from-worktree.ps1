#Requires -Version 5.1
[CmdletBinding()]
param(
  [string]$SourceRef = 'HEAD',
  [string]$ReportPath = '',
  [string]$WorktreeDir = '.recovery\\WT',
  [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Write-Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Write-Err ($m){ Write-Host "[ERR ] $m" -ForegroundColor Red }

function Latest-Report {
  $dir = Join-Path (Get-Location) 'Saved/Recovery'
  if (-not (Test-Path -LiteralPath $dir)) { return '' }
  $f = Get-ChildItem -LiteralPath $dir -File -Filter 'suspects-*.txt' | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if ($f) { return $f.FullName } else { return '' }
}

function Parse-Report([string]$path){
  $list = @()
  if (-not (Test-Path -LiteralPath $path)) { return $list }
  $lines = Get-Content -LiteralPath $path
  foreach($ln in $lines){
    if ($ln -like 'GIT:*') {
      $rel = ($ln -replace '^GIT:\s+','').Trim()
      # if report accidentally contains repo-root leading segment, strip it
      $rel = $rel -replace '^S:/Project/Unreal5/DungeonGenerator/',''
      $rel = $rel -replace '^/',''
      $rel = $rel -replace '/','\\'
      $list += $rel
    }
  }
  return ($list | Sort-Object -Unique)
}

function Copy-Triplet($srcNoExt,$dstNoExt){
  foreach($ext in '.uasset','.uexp','.ubulk'){
    $s = "$srcNoExt$ext"; $d = "$dstNoExt$ext"
    if (Test-Path -LiteralPath $s) {
      Write-Info "Copy $s -> $d"
      if (-not $DryRun){ New-Item -ItemType Directory -Force -Path (Split-Path $d -Parent) | Out-Null; Copy-Item -LiteralPath $s -Destination $d -Force }
    }
  }
}

if (-not $ReportPath) { $ReportPath = Latest-Report }
if (-not $ReportPath) { Write-Err 'No suspects report found. Run recover-after-crash.ps1 -WriteReport first.'; exit 1 }

Write-Info "Using report: $ReportPath"
$targets = Parse-Report -path $ReportPath
if (-not $targets -or $targets.Count -eq 0) { Write-Err 'Report contains no GIT paths.'; exit 1 }

# Prepare worktree
if (Test-Path -LiteralPath $WorktreeDir) { git worktree remove -f "$WorktreeDir" 2>$null | Out-Null }
Write-Info "Adding worktree at $WorktreeDir for $SourceRef"
git worktree add --detach "$WorktreeDir" "$SourceRef" | Out-Null

# LFS should smudge during checkout; still ensure pointers are resolved in worktree
Push-Location "$WorktreeDir"
try {
  git lfs install | Out-Null
  git lfs fetch --all | Out-Null
  git lfs checkout | Out-Null
}
catch { Write-Warn "LFS in worktree: $_" }
Pop-Location

$copied = @()
foreach($rel in $targets){
  $src = Join-Path "$WorktreeDir" $rel
  # construct no-ext base
  $srcNoExt = [System.IO.Path]::Combine((Split-Path $src -Parent), [System.IO.Path]::GetFileNameWithoutExtension($src))
  $dst = Join-Path (Get-Location) $rel
  $dstNoExt = [System.IO.Path]::Combine((Split-Path $dst -Parent), [System.IO.Path]::GetFileNameWithoutExtension($dst))
  if (Test-Path -LiteralPath "$srcNoExt.uasset"){
    Copy-Triplet -srcNoExt $srcNoExt -dstNoExt $dstNoExt
    $copied += @("$dstNoExt.uasset","$dstNoExt.uexp","$dstNoExt.ubulk")
  } else {
    Write-Warn "Not found in source: $rel"
  }
}

git worktree remove -f "$WorktreeDir" | Out-Null

if (-not $DryRun -and $copied.Count -gt 0){
  Write-Info "Staging copied files"
  git add -- $copied 2>$null | Out-Null
  if (git status --porcelain=v1) {
    git commit -m "Recover: restore $(($targets|Measure-Object).Count) assets from $SourceRef after crash" | Out-Null
  }
}

Write-Info "Done. Review changes and push if satisfied."
