$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$swfPath = Join-Path $projectRoot "source\Machinations.swf"
$ffdecRoot = Join-Path $projectRoot "tools\ffdec\app-26.0.0"
$ffdecBat = Join-Path $ffdecRoot "ffdec.bat"
$outputRoot = Join-Path $projectRoot "source\swf_extract"
$exportRoot = Join-Path $outputRoot "ffdec_export"
$dumpSwfPath = Join-Path $outputRoot "dump_swf.txt"
$dumpAs3Path = Join-Path $outputRoot "dump_as3.txt"
$xmlPath = Join-Path $outputRoot "machinations.xml"

if (!(Test-Path $swfPath)) {
	throw "SWF not found: $swfPath"
}

if (!(Test-Path $ffdecBat)) {
	throw "FFDec CLI not found: $ffdecBat"
}

New-Item -ItemType Directory -Force -Path $outputRoot | Out-Null
if (Test-Path $exportRoot) {
	Remove-Item -Recurse -Force $exportRoot
}
New-Item -ItemType Directory -Force -Path $exportRoot | Out-Null

Push-Location $ffdecRoot
try {
	& .\ffdec.bat -cli -dumpSWF "..\..\..\source\Machinations.swf" | Set-Content $dumpSwfPath
	& .\ffdec.bat -cli -dumpAS3 "..\..\..\source\Machinations.swf" | Set-Content $dumpAs3Path
	& .\ffdec.bat -cli -onerror ignore -timeout 120 -exportTimeout 900 -export all "..\..\..\source\swf_extract\ffdec_export" "..\..\..\source\Machinations.swf"
	& .\ffdec.bat -cli -swf2xml "..\..\..\source\Machinations.swf" "..\..\..\source\swf_extract\machinations.xml"
}
finally {
	Pop-Location
}

Write-Host "SWF extraction finished."
Write-Host "SWF dump: $dumpSwfPath"
Write-Host "AS3 dump: $dumpAs3Path"
Write-Host "Export root: $exportRoot"
Write-Host "XML: $xmlPath"
