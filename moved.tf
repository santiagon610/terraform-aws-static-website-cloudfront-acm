moved {
  from = aws_cloudfront_origin_access_identity.staticsite-oai
  to   = aws_cloudfront_origin_access_identity.this
}

moved {
  from = aws_acm_certificate.staticsite-acm-cert
  to   = aws_acm_certificate.this
}

moved {
  from = aws_route53_record.staticsite-acm-cert-validate
  to   = aws_route53_record.cert_validation
}

moved {
  from = aws_acm_certificate_validation.staticsite-acm
  to   = aws_acm_certificate_validation.this
}

moved {
  from = aws_cloudfront_distribution.staticsite-cf
  to   = aws_cloudfront_distribution.this
}

moved {
  from = aws_s3_bucket.staticsite-s3
  to   = aws_s3_bucket.this
}

moved {
  from = aws_s3_bucket_policy.staticsite-s3
  to   = aws_s3_bucket_policy.this
}

moved {
  from = aws_s3_bucket_cors_configuration.staticsite-s3
  to   = aws_s3_bucket_cors_configuration.this
}

moved {
  from = aws_s3_bucket_acl.staticsite-s3
  to   = aws_s3_bucket_acl.this
}

moved {
  from = aws_s3_bucket_website_configuration.staticsite-s3
  to   = aws_s3_bucket_website_configuration.this
}

moved {
  from = aws_cloudfront_function.staticsite-indexhandler
  to   = aws_cloudfront_function.index_handler
}

moved {
  from = aws_route53_record.staticsite-route53-a
  to   = aws_route53_record.cloudfront_a
}

moved {
  from = aws_iam_user.staticsite-iam-deployer
  to   = aws_iam_user.deployer
}
