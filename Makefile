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
CS_SA_PASSWORD := we@kPassw0rd

.PHONY: all test lint clean publish build
all: prom_lint build compose_down compose_up

getcommitid:
	$(eval COMMITID = $(shell git log -1 --pretty=format:'%H'))

getbranchname:
	$(eval BRANCH_NAME = $(shell (git branch --show-current ) -replace '/','.'))

build: getcommitid getbranchname build_prometheus build_nodeexporter build_grafana build_pwsh build_sql
build_prometheus:
	$(eval IMAGE_NAME = mcfood_prometheus)
	docker build -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME)_$(COMMITID) ./src/docker/prometheus
build_nodeexporter:
	$(eval IMAGE_NAME = mcfood_node_exporter)
	docker build -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME)_$(COMMITID) ./src/docker/node_exporter
build_grafana:
	$(eval IMAGE_NAME = mcfood_grafana)
	docker build -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME)_$(COMMITID) ./src/docker/grafana
build_pwsh:
	$(eval IMAGE_NAME = mcfood_pwsh)
	docker build -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME)_$(COMMITID) ./src/Invoke-FoodTruckEtl
build_sql:
	$(eval IMAGE_NAME = mcfood_sql)
	docker build --build-arg CD_SA_PASSWORD=$(CS_SA_PASSWORD) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME)_$(COMMITID) ./src/docker/mssql
	

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

publish: publish_prometheus publish_nodeexporter publish_grafana publish_pwsh

publish_prometheus:
	$(eval IMAGE_NAME = mcfood_prometheus)
	 aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/z1d8m1n4; docker push $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(PUBLISH_TAG)
publish_nodeexporter:
	$(eval IMAGE_NAME = mcfood_node_exporter)
	 aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/z1d8m1n4; docker push $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(PUBLISH_TAG)
publish_grafana:
	$(eval IMAGE_NAME = mcfood_grafana)
	 aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/z1d8m1n4; docker push $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(PUBLISH_TAG)
publish_pwsh:
	$(eval IMAGE_NAME = mcfood_pwsh)
	 aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/z1d8m1n4; docker push $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(PUBLISH_TAG)

build_presentation:
	cd docs; docker run --workdir /mnt -v $${pwd}:/mnt pandoc/latex '/mnt/presentation.md' --embed-resources --standalone -t beamer -o /mnt/presentation.pdf;

lint: lint_mega

lint_mega:
	docker run -v $${PWD}:/tmp/lint oxsecurity/megalinter:v6
lint_goodcheck:
	docker run -t --rm -v $${PWD}:/work sider/goodcheck check
lint_goodcheck_test:
	docker run -t --rm -v $${PWD}:/work sider/goodcheck test
lint_makefile:
	docker run -v $${PWD}:/tmp/lint -e ENABLE_LINTERS=MAKEFILE_CHECKMAKE oxsecurity/megalinter-ci_light:v6.10.0