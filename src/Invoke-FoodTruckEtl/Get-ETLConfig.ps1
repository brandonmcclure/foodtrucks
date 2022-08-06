function Get-ETLConfig{
	param($targetEnvironment,$DownloadCSVUrl = "")
  
	if([string]::IsNullOrEmpty($targetEnvironment)){
	  return;
	}
  
	$outObj = New-Object PSObject -Property @{
		DownloadCSVUrl = $DownloadCSVUrl
	 }

	 if ($TargetEnvironment -eq 'test') {
		if([string]::IsNullOrEmpty($outObj.DownloadCSVUrl)){
		  $outObj.DownloadCSVUrl = "https://data.sfgov.org/api/views/rqzj-sfat/rows.csv"
		}
	  }
	
	  elseif ($TargetEnvironment -eq "production") {
		if([string]::IsNullOrEmpty($outObj.DownloadCSVUrl)){
			$outObj.DownloadCSVUrl = "https://data.sfgov.org/api/views/rqzj-sfat/rows.csv"
		  }
	
	  }
	
	  else {
		Write-Log "Error setting the ETLConfig with $targetEnvironment" Error -ErrorAction Stop
	  }
  
	Write-Output $outobj
  }