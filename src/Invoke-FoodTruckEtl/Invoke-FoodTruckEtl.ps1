<#
.Synopsis
	Downloads a csv file with foodtruck permit information and loads metric definition from a local json file and produces prometheus metrics to alert us to when food truck permits expire. 
.DESCRIPTION
	To force a download of new csv data, manually delete the 'current_foodtruck.csv' file in the specified $tempDownloadLocation 
.PARAMETER DownloadCSVUrl
	if specified, will override the environment specific settings
#>
param(
    $targetEnvironment = 'test'
    ,$promMetricPath = 'D:\metrics'
    ,$logLevel = "Debug"
	,$DownloadCSVUrl
	,$tempDownloadLocation = $env:Temp
)
Import-Module fc_core,fc_log -Force

Set-LogLevel $logLevel

. "$PSScriptRoot/Get-ETLConfig.ps1"
try{
	Set-LogFormattingOptions -PrefixCallingFunction 1 -PrefixTimestamp 1 -PrefixScriptName 1 
    $configuration = Get-ETLConfig -targetEnvironment $targetEnvironment -DownloadCSVUrl $DownloadCSVUrl
    if([string]::IsNullOrEmpty($promMetricPath)){
        $promMetricPath = "$PSScriptRoot\prom"
    }
    $StaticLabels = @("SupportTeam=`"Data`"")
    $metrics = @(
        @{Name="data_instance_start_total"; Description="How many jobs have started";type="gauge"; value="1";labels=$StaticLabels}
    )
    
    $stopwatchTotal = [System.Diagnostics.Stopwatch]::StartNew()

	$csvDownloadPath = "$tempDownloadLocation\current_foodtruck.csv"
	if(-not (Test-Path $csvDownloadPath) -or $reDownload){
		Invoke-WebRequest -Uri $configuration.DownloadCSVUrl -OutFile $csvDownloadPath
	}
	else{
		Write-Log "To download new data, manually delete the file at: $csvDownloadPath and run again" Warning
	}
	

    $stopwatchTotal.Stop()
    Write-Log "Script execution took: $($stopwatchTotal.Elapsed.TotalSeconds) seconds" Debug
    $metrics += @(
            ,@{Name="data_instance_execution_time_seconds"; Description="How long did the job run for.";type="gauge"; value="$($stopwatchTotal.Elapsed.TotalSeconds.ToString())";labels=$StaticLabels}
        )
	Invoke-PrometheusBatchEnding -textFileDir $promMetricPath -SLO_InstanceShouldRunEveryXSeconds 3600 -domain 'data' -metrics $metrics # Should run every 1 hour

	Invoke-UnixLineEndings -directory $promMetricPath
}
catch{
    $ex = $_.Exception
    $line = $_.InvocationInfo.ScriptLineNumber
     if ([string]::IsNullOrEmpty($_.InvocationInfo.ScriptName)) { $scriptName = "[No InvocationInfo Available]" }
     else { $scriptName = Split-Path $_.InvocationInfo.ScriptName -Leaf }
    
     $msg = $ex.Message
     Write-Log "Error in script $scriptName at line $line, error message: $ex" Error
     
}

