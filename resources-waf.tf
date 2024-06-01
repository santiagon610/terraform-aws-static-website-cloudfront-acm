resource "aws_wafv2_ip_set" "this" {
  count              = length(var.ip_allow_list) < 1 ? 1 : 0
  name               = "iplist_${local.primary_domain}"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.ip_allow_list
  tags               = var.tags
}

resource "aws_wafv2_web_acl" "this" {
  count       = length(var.ip_allow_list) < 1 ? 1 : 0
  name        = "webacl-${local.primary_domain}"
  description = "Web ACL for ${var.staticsite_name}"
  scope       = "CLOUDFRONT"

  default_action {
    block {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "waf_${local.primary_domain}"
    sampled_requests_enabled   = true
  }
  tags = var.tags
}
