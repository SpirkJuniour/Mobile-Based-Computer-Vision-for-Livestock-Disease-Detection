param(
	[int]$IntervalSeconds = 60
)

$ErrorActionPreference = "SilentlyContinue"
Set-StrictMode -Version Latest

$root = "D:/mifugo_care"
$runsDetect = Join-Path $root "ml/runs/detect"
$runsClassify = Join-Path $root "ml/runs/classify"
$logFile = Join-Path $root "ml/monitor.log"

function Get-LatestResultsCsv($dir) {
	if (-not (Test-Path $dir)) { return $null }
	$csvs = Get-ChildItem -Path $dir -Filter "results.csv" -Recurse -File | Sort-Object LastWriteTime -Descending
	if ($csvs -and $csvs.Count -gt 0) { return $csvs[0].FullName } else { return $null }
}

function Read-LastLine($filePath) {
	if (-not (Test-Path $filePath)) { return $null }
	$line = Get-Content -Path $filePath -Tail 1 -ErrorAction SilentlyContinue
	return $line
}

function Write-Log($message) {
	$ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
	"$ts`t$message" | Out-File -FilePath $logFile -Append -Encoding utf8
}

Write-Log "Monitor started. Interval: $IntervalSeconds s"

while ($true) {
	$detCsv = Get-LatestResultsCsv $runsDetect
	$clsCsv = Get-LatestResultsCsv $runsClassify

	if ($detCsv) {
		$last = Read-LastLine $detCsv
		Write-Log "detect: $(Split-Path $detCsv -Parent | Split-Path -Leaf) :: $last"
	} else {
		Write-Log "detect: no results.csv yet"
	}

	if ($clsCsv) {
		$last = Read-LastLine $clsCsv
		Write-Log "classify: $(Split-Path $clsCsv -Parent | Split-Path -Leaf) :: $last"
	} else {
		Write-Log "classify: no results.csv yet"
	}

	Start-Sleep -Seconds $IntervalSeconds
}

