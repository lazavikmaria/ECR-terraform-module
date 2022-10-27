module "ecr_repository" {
  source = "../"

  repository_name                   = "trm_ecr"
  repository_image_tag_mutability   = "MUTABLE"
  repository_force_delete           = true
  scan_on_push                      = true
  repository_read_write_access_arns = ["arn:aws:iam::343443274786:role/terraform"]

  lifecycle_policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire untagged images older than 14 days",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["dev","devops"],
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2,
            "description": "Keep last 30 dev images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["prod"],
                "countType": "imageCountMoreThan",
                "countNumber": 30
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF

  ### --- Providers variables --- ###
  aws_region          = "us-east-2"
  owner               = ""
  value_stream        = "Information Technology"
  product             = ""
  component           = "Content Portal"
  environment         = "Personal"
  data_classification = "Internal"
  created_using       = "Terraform"
  source_code         = ""

}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_iam_policy_document" "registry" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = [
      "ecr:ReplicateImage",
    ]

    resources = [
      module.ecr_repository.repository_arn,
    ]
  }
}

output "repository_name" {
  description = "The name of the repository."
  value       = module.ecr_repository.repository_name
}

output "registry_id" {
  description = "The registry ID where the repository was created."
  value       = module.ecr_repository.registry_id
}

output "repository_url" {
  description = "The URL of the repository (in the form `aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName`)."
  value       = module.ecr_repository.repository_url
}

output "repository_arn" {
  description = "Full ARN of the repository."
  value       = module.ecr_repository.repository_arn
}
