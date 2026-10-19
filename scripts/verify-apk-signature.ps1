param(
    [Parameter(Mandatory=$true)][string]$Apk,
    [string]$SignerJar = (Join-Path (Split-Path -Parent $PSScriptRoot) '.buildtools/uber-apk-signer.jar')
)
$ErrorActionPreference='Stop'
if(-not(Test-Path -LiteralPath $Apk)){throw 'APK not found'}
if(-not(Test-Path -LiteralPath $SignerJar)){throw 'Supply the existing uber-apk-signer JAR with -SignerJar'}
$expected='18b6264d0d50c604fe70de23ff4a97e270d442ae6249819f2f092cfaedac69c6'
# Verification only. This script never builds, aligns, signs or replaces the APK.
& java -jar $SignerJar -a $Apk --onlyVerify --verifySha256 $expected
if($LASTEXITCODE -ne 0){throw 'Signature does not match the original GitHub APK, or APK verification failed'}
