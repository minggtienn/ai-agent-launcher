[CmdletBinding()]
param(
  [ValidateSet('Quick', 'PrepareOld', 'PublishUpdate', 'RunUpdate', 'Verify', 'StopServer')]
  [string]$Action = 'Quick',
  [string]$VersionName = '1.2.0',
  [int]$BuildNumber = 3,
  [string]$TrialName = 'test_install_manual',
  [switch]$ForceArtifact
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$feedRoot = Join-Path $repoRoot 'local_update_feed'
$fixtureCurrent = Join-Path $feedRoot 'test_install_legacy_window_manager_1.1.0\current'
$fixtureArchive = Join-Path $feedRoot 'artifacts\launcher-1.1.0-window-manager-fixture.zip'
$manifestPath = Join-Path $feedRoot 'latest.json'
$serverPidPath = Join-Path $feedRoot '.server.pid'
$dartExe = Join-Path $repoRoot '.fvm\flutter_sdk\bin\cache\dart-sdk\bin\dart.exe'

function Assert-LastExitCode([string]$Step) {
  if ($LASTEXITCODE -ne 0) {
    throw "$Step thất bại với exit code $LASTEXITCODE"
  }
}

function Get-TrialRoot {
  if ($TrialName -notmatch '^test_install_[a-zA-Z0-9._-]+$') {
    throw 'TrialName phải bắt đầu bằng test_install_ và không chứa đường dẫn.'
  }
  return Join-Path $feedRoot $TrialName
}

function Write-UpdateManifest(
  [string]$ManifestVersion,
  [string]$DownloadUrl,
  [long]$Size,
  [string]$Sha256,
  [bool]$Mandatory,
  [string]$Note
) {
  $manifest = [ordered]@{
    version = $ManifestVersion
    mandatory = $Mandatory
    downloadUrl = $DownloadUrl
    size = $Size
    sha256 = $Sha256.ToLowerInvariant()
    signature = ''
    entryExecutable = 'ai_agent_launcher.exe'
    releaseNotes = @($Note)
  }
  $manifest | ConvertTo-Json -Depth 4 | Set-Content $manifestPath -Encoding utf8
}

function Start-LocalServer {
  try {
    $null = Invoke-WebRequest -UseBasicParsing 'http://127.0.0.1:8080/latest.json' -TimeoutSec 2
    Write-Host 'Server local đã chạy trên cổng 8080.' -ForegroundColor Green
    return
  } catch {
    # Chưa có server; tiếp tục khởi động bên dưới.
  }

  if (-not (Test-Path $dartExe)) {
    throw "Không tìm thấy Dart của FVM: $dartExe"
  }
  $stdout = Join-Path $feedRoot 'quick-server.stdout.log'
  $stderr = Join-Path $feedRoot 'quick-server.stderr.log'
  $process = Start-Process -FilePath $dartExe `
    -ArgumentList 'run', 'server.dart' `
    -WorkingDirectory $feedRoot `
    -RedirectStandardOutput $stdout `
    -RedirectStandardError $stderr `
    -WindowStyle Hidden `
    -PassThru
  $process.Id | Set-Content $serverPidPath -Encoding ascii

  for ($attempt = 0; $attempt -lt 20; $attempt++) {
    Start-Sleep -Milliseconds 250
    try {
      $null = Invoke-WebRequest -UseBasicParsing 'http://127.0.0.1:8080/latest.json' -TimeoutSec 2
      Write-Host "Đã mở server local, PID $($process.Id)." -ForegroundColor Green
      return
    } catch {
      # Chờ server sẵn sàng.
    }
  }
  throw "Server không sẵn sàng. Xem log: $stderr"
}

function Stop-LocalServer {
  if (-not (Test-Path $serverPidPath)) {
    Write-Host 'Không có PID server do script quản lý.' -ForegroundColor Yellow
    return
  }
  $serverPid = [int](Get-Content $serverPidPath -Raw)
  $process = Get-Process -Id $serverPid -ErrorAction SilentlyContinue
  if ($null -ne $process -and $process.ProcessName -eq 'dart') {
    Stop-Process -Id $serverPid -Force
    Write-Host "Đã dừng server PID $serverPid." -ForegroundColor Green
  }
  Remove-Item -LiteralPath $serverPidPath -Force
}

function New-TrialCopy {
  $trialRoot = Get-TrialRoot
  if (Test-Path $trialRoot) {
    throw "Thư mục trial đã tồn tại: $trialRoot. Hãy chọn TrialName mới."
  }
  if (-not (Test-Path (Join-Path $fixtureCurrent 'ai_agent_launcher.exe'))) {
    throw "Fixture bản cũ không tồn tại: $fixtureCurrent"
  }
  New-Item -ItemType Directory -Path $trialRoot | Out-Null
  Copy-Item -LiteralPath $fixtureCurrent -Destination (Join-Path $trialRoot 'current') -Recurse
  Write-Host "Đã tạo trial: $trialRoot" -ForegroundColor Green
  return $trialRoot
}

function Publish-NewVersion {
  $release = Join-Path $repoRoot 'build\windows\x64\runner\Release'
  $zip = Join-Path $feedRoot "artifacts\launcher-$VersionName.zip"
  if (Test-Path $zip) {
    if (-not $ForceArtifact) {
      throw "Artifact đã tồn tại: $zip. Dùng -ForceArtifact để tạo lại đúng file này."
    }
    Remove-Item -LiteralPath $zip -Force
  }

  Push-Location $repoRoot
  try {
    & fvm flutter clean
    Assert-LastExitCode 'flutter clean'
    & fvm flutter pub get
    Assert-LastExitCode 'flutter pub get'
    & fvm flutter build windows --release `
      "--build-name=$VersionName" `
      "--build-number=$BuildNumber" `
      '--dart-define=LAUNCHER_UPDATE_MANIFEST_URL=http://127.0.0.1:8080/latest.json' `
      '--dart-define=ALLOW_UNSIGNED_UPDATES=true'
    Assert-LastExitCode 'Build Windows Release'
  } finally {
    Pop-Location
  }

  $newExe = Join-Path $release 'ai_agent_launcher.exe'
  if (-not (Test-Path $newExe)) { throw "Thiếu executable mới: $newExe" }
  if (Test-Path (Join-Path $release 'window_manager_plugin.dll')) {
    throw 'Release mới còn DLL window_manager cũ; không tạo manifest.'
  }
  Compress-Archive -Path (Join-Path $release '*') -DestinationPath $zip -CompressionLevel Optimal
  $zipInfo = Get-Item $zip
  $zipHash = (Get-FileHash $zip -Algorithm SHA256).Hash.ToLowerInvariant()
  Write-UpdateManifest $VersionName `
    "http://127.0.0.1:8080/artifacts/launcher-$VersionName.zip" `
    $zipInfo.Length $zipHash $true "Kiểm thử update launcher lên $VersionName+$BuildNumber"
  Write-Host "Đã công bố $VersionName+$BuildNumber" -ForegroundColor Green
  Write-Host "ZIP: $zip"
  Write-Host "Size: $($zipInfo.Length)"
  Write-Host "SHA-256: $zipHash"
}

function Prepare-OldLauncher {
  $trialRoot = New-TrialCopy
  $fixtureInfo = Get-Item $fixtureArchive
  $fixtureHash = (Get-FileHash $fixtureArchive -Algorithm SHA256).Hash.ToLowerInvariant()
  Write-UpdateManifest '1.1.0' `
    'http://127.0.0.1:8080/artifacts/launcher-1.1.0-window-manager-fixture.zip' `
    $fixtureInfo.Length $fixtureHash $true 'Chưa có phiên bản mới'
  Start-LocalServer
  $oldExe = Join-Path $trialRoot 'current\ai_agent_launcher.exe'
  Start-Process -FilePath $oldExe -WorkingDirectory (Split-Path $oldExe) | Out-Null
  Write-Host 'Launcher cũ đang dùng manifest cùng version nên sẽ vào màn hình đăng nhập.' -ForegroundColor Cyan
  Write-Host 'Hãy xem xong và đóng launcher trước khi chạy PublishUpdate.' -ForegroundColor Cyan
}

function Run-TrialUpdate {
  $trialRoot = Get-TrialRoot
  $oldExe = Join-Path $trialRoot 'current\ai_agent_launcher.exe'
  if (-not (Test-Path $oldExe)) { throw "Không tìm thấy trial: $oldExe" }
  $running = Get-Process ai_agent_launcher -ErrorAction SilentlyContinue |
    Where-Object { $_.Path -eq $oldExe }
  if ($running) { throw 'Launcher trial vẫn đang chạy. Hãy đóng nó rồi chạy lại RunUpdate.' }
  Start-LocalServer
  Start-Process -FilePath $oldExe -WorkingDirectory (Split-Path $oldExe) | Out-Null
  Write-Host "Đã mở launcher trial để update: $oldExe" -ForegroundColor Green
}

function Test-UpdateResult {
  $trialRoot = Get-TrialRoot
  $currentExe = Join-Path $trialRoot 'current\ai_agent_launcher.exe'
  $backup = Get-ChildItem $trialRoot -Directory -Filter 'current.backup-*' -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if (-not (Test-Path $currentExe)) { throw 'Không tìm thấy executable current.' }
  $currentVersion = (Get-Item $currentExe).VersionInfo.ProductVersion
  $backupVersion = if ($backup) {
    (Get-Item (Join-Path $backup.FullName 'ai_agent_launcher.exe')).VersionInfo.ProductVersion
  } else { 'không có' }
  $partFiles = @(Get-ChildItem (Join-Path $trialRoot '.launcher-update') -Filter '*.zip.part' -ErrorAction SilentlyContinue)
  $passed = $currentVersion.StartsWith("$VersionName+") -and $backupVersion.StartsWith('1.1.0+') -and $partFiles.Count -eq 0
  [pscustomobject]@{
    KetQua = if ($passed) { 'PASS' } else { 'FAIL' }
    VersionHienTai = $currentVersion
    VersionBackup = $backupVersion
    DllWindowManagerTrongBanMoi = Test-Path (Join-Path $trialRoot 'current\window_manager_plugin.dll')
    SoFileTaiDo = $partFiles.Count
    ThuMucTrial = $trialRoot
  } | Format-List
  if (-not $passed) { exit 1 }
}

switch ($Action) {
  'PrepareOld' { Prepare-OldLauncher }
  'PublishUpdate' { Publish-NewVersion }
  'RunUpdate' { Run-TrialUpdate }
  'Verify' { Test-UpdateResult }
  'StopServer' { Stop-LocalServer }
  'Quick' {
    if ($TrialName -eq 'test_install_manual') {
      $TrialName = 'test_install_quick_' + (Get-Date -Format 'yyyyMMdd_HHmmss')
    }
    Publish-NewVersion
    $null = New-TrialCopy
    Start-LocalServer
    Run-TrialUpdate
    Write-Host 'Đang chờ updater hoàn tất...' -ForegroundColor Cyan
    $deadline = (Get-Date).AddSeconds(120)
    do {
      Start-Sleep -Seconds 2
      $exe = Join-Path (Get-TrialRoot) 'current\ai_agent_launcher.exe'
      $version = if (Test-Path $exe) { (Get-Item $exe).VersionInfo.ProductVersion } else { '' }
    } while (-not $version.StartsWith("$VersionName+") -and (Get-Date) -lt $deadline)
    Test-UpdateResult
  }
}

