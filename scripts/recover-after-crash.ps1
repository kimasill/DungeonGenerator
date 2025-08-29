#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess=$true)]
param(
  [int]$HoursBack = 12,
  [string]$ContentRoot = "Content",
  [string]$AutosavesRoot = "Saved/Autosaves",
  [string]$FallbackCommit = "HEAD",
  [switch]$PreferAutosaves,
  [switch]$IncludeAllRecent,           # 최근 변경 전체를 대상으로(용량 무관)
  [int]$SmallSizeBytes = 4096,         # 작은 파일(포인터/깨짐 의심)
  [string[]]$IncludeGlob = @("Content/**"),
  [switch]$DryRun,
  [switch]$WriteReport
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Info($msg) { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Warn($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Err ($msg) { Write-Host "[ERR ] $msg" -ForegroundColor Red }

function Resolve-PathSafe([string]$p) {
  $rp = Resolve-Path -LiteralPath $p -ErrorAction SilentlyContinue
  if ($rp) { return $rp.Path } else { return $null }
}

function Get-Suspects {
  param(
    [string]$Root,
    [int]$Hours,
    [switch]$AllRecent,
    [int]$SmallBytes,
    [string[]]$Include
  )
  $cut = (Get-Date).AddHours(-1 * [Math]::Abs($Hours))
  $patterns = @('*.uasset','*.umap','*.uexp','*.ubulk')
  $files = @()
  foreach ($glob in $Include) {
    $base = Split-Path $glob -Leaf
    $dir  = Split-Path $glob -Parent
    if (-not $dir) { $dir = $Root }
    $rp = Resolve-PathSafe $dir
    if (-not $rp) { continue }
    foreach ($pat in $patterns) {
      $f = Get-ChildItem -LiteralPath $rp -Recurse -File -Filter $pat -ErrorAction SilentlyContinue
      $files += $f
    }
  }
  $files = $files | Sort-Object FullName -Unique
  if ($AllRecent) {
    return $files | Where-Object { $_.LastWriteTime -ge $cut }
  } else {
    return $files | Where-Object { $_.LastWriteTime -ge $cut -and $_.Length -lt $SmallBytes }
  }
}

function Get-Sidecars([string]$path) {
  $base = [System.IO.Path]::Combine((Split-Path $path -Parent), [System.IO.Path]::GetFileNameWithoutExtension($path))
  return @("$base.uasset","$base.uexp","$base.ubulk")
}

function Find-AutosaveCandidate([string]$originalPath, [string]$autosavesRoot) {
  $leaf = [System.IO.Path]::GetFileName($originalPath)
  $ar = Resolve-PathSafe $autosavesRoot
  if (-not $ar) { return $null }
  # 검색 폭을 넓히기 위해 파일명 기준으로 전수 검색
  $cands = Get-ChildItem -LiteralPath $ar -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -ieq $leaf } | Sort-Object LastWriteTime -Descending
  return $cands | Select-Object -First 1
}

function Copy-Triplet([string]$srcBaseNoExt, [string]$dstBaseNoExt) {
  foreach ($ext in @('.uasset','.uexp','.ubulk')) {
    $s = "$srcBaseNoExt$ext"
    $d = "$dstBaseNoExt$ext"
    if (Test-Path -LiteralPath $s) {
      if ($PSCmdlet.ShouldProcess("$s", "Copy to $d")) {
        if ($DryRun) { Write-Info "DRYRUN copy $s -> $d" }
        else {
          New-Item -ItemType Directory -Force -Path (Split-Path $d -Parent) | Out-Null
          Copy-Item -LiteralPath $s -Destination $d -Force
        }
      }
    }
  }
}

function Restore-FromAutosave([System.IO.FileInfo]$target, [System.IO.FileInfo]$autosaveFile) {
  $dstBase = [System.IO.Path]::Combine($target.DirectoryName, [System.IO.Path]::GetFileNameWithoutExtension($target.Name))
  $srcBase = [System.IO.Path]::Combine($autosaveFile.DirectoryName, [System.IO.Path]::GetFileNameWithoutExtension($autosaveFile.Name))
  Write-Info "Restore from Autosave: $($autosaveFile.FullName) -> $($target.FullName)"
  Copy-Triplet -srcBaseNoExt $srcBase -dstBaseNoExt $dstBase
}

function Restore-FromGit([string]$path, [string]$commit) {
  Write-Info "Restore from Git ${commit}: $path"
  if ($DryRun) { return }
  & git restore --source=$commit -- "$path"
  # 사이드카도 함께 시도
  foreach ($ext in @('.uexp','.ubulk')) {
    $sp = [System.IO.Path]::ChangeExtension($path, $ext)
    & git restore --source=$commit -- "$sp" 2>$null
  }
}

function Ensure-LfsReady {
  Write-Info "Ensuring LFS checkout & pointers"
  if ($DryRun) { return }
  & git lfs install | Out-Null
  & git lfs fetch --all | Out-Null
  & git lfs checkout | Out-Null
}

# 0) 사전 준비: 읽기전용 해제
Write-Info "Clearing read-only attributes (may take a moment)"
if (-not $DryRun) { cmd /c attrib -R *.* /S /D | Out-Null }

# 1) LFS 정합성 우선 확보
Ensure-LfsReady

# 2) 대상 파일(의심 또는 최근 변경) 수집
$suspects = Get-Suspects -Root $ContentRoot -Hours $HoursBack -AllRecent:$IncludeAllRecent -SmallBytes $SmallSizeBytes -Include $IncludeGlob
if (-not $suspects -or $suspects.Count -eq 0) {
  Write-Warn "No suspect files found (within $HoursBack hours). Use -IncludeAllRecent to widen scan or adjust -IncludeGlob."
}
else {
  Write-Info ("Suspects: {0}" -f $suspects.Count)
  foreach ($s in $suspects) { Write-Host "  - $($s.FullName)" }
  if ($WriteReport) {
    $outDir = Resolve-PathSafe "Saved/Recovery"
    if (-not $outDir) { New-Item -ItemType Directory -Force -Path "Saved/Recovery" | Out-Null; $outDir = Resolve-PathSafe "Saved/Recovery" }
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $report = Join-Path $outDir "suspects-$stamp.txt"
    $lines = @()
    $repoRoot = (Resolve-Path -LiteralPath ".").Path
    foreach ($s in $suspects) {
      $full = (Resolve-Path -LiteralPath $s.FullName).Path
      $fullNorm = $full -replace '/', '\\'
      $rootNorm = $repoRoot -replace '/', '\\'
      $fullLower = $fullNorm.ToLowerInvariant()
      $rootLower = $rootNorm.ToLowerInvariant()
      $rel = $fullNorm
      if ($fullLower.StartsWith($rootLower)) {
        $rel = $fullNorm.Substring($rootNorm.Length).TrimStart('\\')
      }
      $relGit = $rel -replace '\\','/'
      $lines += "FULL: $full"
      $lines += "GIT:  $relGit"
    }
    Set-Content -LiteralPath $report -Value $lines -Encoding UTF8
    Write-Info "Suspects report: $report"
  }
}

# 3) 각 파일에 대해 Autosave 선호시 Autosaves 우선, 아니면 Git 우선 복원
foreach ($f in $suspects) {
  try {
    $fi = Get-Item -LiteralPath $f -ErrorAction SilentlyContinue
    if (-not $fi) { continue }
    $auto = Find-AutosaveCandidate -originalPath $f -autosavesRoot $AutosavesRoot
    $did = $false
    if ($PreferAutosaves -and $auto) {
      Restore-FromAutosave -target $fi -autosaveFile $auto
      $did = $true
    }
    elseif (-not $PreferAutosaves) {
      Restore-FromGit -path $f -commit $FallbackCommit
      $did = $true
      # 필요 시 Autosave가 더 최신이면 그걸로 덮어쓰기
      if ($auto -and $auto.LastWriteTime -gt $fi.LastWriteTime) {
        Write-Info "Autosave is newer; applying autosave after Git restore"
        Restore-FromAutosave -target (Get-Item -LiteralPath $f) -autosaveFile $auto
      }
    }
    elseif ($auto) {
      Restore-FromAutosave -target $fi -autosaveFile $auto
      $did = $true
    }

    if (-not $did) {
      Write-Warn "No recovery source found for: $f; attempting Git fallback"
      Restore-FromGit -path $f -commit $FallbackCommit
    }
  }
  catch {
    Write-Err "Failed to process $f : $_"
  }
}

# 4) 최종 LFS 체크아웃 및 간단 검증
Ensure-LfsReady
Write-Info "Recovery pass complete. Consider running: Fix Up Redirectors in UE, then resave assets."

if (-not $DryRun) {
  Write-Info "You can now stage and commit recovered assets if desired."
}
