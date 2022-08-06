module "public_ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "${var.repository_name}"
  create = true
  create_repository = true
  repository_type = "public"
  repository_read_write_access_arns = ["arn:aws:iam::012345678901:role/terraform"]
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 10 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 10
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  public_repository_catalog_data = {
    description       = "Docker container for some things"
    about_text        = file("${path.module}/files/ABOUT.md")
    usage_text        = file("${path.module}/files/USAGE.md")
    operating_systems = ["Linux"]
    architectures     = ["x86"]
    logo_image_blob   = filebase64("${path.module}/files/eye.png")
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}