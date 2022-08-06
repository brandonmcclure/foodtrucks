# Journal

# 1

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

# 2

Start the pwsh script. I want to setup a test framework quick so I can use that as a baseline for all my development. The `Get-ETLConfig.ps1` is a abstraction to make it very easy to codify and the confirm proper environment settings via testing. 

# 3

Pwsh testing is working well, working on the etl portion of this