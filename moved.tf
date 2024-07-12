moved {
  from = aws_cloudfront_origin_access_identity.staticsite-oai
  to   = aws_cloudfront_origin_access_identity.this
}

moved {
  from = aws_acm_certificate.staticsite-acm-cert
  to   = aws_acm_certificate.this
}
