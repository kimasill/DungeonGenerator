[CmdletBinding()]
param(
  [switch]$ReplaceCurrent # If set, overwrite current assets with previous version instead of creating copies
)

$ErrorActionPreference = 'Stop'

function Info($m){ Write-Host ("[recover-refine-stair] " + $m) }

Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path) | Out-Null
Set-Location -Path .. | Out-Null  # go to repo root

if (-not (Test-Path '.git')) { Info 'Run from repo root/scripts'; exit 1 }

# Close UE and clear attributes
Get-Process -Name UnrealEditor -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.Id -Force }
attrib -R -S -H "Content" /S /D 2>$null | Out-Null

$ts = Get-Date -Format yyyyMMdd-HHmmss
$backup = "Saved/RecoveryBackup/$ts"
$recoveredDir = "Content/PCG/Recovered"
New-Item -ItemType Directory -Force -Path $backup | Out-Null
New-Item -ItemType Directory -Force -Path $recoveredDir | Out-Null

# Collect candidate stair/refine PCG assets
$cands = @()
$cands += Get-ChildItem -Recurse -Path "Content/PCG" -File -Include *Refine*Stair*.uasset, *Stair*Refine*.uasset, *refineStair*.uasset -ErrorAction SilentlyContinue
$cands += Get-ChildItem -Recurse -Path "Content/PCG" -File -Include *Stair*.uasset -ErrorAction SilentlyContinue
$cands = $cands | Sort-Object FullName -Unique

function PrevCommit($rel){
  $log = git log --format=%H -- "$rel" 2>$null
  if ($LASTEXITCODE -ne 0 -or -not $log) { return $null }
  $lines = $log -split "`n"
  if ($lines.Length -ge 2) { return $lines[1] } else { return $null }
}

$restored = 0
foreach ($f in $cands) {
  $rel = $f.FullName.Replace((Resolve-Path ".").Path + '\\','').Replace('\\','/')
  $prev = PrevCommit $rel
  if (-not $prev) { continue }

  # Backup current
  $bk = Join-Path $backup $rel
  New-Item -ItemType Directory -Force -Path (Split-Path $bk) | Out-Null
  if (Test-Path $f.FullName) { Copy-Item $f.FullName $bk -Force }

  if ($ReplaceCurrent) {
    Info ("Replacing current with previous for {0}" -f $rel)
    git checkout $prev -- "$rel" | Out-Null
    $restored++
  } else {
    Info ("Exporting previous version for {0}" -f $rel)
    # Checkout previous into a temp path, then copy into Recovered with suffix
    $tmp = Join-Path $env:TEMP ("prev_" + [IO.Path]::GetFileName($rel))
    if (Test-Path $tmp) { Remove-Item $tmp -Force }
    # Use 'git show' to write the blob content (LFS pointer will be expanded by lfs smudge if configured)
    $blob = git show "$prev:$rel" 2>$null
    # Checkout previous version into working tree, copy as __prev, then restore current HEAD
    git checkout $prev -- "$rel" | Out-Null
    $dst = Join-Path $recoveredDir ((Split-Path $rel -LeafBase) + "__prev.uasset")
    Copy-Item $f.FullName $dst -Force
    # Restore current from HEAD
    git checkout HEAD -- "$rel" | Out-Null
    $restored++
  }
}

# If nothing from git, try autosaves
if ($restored -eq 0) {
  $auto = Get-ChildItem -Recurse -Path "Saved/Autosaves" -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match '(?i)refine.*stair|stair.*refine|refineStair' -or $_.Name -like '*Stair*.uasset' } |
    Sort-Object LastWriteTime -Descending | Select-Object -First 3
  foreach ($a in $auto) {
    Copy-Item $a.FullName (Join-Path $recoveredDir $a.Name) -Force
    $restored++
  }
}

# Ensure LFS for recovered
try { git lfs install | Out-Null } catch {}

# Stage recovered copies only (not replacing current unless -ReplaceCurrent)
if (-not $ReplaceCurrent -and (Test-Path $recoveredDir)) {
  git add "$recoveredDir/**" 2>$null | Out-Null
}

# Commit if staged
$staged = git diff --cached --name-only
if ($staged) {
  git commit -m "chore: add recovered previous versions for stair/refine PCG graphs"
  git push -u origin HEAD
}

Info ("Recovered count: {0}" -f $restored)
if (-not $ReplaceCurrent) {
  Info "Open UE and compare with Content/PCG/Recovered/*__prev.uasset to copy refineStairPoints nodes back."
} else {
  Info "Previous versions were restored in-place. Verify in UE and commit if satisfied."
}
