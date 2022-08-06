 terraform {
	backend "s3" {
    bucket                      = "terraform"
    key                         = "aws/test/terraform.tfstate"
    endpoint                    = "https://minio.mcd.com"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
    access_key                  = ""
    secret_key                  = ""
    region                      = "us-east-1"
  }
 }
provider "aws" {
  region = "us-east-1"
  profile = "default"
}

module ecr_prometheus {
	source = "./ecr"
	repository_name = "mcfood_prometheus"
}
module ecr_grafana {
	source = "./ecr"
	repository_name = "mcfood_grafana"
}
module ecr_node_exporter {
	source = "./ecr"
	repository_name = "mcfood_node_exporter"
}
module ecr_pws {
	source = "./ecr"
	repository_name = "mcfood_pwsh"
}