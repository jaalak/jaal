# Builds the signed release APK and publishes it as GitHub release v<version> with a
# `jaal.apk` asset. The web app's download page and Settings → updates both read
# the latest release, so this is all it takes to ship an update.
#
# Before each release, bump `version:` in apps/mobile/pubspec.yaml: the part after "+"
# must go up every time, or Android refuses to install it over the old one.
# Needs android/key.properties (gitignored) pointing at the release keystore.
param([string]$Notes = '')
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')

if (-not (Test-Path android/key.properties)) { throw 'android/key.properties missing: release builds must use the release key' }
$version = (Select-String -Path pubspec.yaml -Pattern '^version:\s*([0-9.]+)\+').Matches[0].Groups[1].Value
$tag = "v$version"
gh release view $tag -R jaalak/jaal 2>$null | Out-Null
if ($LASTEXITCODE -eq 0) { throw "$tag is already released; bump version in pubspec.yaml first" }

& C:\flutter\bin\flutter.bat build apk --release
if ($LASTEXITCODE -ne 0) { throw 'build failed' }
$apk = Join-Path $env:TEMP 'jaal.apk'
Copy-Item build/app/outputs/flutter-apk/app-release.apk $apk -Force

if (-not $Notes) { $Notes = "jaal $version for android" }
gh release create $tag $apk -R jaalak/jaal --title "jaal $version" --notes $Notes
