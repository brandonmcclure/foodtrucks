Describe 'local Get-ETLConfig'{

	BeforeEach{
	  Remove-Module "$PSScriptRoot/Get-ETLConfig.ps1" -Force -ErrorAction Ignore | Out-Null
	  . "$PSScriptRoot/Get-ETLConfig.ps1"
	}
  
	context "general"{
	  it "Nothing in, nothing out"{
		Get-ETLConfig | should -be $null
	  }
	}
  
	context "DownloadCSVUrl"{
	  it "ImportFilePath if null/empty and TargetEnvironment is test will default to https://data.sfgov.org/api/views/rqzj-sfat/rows.csv"{
		$envConfig = Get-ETLConfig -targetEnvironment "test"
		$envConfig.DownloadCSVUrl | should -be "https://data.sfgov.org/api/views/rqzj-sfat/rows.csv"
	  }
  
	  it "DownloadCSVUrl if null/empty and TargetEnvironment is production will default to https://data.sfgov.org/api/views/rqzj-sfat/rows.csv"{
		$envConfig = Get-ETLConfig -targetEnvironment "production"
		$envConfig.DownloadCSVUrl | should -be "https://data.sfgov.org/api/views/rqzj-sfat/rows.csv"
	  }

	}
  
	
  }