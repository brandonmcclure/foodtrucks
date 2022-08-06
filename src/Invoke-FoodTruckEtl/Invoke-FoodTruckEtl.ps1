param(
    $targetEnvironment = 'production'
    ,$promMetricPath = 'D:\metrics'
    ,$logLevel = "Debug"
	,$DownloadCSVUrl
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

