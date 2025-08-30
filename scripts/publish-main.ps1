<#
Publishes local branch to remote with Git LFS, creates a snapshot tag, and prints verification info.
Usage (from repo root):
  powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\publish-main.ps1
Optional params:
  -Remote origin -Branch main -NoTag
#>
[CmdletBinding()]
param(
  [string]$Remote = 'origin',
  [string]$Branch = 'main',
  [switch]$NoTag,
  [switch]$ForceOverwrite
)

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$ErrorActionPreference = 'Continue'

function Write-Section([string]$Title) {
  Write-Host "`n==== $Title ====\n" -ForegroundColor Cyan
}

Write-Section "Repo status"
try { git --no-pager status -sb 2>&1 | Write-Host } catch {}

# Ensure branch
$current = (git --no-pager rev-parse --abbrev-ref HEAD 2>$null).Trim()
if (-not $current) { throw "Not a git repository or HEAD is undefined." }
if ($current -ne $Branch) {
  Write-Section "Switching to $Branch"
  git switch $Branch 2>&1 | Write-Host
}

# LFS hooks/update
Write-Section "Git LFS update"
git lfs update --force 2>&1 | Write-Host

if ($ForceOverwrite) {
  # Prepare overwrite with backup and lease
  Write-Section "Fetch & divergence"
  git fetch --prune $Remote 2>&1 | Write-Host
  try { git rev-list --left-right --count "$Branch...$Remote/$Branch" 2>&1 | Write-Host } catch {}

  $ls = (git ls-remote --heads $Remote $Branch 2>$null | Select-Object -First 1)
  $remoteSha = if ($ls) { ($ls -split '\s+')[0] } else { '' }
  if ($remoteSha) {
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backupTag = "backup-$Remote-$Branch-$stamp"
    Write-Section "Create backup tag $backupTag -> $remoteSha"
    git tag -a $backupTag $remoteSha -m "Backup of $Remote/$Branch before overwrite" 2>&1 | Write-Host
    Write-Section "Push backup tag $backupTag"
    git push $Remote $backupTag 2>&1 | Write-Host
    Write-Section "Force push with lease ($remoteSha)"
    git push --force-with-lease=refs/heads/$Branch:$remoteSha $Remote $Branch 2>&1 | Write-Host
  } else {
    Write-Section "Force push (no remote head found)"
    git push --force $Remote $Branch 2>&1 | Write-Host
  }
} else {
  # Normal push
  Write-Section "Push $Branch to $Remote"
  git push $Remote $Branch 2>&1 | Write-Host
}

# Push all LFS objects for the branch
Write-Section "Push LFS objects (all)"
git lfs push --all $Remote $Branch 2>&1 | Write-Host

# Create and push snapshot tag unless disabled
if (-not $NoTag) {
  $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
  $short = (git rev-parse --short HEAD).Trim()
  $tag = "snapshot-$stamp"
  Write-Section "Create tag $tag for $short"
  git tag -a $tag -m "Snapshot after syncing local $Branch ($short)" 2>&1 | Write-Host
  Write-Section "Push tag $tag"
  git push $Remote $tag 2>&1 | Write-Host
}

# Show remote/local head & divergence
Write-Section "Verification"
$ls = (git ls-remote --heads $Remote $Branch 2>$null | Select-Object -First 1)
$remoteSha = if ($ls) { ($ls -split '\s+')[0] } else { '' }
$localSha  = (git rev-parse HEAD 2>$null).Trim()
if ($remoteSha) { Write-Host ("REMOTE {0}/{1} = {2}" -f $Remote,$Branch,$remoteSha) }
if ($localSha)  { Write-Host ("LOCAL  {0}       = {1}" -f $Branch,$localSha) }

try {
  $div = (git rev-list --left-right --count "$Branch...$Remote/$Branch" 2>$null).Trim()
  if ($div) { Write-Host ("DIVERGENCE (left=local ahead | right=remote ahead): {0}" -f $div) }
} catch {}

Write-Host "\nDone." -ForegroundColor Green
