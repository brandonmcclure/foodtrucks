Describe 'Invoke-FoodTruckEtl' {
	BeforeAll{
		$testDownloadPath = "TestDrive:\download"
        if(-not(Test-Path $testDownloadPath)){New-Item $testDownloadPath -Force -ItemType Directory}
		$testDownloadEmptyPath = "TestDrive:\download_empty"
        if(-not(Test-Path $testDownloadEmptyPath)){New-Item $testDownloadEmptyPath -Force -ItemType Directory}

		Set-Content -value 'locationid,Applicant,FacilityType,cnn,LocationDescription,Address,blocklot,block,lot,permit,Status,FoodItems,X,Y,Latitude,Longitude,Schedule,dayshours,NOISent,Approved,Received,PriorPermit,ExpirationDate,Location,Fire Prevention Districts,Police Districts,Supervisor Districts,Zip Codes,Neighborhoods (old)
		1571753,The Geez Freeze,Truck,887000,18TH ST: DOLORES ST to CHURCH ST (3700 - 3799),3750 18TH ST,3579006,3579,006,21MFF-00015,APPROVED,Snow Cones: Soft Serve Ice Cream & Frozen Virgin Daiquiris,6004575.869,2105666.974,37.76201920035647,-122.42730642251331,http://bsm.sfdpw.org/PermitsTracker/reports/report.aspx?title=schedule&report=rptSchedule&params=permit=21MFF-00015&ExportPDF=1&Filename=21MFF-00015_schedule.pdf,,,01/28/2022 12:00:00 AM,20210315,0,11/15/2022 12:00:00 AM,"(37.76201920035647, -122.42730642251331)",8,4,5,28862,3
		1569152,Datam SF LLC dba Anzu To You,Truck,12463000,TAYLOR ST: BAY ST to NORTH POINT ST (2500 - 2599),2535 TAYLOR ST,0029007,0029,007,21MFF-00106,APPROVED,Asian Fusion - Japanese Sandwiches/Sliders/Misubi,6008186.35457,2121568.81783,37.805885350100986,-122.41594524663745,http://bsm.sfdpw.org/PermitsTracker/reports/report.aspx?title=schedule&report=rptSchedule&params=permit=21MFF-00106&ExportPDF=1&Filename=21MFF-00106_schedule.pdf,,,11/05/2021 12:00:00 AM,20211105,0,11/15/2022 12:00:00 AM,"(37.805885350100986, -122.41594524663745)",5,1,10,308,23
		1569145,Casita Vegana,Truck,7553000,JOHN MUIR DR: LAKE MERCED BLVD to SKYLINE BLVD (200 - 699),Assessors Block 7283/Lot004,7283004,7283,004,21MFF-00105,APPROVED,Coffee: Vegan Pastries: Vegan Hot Dogs: Vegan Tamales: Te: Vegan Shakes,5985417.15,2091453.145,37.72188970870838,-122.4925212449949,http://bsm.sfdpw.org/PermitsTracker/reports/report.aspx?title=schedule&report=rptSchedule&params=permit=21MFF-00105&ExportPDF=1&Filename=21MFF-00105_schedule.pdf,,,11/05/2021 12:00:00 AM,20211105,0,11/15/2022 12:00:00 AM,"(37.72188970870838, -122.4925212449949)",1,8,4,64,14' -Path "$testDownloadPath\current_foodtruck.csv"
	}
	context "general"{
		it "If no file exists at $testDownloadEmptyPath, download one"{
			mock Invoke-PrometheusBatchEnding {return $null}
			mock Invoke-UnixLineEndings {return $null} 
			mock Invoke-WebRequest {return $null} -Verifiable
			. "$PSScriptRoot/Invoke-FoodTruckEtl.ps1" -tempDownloadLocation $testDownloadEmptyPath | Should -Invoke "Invoke-WebRequest" -Exactly 1
		}
		it "If there is already a file downloaded, don't do so again"{
			mock Invoke-PrometheusBatchEnding {return $null}
			mock Invoke-UnixLineEndings {return $null} 
			mock Invoke-WebRequest {return $null} -Verifiable
			. "$PSScriptRoot/Invoke-FoodTruckEtl.ps1" -tempDownloadLocation $testDownloadPath | Should -Invoke "Invoke-WebRequest" -Exactly 0
		}
	  }
}
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