$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$source = Join-Path $root 'jwxt-webapp'
$targets = @(
    (Join-Path $root 'apk-source/assets'),
    (Join-Path $root 'cicp-jwxt-android/app/src/main/assets')
)

foreach ($target in $targets) {
    $scheduleAssets = Join-Path $target 'schedule-assets'
    New-Item -ItemType Directory -Path $scheduleAssets -Force | Out-Null
    Copy-Item (Join-Path $source 'index.html') (Join-Path $target 'index.html') -Force
    Copy-Item (Join-Path $source 'schedule-assets/*') $scheduleAssets -Force
}

Write-Output 'Web page and offline schedule artwork synced to both Android packaging sources.'
