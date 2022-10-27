# Create repository
resource "aws_ecr_repository" "ecr_repository" {
  name                 = var.repository_name
  image_tag_mutability = var.repository_image_tag_mutability
  encryption_configuration {
    encryption_type = var.repository_encryption_type
    kms_key         = var.repository_kms_key
  }

  force_delete = var.repository_force_delete
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
  # Tags
  tags = var.tags
}

# Repository policy
resource "aws_ecr_repository_policy" "repository_policy" {
  repository = aws_ecr_repository.ecr_repository.name
  policy     = var.repository_policy == null ? data.aws_iam_policy_document.repository.json : var.repository_policy
}

# Lifecycle policy
resource "aws_ecr_lifecycle_policy" "lifecycle_policy" {
  count      = var.lifecycle_policy == null ? 0 : 1
  repository = aws_ecr_repository.ecr_repository.name
  policy     = var.lifecycle_policy
}

# Policy used by  private repository
data "aws_iam_policy_document" "repository" {
  statement {

    sid = "PrivateReadOnly"
    principals {
      type = "AWS"
      identifiers = coalescelist(
        concat(var.repository_read_access_arns, var.repository_read_write_access_arns),
        ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"],
      )
    }
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImageScanFindings",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:ListTagsForResource",
    ]
  }
  statement {

    sid = "ReadWrite"
    principals {
      type = "AWS"
      identifiers = coalescelist(
        concat(var.repository_read_access_arns, var.repository_read_write_access_arns),
        ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"],
      )
    }

    actions = [
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
    ]
  }
}

# Registry policy
resource "aws_ecr_registry_policy" "registry_policy" {
  policy = var.registry_policy == null ? data.aws_iam_policy_document.registry.json : var.registry_policy
}
