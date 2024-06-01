locals {
  sanitized_primary_domain = replace(local.primary_domain, ".", "-")
}

resource "aws_wafv2_ip_set" "this" {
  count              = length(var.ip_allow_list) >= 1 ? 1 : 0
  name               = "iplist-${local.sanitized_primary_domain}"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.ip_allow_list
  tags               = var.tags
}

# resource "aws_wafv2_web_acl" "this" {
#   count       = length(var.ip_allow_list) >= 1 ? 1 : 0
#   name        = "webacl-${local.sanitized_primary_domain}"
#   description = "Web ACL for ${var.staticsite_name}"
#   scope       = "CLOUDFRONT"

#   default_action {
#     block {}
#   }

#   visibility_config {
#     cloudwatch_metrics_enabled = true
#     metric_name                = "waf-${local.sanitized_primary_domain}"
#     sampled_requests_enabled   = true
#   }
#   tags = var.tags
# }

resource "aws_wafv2_web_acl" "this" {
  count       = length(var.ip_allow_list) >= 1 ? 1 : 0
  name        = "rulegroup-${local.sanitized_primary_domain}"
  description = "Rule Group for ${var.staticsite_name}"
  scope       = "CLOUDFRONT"

  rule {
    name     = "Honor IP Allow List"
    priority = 1
    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.this.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-rulegroup-ipallow-${local.sanitized_primary_domain}"
      sampled_requests_enabled   = true
    }
  }

  default_action {
    block {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "waf-${local.sanitized_primary_domain}"
    sampled_requests_enabled   = true
  }
  tags = var.tags
}
