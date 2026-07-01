# Build APK cho EnglishMe
# Chạy: .\build_apk.ps1
# Chạy release: .\build_apk.ps1 -Mode release
# Chạy split ABI: .\build_apk.ps1 -Mode release -SplitAbi

param(
    [ValidateSet("debug", "release", "profile")]
    [string]$Mode = "release",

    [switch]$SplitAbi
)

$projectDir = $PSScriptRoot
Set-Location $projectDir

Write-Host "=== EnglishMe APK Builder ===" -ForegroundColor Cyan
Write-Host "Mode: $Mode" -ForegroundColor Yellow

# Flutter pub get
Write-Host "`n[1/3] flutter pub get..." -ForegroundColor Green
flutter pub get
if ($LASTEXITCODE -ne 0) { Write-Error "pub get failed"; exit 1 }

# flutter_launcher_icons nếu chưa generate
if (Test-Path "assets/images/icon-app-english-me.png") {
    Write-Host "`n[2/3] Generate launcher icons..." -ForegroundColor Green
    dart run flutter_launcher_icons
} else {
    Write-Host "`n[2/3] Skip icon generation (PNG not found)" -ForegroundColor Yellow
}

# Build APK
Write-Host "`n[3/3] Building APK ($Mode)..." -ForegroundColor Green

if ($SplitAbi) {
    flutter build apk --$Mode --split-per-abi
} else {
    flutter build apk --$Mode
}

if ($LASTEXITCODE -ne 0) { Write-Error "Build failed"; exit 1 }

# Tìm file APK output
$outDir = Join-Path $projectDir "build\app\outputs\flutter-apk"
$apks = Get-ChildItem $outDir -Filter "*.apk" | Sort-Object LastWriteTime -Descending

Write-Host "`n=== Build Success ===" -ForegroundColor Cyan
Write-Host "APK files:" -ForegroundColor Green
foreach ($apk in $apks) {
    $sizeMB = [math]::Round($apk.Length / 1MB, 2)
    Write-Host "  $($apk.Name)  ($sizeMB MB)" -ForegroundColor White
    Write-Host "  Path: $($apk.FullName)" -ForegroundColor Gray
}

# Mở thư mục output
Write-Host "`nMở thư mục output..." -ForegroundColor Yellow
explorer $outDir
