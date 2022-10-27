# trm-infra-ecr

Terraform module to create [AWS ECR](https://aws.amazon.com/ecr/) (Elastic Container Registry) which is a fully-managed Docker container registry.

# Table of contents

  - [Usage](#usage)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
  - [Push commands for ECR repository](#Push_commands_for_ECR_repository)
   
## Usage
You can use this module to create an ECR registry using few parameters (simple example) or define in detail every aspect of the registry (complete example).

Check the [examples](examples/).

### Complete example
In this example the register is defined in detailed.

```
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
  component           = ""
  environment         = "Personal"
  data_classification = "Internal"
  created_using       = "Terraform"
  source_code         = ""
}

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

# Tags

tags {
    Name = "dev_repository"
}
   
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| **repository_name** | Name of the repository. | `string` |  | yes |
| **repository_image_tag_mutability** | The tag mutability setting for the repository. Must be one of: `MUTABLE` or `IMMUTABLE`. | `string` | `"IMMUTABLE"` | no |
|**scan_on_push** | Indicates whether images are scanned after being pushed to the repository (`true`) or not scanned (`false`). | `bool` |`true` | no |
| **repository_encryption_type** | The encryption type for the repository. Must be one of: `KMS` or `AES256`. Defaults to `AES256`.| `string` | `AES256` | no |
| **"repository_kms_key** | The ARN of the KMS key to use when encryption_type is `KMS`. If not specified, uses the default AWS managed key for ECR. | `string` | `null` | no |
| **repository_force_delete** | If `true`, will delete the repository even if it contains images. | `string` | `false` | yes |
| **repository_policy** | Manages the ECR repository policy. | `string` | `null` | no |
| **repository_read_access_arns**| The ARNs of the IAM users/roles that have read access to the repository. | `list(string)` | `[]` | no |
|**epository_read_write_access_arns** | The ARNs of the IAM users/roles that have read/write access to the repository.| `list(string)` | `[]` | no |
| **lifecycle_policy** | Manages the ECR repository lifecycle policy. | `string` | `null` | no |
| **registry_policy** | The policy document. This is a JSON formatted string. | `string` | `null` | no |
| **tags** | Map with ECR tags. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| **repository_name** | The name of the repository. |
| **registry_id** | The registry ID where the repository was created. |
| **repository_url** | The URL of the repository (in the form `aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName`). |
| **repository_arn** | Full ARN of the repository. |

## Push commands for ECR repository 

1. Use the following steps to authenticate and push an image to your repository. For additional registry authentication methods, including the Amazon ECR credential helper, see Registry Authentication .
Retrieve an authentication token and authenticate your Docker client to your registry.
Use the AWS CLI:

```bash
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com
```

2. After the build completes, tag your image so you can push the image to this repository:

```bash
   docker tag <image_id> <aws_account_id>.dkr.ecr.<region>.amazonaws.com/my-repository:tag
```

3. Run the following command to push this image to your newly created AWS repository:

```bash
   docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/my-repository:tag
```
