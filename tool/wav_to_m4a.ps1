# يحوّل مقاطع صوت المرشد من WAV (ناتج tool/generate_meditation_voice.dart) إلى m4a (AAC أحادي)
# ويضعها في assets/meditation/voice/<session>/<clip>.m4a، حيث يبحث عنها التطبيق.
# يستعمل مرمّز Windows المدمج (Media Foundation)، فلا يحتاج تثبيت أي برنامج.
# يعمل في Windows PowerShell 5.1 فقط (لا pwsh)، لأن واجهات WinRT غير متاحة في pwsh:
#   powershell -NoProfile -ExecutionPolicy Bypass -File tool/wav_to_m4a.ps1
param(
  [string]$InputDir = (Join-Path $PSScriptRoot '..\build\meditation_voice\wav'),
  [string]$OutputDir = (Join-Path $PSScriptRoot '..\assets\meditation\voice'),
  # مرمّز AAC في Windows يقبل 96 أو 128 أو 160 أو 192 كيلوبت فقط. 96 يكفي للكلام.
  [int]$Bitrate = 96000
)
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Runtime.WindowsRuntime
$null = [Windows.Storage.StorageFile, Windows.Storage, ContentType = WindowsRuntime]
$null = [Windows.Storage.StorageFolder, Windows.Storage, ContentType = WindowsRuntime]
$null = [Windows.Media.Transcoding.MediaTranscoder, Windows.Media.Transcoding, ContentType = WindowsRuntime]
$null = [Windows.Media.MediaProperties.MediaEncodingProfile, Windows.Media.MediaProperties, ContentType = WindowsRuntime]

$extensions = [System.WindowsRuntimeSystemExtensions].GetMethods()
$asTaskOperation = $extensions | Where-Object {
  $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and
  $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'
} | Select-Object -First 1
$asTaskProgress = $extensions | Where-Object {
  $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and
  $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncActionWithProgress`1'
} | Select-Object -First 1

function Wait-Operation($operation, [type]$resultType) {
  $task = $asTaskOperation.MakeGenericMethod($resultType).Invoke($null, @($operation))
  $task.Wait(-1) | Out-Null
  return $task.Result
}

function Convert-Clip([string]$wavPath, [string]$m4aPath) {
  $folderPath = Split-Path -Parent $m4aPath
  New-Item -ItemType Directory -Force -Path $folderPath | Out-Null
  $source = Wait-Operation ([Windows.Storage.StorageFile]::GetFileFromPathAsync($wavPath)) ([Windows.Storage.StorageFile])
  $folder = Wait-Operation ([Windows.Storage.StorageFolder]::GetFolderFromPathAsync($folderPath)) ([Windows.Storage.StorageFolder])
  $target = Wait-Operation ($folder.CreateFileAsync((Split-Path -Leaf $m4aPath), [Windows.Storage.CreationCollisionOption]::ReplaceExisting)) ([Windows.Storage.StorageFile])

  $encoding = [Windows.Media.MediaProperties.MediaEncodingProfile]::CreateM4a([Windows.Media.MediaProperties.AudioEncodingQuality]::Medium)
  $encoding.Audio = [Windows.Media.MediaProperties.AudioEncodingProperties]::CreateAac(44100, 1, $Bitrate)

  $transcoder = New-Object Windows.Media.Transcoding.MediaTranscoder
  $prepared = Wait-Operation ($transcoder.PrepareFileTranscodeAsync($source, $target, $encoding)) ([Windows.Media.Transcoding.PrepareTranscodeResult])
  if (-not $prepared.CanTranscode) { throw "Cannot convert $wavPath ($($prepared.FailureReason))" }
  $task = $asTaskProgress.MakeGenericMethod([double]).Invoke($null, @($prepared.TranscodeAsync()))
  $task.Wait(-1) | Out-Null
}

$InputDir = (Resolve-Path $InputDir).Path
$OutputDir = [System.IO.Path]::GetFullPath($OutputDir)
# مستوى واحد فقط: <InputDir>/<session>/<clip>.wav. مجلدات اللغات الأخرى (wav/en/...) تُحوَّل
# بأمر منفصل إلى assets/meditation/voice/en حتى لا يدخل صوت إنجليزي مجلدات الجلسات العربية.
$wavs = Get-ChildItem -Path $InputDir -Filter *.wav -Recurse |
  Where-Object { (Split-Path -Parent $_.DirectoryName) -eq $InputDir } |
  Sort-Object FullName
if ($wavs.Count -eq 0) { Write-Output "No WAV files in $InputDir"; exit 1 }

$total = 0
foreach ($wav in $wavs) {
  $session = Split-Path -Leaf $wav.DirectoryName
  $m4a = Join-Path (Join-Path $OutputDir $session) ($wav.BaseName + '.m4a')
  Convert-Clip $wav.FullName $m4a
  $size = (Get-Item $m4a).Length
  $total += $size
  Write-Output ("{0}/{1}.m4a  {2:N0} KB" -f $session, $wav.BaseName, ($size / 1KB))
}
Write-Output ("Done. {0} file(s), {1:N1} MB in all." -f $wavs.Count, ($total / 1MB))
