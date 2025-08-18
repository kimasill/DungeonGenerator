[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

function Info($msg) { Write-Host ("[sync-main] " + $msg) }

try {
  if (-not (Test-Path ".git")) { Info "Not at repo root. Aborting."; exit 1 }

  Info "Clearing file attributes under Content (read-only/hidden/system)"
  attrib -R -S -H "Content" /S /D 2>$null | Out-Null

  Info "Fetching origin with prune"
  git fetch --prune | Out-Null

  $cur = git rev-parse --abbrev-ref HEAD
  Info ("Current branch: {0}" -f $cur)

  if ($cur -ne 'main') {
    Info "Checking out main"
    git checkout main | Out-Null
  }

  Info "Resetting main to origin/main (hard)"
  git reset --hard origin/main | Out-Null

  Info "Ensuring Git LFS and pulling LFS objects"
  git lfs install | Out-Null
  git lfs pull | Out-Null

  $head = git --no-pager log --oneline -n 1
  Info ("HEAD now at: {0}" -f $head)
  exit 0
}
catch {
  Info ("Failed: " + $_.Exception.Message)
  exit 1
}
