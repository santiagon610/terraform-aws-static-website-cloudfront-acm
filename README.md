# AWS Static Website w/ CloudFront Distribution, ACM Cert, and IAM User

Want to host a static website on AWS simply and (theoretically) cheaply? Let S3, CloudFront, ACM, and Route 53 do the magic for you with this module.

## Features

- S3 bucket
  - IAM user with permissions to S3 Bucket
- CloudFront distribution
- ACM TLS certificates
- Route 53 records
- Automatic certificate verification via Route 53
- Lambda@Edge to handle `index.html` in subdirectories
- WAFv2 IP Allow List

## Terraform versions

I've tested this on 0.13 onward, and seems to be fine. If you find an issue, feel free to raise an issue.

### Example Usage

```hcl
# Production Website
module "prod_website" {
  source          = "santiagon610/static-website-cloudfront-acm/aws"
  version         = "~> 0.1"
  staticsite_name = "Production Website"
  aws_region      = "us-west-2"
  oai_comment     = "prod-website-oai"
  domain_list = [
    "www.example.com",
    "prod.example.com",
    "example.com"
  ]
  s3_bucket_name = "mycompany-website-prod"
  tags = {
    pizza     = "pepperoni"
    doughnuts = "magic"
  }
  index_document           = "index.html"
  error_document           = "404.html"
  dns_zone_id              = aws_route53_zone.example_com.id
  deployer_iam_user        = true
  deployer_iam_user_name   = "prod-website-deployer"
  cloudfront_index_handler = true
  ip_allow_list = [
    "1.2.3.4/32",
    "2.3.4.0/24"
  ]
}
```

## Providers

- [AWS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## Outputs

- `deployer_creds`: When this and `deployer_iam_user` are set to `true`, Outputs the `access_key` and `secret_key` of the created IAM user.
  - Note: If `deployer_iam_user` is set to false, this will render as `undefined`

## Authors

- [Nicholas Santiago](https://github.com/santiagon610)

## License

[CC0 1.0 Universal](LICENSE)