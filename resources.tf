locals {
  domain_list      = var.domain_list
  primary_domain   = var.domain_list[0]
  sanitized_primary_domain = replace(local.primary_domain, ".", "-")
  domain_list_full = distinct(concat(tolist([local.primary_domain]), local.domain_list))
  san_list         = slice(local.domain_list_full, 1, length(local.domain_list_full))
  s3_origin_id     = "${local.primary_domain}-s3_origin"
}

resource "aws_cloudfront_origin_access_identity" "staticsite-oai" {
  comment = var.oai_comment
}

resource "aws_acm_certificate" "staticsite-acm-cert" {
  domain_name               = local.primary_domain
  validation_method         = "DNS"
  subject_alternative_names = local.san_list
  tags                      = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "staticsite-acm-cert-validate" {
  for_each = {
    for dvo in aws_acm_certificate.staticsite-acm-cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.dns_zone_id
}

resource "aws_acm_certificate_validation" "staticsite-acm" {
  certificate_arn = aws_acm_certificate.staticsite-acm-cert.arn
  validation_record_fqdns = [
    for record in aws_route53_record.staticsite-acm-cert-validate : record.fqdn
  ]
}

resource "aws_cloudfront_distribution" "staticsite-cf" {
  origin {
    domain_name = aws_s3_bucket.staticsite-s3.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.staticsite-oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.staticsite_name
  default_root_object = var.index_document
  aliases             = local.domain_list
  price_class         = "PriceClass_100"
  tags                = var.tags
  web_acl_id = length(var.ip_allow_list) >= 1 ? aws_wafv2_web_acl.this[0].arn : null
  depends_on = [
    aws_acm_certificate_validation.staticsite-acm
  ]

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 7200
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    dynamic "function_association" {
      for_each = var.cloudfront_index_handler == true ? [1] : []
      content {
        event_type   = "viewer-request"
        function_arn = aws_cloudfront_function.staticsite-indexhandler.arn
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.staticsite-acm-cert.arn
    ssl_support_method             = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = var.allowed_countries
    }
  }

}

resource "aws_s3_bucket" "staticsite-s3" {
  bucket = var.s3_bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_policy" "staticsite-s3" {
  bucket = var.s3_bucket_name
  policy = jsonencode(
    {
      Id      = "PolicyForCloudFrontPrivateContent"
      Version = "2008-10-17"
      Statement = [
        {
          Action = [
            "s3:GetObject",
            "s3:ListBucket"
          ]
          Effect = "Allow"
          Sid    = "1"
          Resource = [
            "arn:aws:s3:::${var.s3_bucket_name}/*",
            "arn:aws:s3:::${var.s3_bucket_name}"
          ]
          Principal = {
            AWS = aws_cloudfront_origin_access_identity.staticsite-oai.iam_arn
          }
        }
      ]
    }
  )
}

resource "aws_s3_bucket_cors_configuration" "staticsite-s3" {
  bucket = var.s3_bucket_name

  cors_rule {
    allowed_headers = [
      "*",
    ]
    allowed_methods = [
      "GET", "HEAD"
    ]
    allowed_origins = [
      "*"
    ]
    expose_headers  = []
    max_age_seconds = 0
  }
}

resource "aws_s3_bucket_acl" "staticsite-s3" {
  count = var.skip_acl ? 0 : 1
  bucket = var.s3_bucket_name
  acl    = "private"
}

resource "aws_s3_bucket_website_configuration" "staticsite-s3" {
  bucket = var.s3_bucket_name

  index_document {
    suffix = "var.index_document"
  }

  error_document {
    key = var.error_document
  }
}

resource "aws_cloudfront_function" "staticsite-indexhandler" {
  name    = "${var.oai_comment}_index_handler"
  runtime = "cloudfront-js-1.0"
  publish = true
  code    = file("${path.module}/cloudfront_index_handler.js")
}

resource "aws_route53_record" "staticsite-route53-a" {
  for_each        = toset(local.domain_list)
  allow_overwrite = true
  name            = each.key
  zone_id         = var.dns_zone_id
  type            = "A"
  alias {
    name                   = aws_cloudfront_distribution.staticsite-cf.domain_name
    zone_id                = aws_cloudfront_distribution.staticsite-cf.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_iam_user" "staticsite-iam-deployer" {
  count = var.deployer_iam_user ? 1 : 0
  name  = var.deployer_iam_user_name
  tags  = var.tags
}

resource "aws_iam_access_key" "staticsite-iam-deployer" {
  count = var.deployer_iam_user ? 1 : 0
  user  = aws_iam_user.staticsite-iam-deployer[0].name
}

resource "aws_iam_user_policy" "staticsite-iam-deployer" {
  count = var.deployer_iam_user ? 1 : 0
  name  = "${aws_iam_user.staticsite-iam-deployer[0].name}_user_policy"
  user  = aws_iam_user.staticsite-iam-deployer[0].name
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action   = [
            "s3:ListBucket",
            "cloudfront:CreateInvalidation"
          ]
          Effect   = "Allow"
          Resource = [
            aws_s3_bucket.staticsite-s3.arn,
            aws_cloudfront_distribution.staticsite-cf.arn
          ]
        },
        {
          Action = [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject",
            "s3:ListObject*"
          ]
          Effect   = "Allow"
          Resource = "${aws_s3_bucket.staticsite-s3.arn}/*"
        },
        {
          Action = "cloudfront:ListDistributions"
          Effect = "Allow"
          Resource = "*"
        }
      ]
    }
  )
}

resource "aws_wafv2_ip_set" "this" {
  count              = length(var.ip_allow_list) >= 1 ? 1 : 0
  name               = "iplist-${local.sanitized_primary_domain}"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.ip_allow_list
  tags               = var.tags
}

resource "aws_wafv2_web_acl" "this" {
  count       = length(var.ip_allow_list) >= 1 ? 1 : 0
  name        = "rulegroup-${local.sanitized_primary_domain}"
  description = "Rule Group for ${var.staticsite_name}"
  scope       = "CLOUDFRONT"

  rule {
    name     = "allowed-ips-${local.sanitized_primary_domain}"
    priority = 1
    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.this[0].arn
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
