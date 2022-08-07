ifeq ($(OS),Windows_NT)
	SHELL := pwsh.exe
else
	SHELL := pwsh
endif

.SHELLFLAGS := -NoProfile -Command

REGISTRY_NAME := public.ecr.aws/z1d8m1n4/
REPOSITORY_NAME :=
TAG := :latest
PUBLISH_TAG := :main

all: prom_lint build run compose_down compose_up

getcommitid:
	$(eval COMMITID = $(shell git log -1 --pretty=format:'%H'))

getbranchname:
	$(eval BRANCH_NAME = $(shell (git branch --show-current ) -replace '/','.'))

build: getcommitid getbranchname
	$(eval IMAGE_NAME = mcfood_prometheus)
	docker build -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME)_$(COMMITID) ./src/docker/prometheus
	$(eval IMAGE_NAME = mcfood_node_exporter)
	docker build -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME)_$(COMMITID) ./src/docker/node_exporter
	$(eval IMAGE_NAME = mcfood_grafana)
	docker build -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME)_$(COMMITID) ./src/docker/grafana
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

tf_destroy:
	cd src/tf; terraform destroy 
tf_init:
	cd src/tf; terraform init
tf_plan: tf_init getcommitid getbranchname
	cd src/tf; terraform plan -out "bin/$(BRANCH_NAME)_$(COMMITID).tfplan"
tf_apply: tf_plan
	cd src/tf; terraform apply "bin/$(BRANCH_NAME)_$(COMMITID).tfplan"

publish:
	$(eval IMAGE_NAME = mcfood_prometheus)
	 aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/z1d8m1n4; docker push $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(PUBLISH_TAG)
	$(eval IMAGE_NAME = mcfood_node_exporter)
	 aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/z1d8m1n4; docker push $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(PUBLISH_TAG)
	$(eval IMAGE_NAME = mcfood_grafana)
	 aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/z1d8m1n4; docker push $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(PUBLISH_TAG)
	$(eval IMAGE_NAME = mcfood_pwsh)
	 aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/z1d8m1n4; docker push $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(PUBLISH_TAG)
