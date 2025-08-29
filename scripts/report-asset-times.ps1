#Requires -Version 5.1
[CmdletBinding()]
param(
  [string[]]$Assets = @(
    'Content/PCG/PCG_SingleFloor.uasset',
    'Content/PCG/Subgraphs/PCG_RandomYaw.uasset',
    'Content/PCG/Loops/PCG_SetRotationAlongWall.uasset',
    'Content/PCG/Subgraphs/PCG_FacingMode.uasset'
  ),
  [string]$OutDir = 'Saved/Recovery'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Line($sw, $text){
  $sw.WriteLine($text)
  Write-Host $text
}

if (-not (Test-Path -LiteralPath $OutDir)) {
  New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
}
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$outPath = Join-Path $OutDir "asset-times-$stamp.txt"

$sw = New-Object System.IO.StreamWriter($outPath, $false, [System.Text.Encoding]::UTF8)
try {
  Write-Line $sw ("Report time: {0:yyyy-MM-dd HH:mm:ss}" -f (Get-Date))
  Write-Line $sw ("Repo root: " + (Resolve-Path -LiteralPath ".").Path)
  Write-Line $sw ""

  foreach($a in $Assets){
    $win = $a -replace '/', '\\'
    $exists = Test-Path -LiteralPath $win
    Write-Line $sw ("ASSET: {0}" -f $a)
    Write-Line $sw ("  Exists: {0}" -f $exists)
    if ($exists) {
      $fi = Get-Item -LiteralPath $win
      Write-Line $sw ("  FS LastWriteTime: {0:yyyy-MM-dd HH:mm:ss}" -f $fi.LastWriteTime)
      Write-Line $sw ("  Size: {0}" -f $fi.Length)
    }
    # Autosave candidate
    $leaf = [System.IO.Path]::GetFileName($win)
    if (Test-Path -LiteralPath 'Saved/Autosaves'){
      $auto = Get-ChildItem -LiteralPath 'Saved/Autosaves' -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -ieq $leaf } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
      if ($auto){
        Write-Line $sw ("  Autosave: {0:yyyy-MM-dd HH:mm:ss} | {1} | {2}" -f $auto.LastWriteTime, $auto.Length, $auto.FullName)
      } else {
        Write-Line $sw "  Autosave: (none)"
      }
    } else {
      Write-Line $sw "  Autosave: (Saved/Autosaves missing)"
    }
    Write-Line $sw ""
  }
}
finally {
  $sw.Flush(); $sw.Dispose()
}

Write-Host "Report written: $outPath" -ForegroundColor Cyan