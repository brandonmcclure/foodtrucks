# Journal

# 8:30

I use the pwsh shell in my makefile to make it cross platform :-)
```
ifeq ($(OS),Windows_NT)
	SHELL := pwsh.exe
else
	SHELL := pwsh
endif

.SHELLFLAGS := -NoProfile -Command
```

We build the docker images, and compose them up. You can see the node_exporter metrics at `http://localhost:9100/metrics`

`Invoke-WebRequest -Uri http://localhost:9100/metrics | select -ExpandProperty RawContent`


Access Grafana at: http://localhost:3000/login (admin,admin)

Prometheus at: http://localhost:9090/targets?search=

# 9:00

Start the pwsh script. I want to setup a test framework quick so I can use that as a baseline for all my development. The `Get-ETLConfig.ps1` is a abstraction to make it very easy to codify and the confirm proper environment settings via testing. 

# 9:30

Pwsh testing is working well, working on the etl portion of this. Started the docker image that the pwsh will run in. 

I used a private image `bmcclure89/fc_powershell:main` for the pwsh due to it's availability to me. For a team/production setting this would be a private base image. 

# 10:00 

We need to test that the textfile is not having any issues, this [graph link](http://localhost:9090/graph?g0.expr=node_textfile_scrape_error&g0.tab=1&g0.stacked=0&g0.show_exemplars=0&g0.range_input=1h) should show you. 

I would like to document the Prometheus relabels and labeling strategy more. 

Create a dashboard. new state viz to show that the text file is working
![picture 1](../.images/b3e3dfe48cc16e13f6de429f2ad9fadc37f3eb3e498c83c5a8b5ec20f3112cc5.png)  

also added a viz to show the time since the last run via expresison: `time() - max(data_data_instance_last_complete_epoch_seconds_diff) by(script_name)`

You need gitlfs now because I added images. If I had more time I would add actions/make target to test if the files actually are lfs. 

# 10:30

Powershell to metrics

banged my ahead against a prometheus file issue. A tab snuck in. Implemented `prom_lint` target to warn me before I deploy. 

Updated the grafana dashboard with some viz with expression: `min(location_expiration_epoch{Applicant=~"$Applicant"}) by (Applicant) - time()`

There is also a variable to let us pick our favorite food trucks to show us when their permit expires. 
![picture 2](../.images/249e5ba0d55a835fe688a1b22c478377caf1bb17083e21cc572828c0e261ae75.png)  

There is not alot of discrepancy in this expiration data. This data will become more rich as we run the job over time, and collect the changeing data/metrics. 

Next steps. I would love to stand up a RDS instance on AWS via terraform and load this data into that for persistence outside of prometheus. That is not doable in 30 minutes, so I will instead setup AWS ECR registries for the docker images. (And github build actions for the whole thing?)

# 11:00

I wrote a simple module for the ECR deployment to attempt to reuse code. 

I used my hosted minio instance as a backend for the state file. You will need to remove the `Backend` tag in the main.tf file, or set it up with your own S3 configuration. 

Deploy ECR and publish our images via `makefile`. It is hardcoded to only publish `:latest` tag via a variable `PUBLISH_TAG` in the makefile. Update that variable and run `make publish` again to publish different tags 

I could not figure out how to create a single repository with multiple registries, which is why there are separate cloud resources for each image. I also could not figure out IAM enough to be able to finish anything, so this is public access. 

There are no special secrets in these images, and having them be public also helps others pull/test out this project.

# Done

## Immediate thoughts

I enjoyed this challenge. Not having lint tools tripped me up when writing the prometheus config/alert rules. I want to test this out on another computer, because if I did this right then the only dependency to run this is docker. 

I was hoping to get some github actions built out and demonstrate how I would use them to build a gated CI to give me feedback that my changes will not break anything. I am hopeful that the Makefile is expressive enough to document how that CI process should look. 