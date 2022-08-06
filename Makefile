ifeq ($(OS),Windows_NT)
	SHELL := pwsh.exe
else
	SHELL := pwsh
endif

.SHELLFLAGS := -NoProfile -Command

REGISTRY_NAME := registry.mcd.com/
REPOSITORY_NAME :=
TAG := :latest

all: build run compose_down compose_up

getcommitid:
	$(eval COMMITID = $(shell git log -1 --pretty=format:'%H'))

getbranchname:
	$(eval BRANCH_NAME = $(shell (git branch --show-current ) -replace '/','.'))

build: test getcommitid getbranchname
	$(eval IMAGE_NAME = mcfood_prometheus)
	docker build -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME)_$(COMMITID) ./src/Docker/Prometheus
	$(eval IMAGE_NAME = mcfood_node_exporter)
	docker build -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME)_$(COMMITID) ./src/Docker/node_exporter
	$(eval IMAGE_NAME = mcfood_grafana)
	docker build -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME)_$(COMMITID) ./src/Docker/grafana
	$(eval IMAGE_NAME = mcfood_pwsh)
	docker build -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME)_$(COMMITID) ./src/Invoke-FoodTruckEtl

run_it:
	docker run -it $(REGISTRY_NAME)mcfood_pwsh:latest 
run:
	docker run -v $${PWD}/mnt/prom:/mnt/prom $(REGISTRY_NAME)mcfood_pwsh:latest pwsh -F /src/Invoke-FoodTruckEtl.ps1 -promMetricPath /mnt/prom

compose_up:
	@docker-compose -f docker-compose.yaml up -d

compose_down:
	@docker compose -f Docker-compose.yaml down

clean:
	@docker-compose -f docker-compose.yaml down -v --remove-orphans

pwsh_test:
	. "$$env:USERPROFILE\.vscode\extensions\ms-vscode.powershell-2022.7.2\modules\PowerShellEditorServices\InvokePesterStub.ps1" -ScriptPath 'e:\Git\brandonmcclure\foodtrucks\src\Invoke-FoodTruckEtl\Invoke-FoodTruckEtl.Tests.ps1' -LineNumber 1 -Output 'FromPreference'

prom_lint:
	docker run --rm --entrypoint /bin/promtool -v $${PWD}/src/docker/prometheus/:/mnt/:ro $(REGISTRY_NAME)mcfood_prometheus:latest check config /mnt/prometheus.yml

test: prom_lint pwsh_test