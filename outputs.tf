output "deployer_creds" {
  description = "Credentials for the deployer user. Useful as an output for programmatic processes to grab via the Terraform state JSON."
  value = {
    access_key = (
      var.deployer_iam_user ? aws_iam_access_key.deployer[0].id : "undefined"
    )
    secret_key = (
      var.deployer_iam_user ? aws_iam_access_key.deployer[0].secret : "undefined"
    )
    default_region = var.aws_region
  }
  sensitive = true
}

output "distribution_id" {
  description = "Cloudfront distribution ID"
  value       = aws_cloudfront_distribution.this.id
  sensitive   = false
}
