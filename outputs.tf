
output "repository_name" {
  description = "The name of the repository."
  value       = aws_ecr_repository.ecr_repository.name
}

output "registry_id" {
  description = "The registry ID where the repository was created."
  value       = aws_ecr_repository.ecr_repository.registry_id
}

output "repository_url" {
  description = "The URL of the repository (in the form `aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName`)."
  value       = aws_ecr_repository.ecr_repository.repository_url

}

output "repository_arn" {
  description = "Full ARN of the repository."
  value       = aws_ecr_repository.ecr_repository.arn
}
