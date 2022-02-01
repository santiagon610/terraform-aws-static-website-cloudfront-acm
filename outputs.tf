output "domains" {
  value = {
    domain_list      = local.domain_list
    domain_list_full = local.domain_list_full
    primary_domain   = local.primary_domain
    san_list         = local.san_list
    s3_origin_id     = local.s3_origin_id
  }
}

output "deployer_creds" {
  value = {
    access_key = (
      var.deployer_iam_user ? aws_iam_access_key.staticsite-iam-deployer[0].id : "undefined"
    )
    secret_key = (
      var.deployer_iam_user ? aws_iam_access_key.staticsite-iam-deployer[0].secret : "undefined"
    )
    default_region = var.aws_region
  }
  sensitive = true
}
