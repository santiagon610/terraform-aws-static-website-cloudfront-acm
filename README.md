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

I've tested this on OpenTofu 1.9.0, and seems to be fine. If you find an problem, feel free to [raise an issue](https://github.com/santiagon610/terraform-aws-static-website-cloudfront-acm/issues/).

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

## Requirements

| Name                                                                     | Version |
| ------------------------------------------------------------------------ | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.0  |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | >= 4.0  |

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | >= 4.0  |

## Modules

No modules.

## Resources

| Name                                                                                                                                                        | Type     |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_acm_certificate.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate)                                     | resource |
| [aws_acm_certificate_validation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation)               | resource |
| [aws_cloudfront_distribution.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution)                     | resource |
| [aws_cloudfront_function.index_handler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_function)                    | resource |
| [aws_cloudfront_origin_access_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_iam_access_key.deployer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key)                                   | resource |
| [aws_iam_user.deployer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user)                                               | resource |
| [aws_iam_user_policy.deployer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy)                                 | resource |
| [aws_route53_record.cert_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)                            | resource |
| [aws_route53_record.cloudfront_a](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)                               | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                                                 | resource |
| [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl)                                         | resource |
| [aws_s3_bucket_cors_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration)           | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy)                                   | resource |
| [aws_s3_bucket_website_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration)     | resource |
| [aws_wafv2_ip_set.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_ip_set)                                           | resource |
| [aws_wafv2_web_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl)                                         | resource |

## Inputs

| Name                                                                                                      | Description                                                                                                                                                       | Type           | Default                                                                                                                                                                                                                                                             | Required |
| --------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------: |
| <a name="input_allowed_countries"></a> [allowed_countries](#input_allowed_countries)                      | Allowed countries to access Cloudfront hosted resources                                                                                                           | `list(string)` | <pre>[<br/> "US",<br/> "CA",<br/> "GB",<br/> "MX",<br/> "IN",<br/> "DE",<br/> "NL",<br/> "FR",<br/> "BR",<br/> "JP",<br/> "SG",<br/> "TW",<br/> "KR",<br/> "CO",<br/> "ES",<br/> "AU",<br/> "CH",<br/> "IT",<br/> "PH",<br/> "HK",<br/> "SE",<br/> "CR"<br/>]</pre> |    no    |
| <a name="input_aws_region"></a> [aws_region](#input_aws_region)                                           | AWS region for region-specific resources                                                                                                                          | `string`       | `"us-east-1"`                                                                                                                                                                                                                                                       |    no    |
| <a name="input_cloudfront_index_handler"></a> [cloudfront_index_handler](#input_cloudfront_index_handler) | Create Lambda@Edge function to handle index files for subdirectories                                                                                              | `bool`         | `true`                                                                                                                                                                                                                                                              |    no    |
| <a name="input_deployer_iam_user"></a> [deployer_iam_user](#input_deployer_iam_user)                      | Create an IAM user with ability to deploy to the newly created S3 bucket                                                                                          | `bool`         | `false`                                                                                                                                                                                                                                                             |    no    |
| <a name="input_deployer_iam_user_name"></a> [deployer_iam_user_name](#input_deployer_iam_user_name)       | Create an IAM user with ability to deploy to the newly created S3 bucket                                                                                          | `string`       | `"my-static-site-deployer"`                                                                                                                                                                                                                                         |    no    |
| <a name="input_dns_ttl"></a> [dns_ttl](#input_dns_ttl)                                                    | Time to live for DNS records                                                                                                                                      | `number`       | `60`                                                                                                                                                                                                                                                                |    no    |
| <a name="input_dns_zone_id"></a> [dns_zone_id](#input_dns_zone_id)                                        | AWS Route 53 zone ID for DNS zone into which records will be placed                                                                                               | `string`       | `""`                                                                                                                                                                                                                                                                |    no    |
| <a name="input_domain_list"></a> [domain_list](#input_domain_list)                                        | List of domains for Cloudfront distribution and ACM certificate                                                                                                   | `list(string)` | <pre>[<br/> "example.com",<br/> "www.example.com",<br/> "mysite.example.com"<br/>]</pre>                                                                                                                                                                            |    no    |
| <a name="input_error_document"></a> [error_document](#input_error_document)                               | Default error document for static website                                                                                                                         | `string`       | `"error.html"`                                                                                                                                                                                                                                                      |    no    |
| <a name="input_index_document"></a> [index_document](#input_index_document)                               | Default index document for static website                                                                                                                         | `string`       | `"index.html"`                                                                                                                                                                                                                                                      |    no    |
| <a name="input_ip_allow_list"></a> [ip_allow_list](#input_ip_allow_list)                                  | List of IP addresses allowed to access Cloudfront hosted resources. If an empty list, all IPs within the allowed countries are allowed to access the static site. | `list(string)` | `[]`                                                                                                                                                                                                                                                                |    no    |
| <a name="input_oai_comment"></a> [oai_comment](#input_oai_comment)                                        | Descriptive string for Origin Access Identity                                                                                                                     | `string`       | `"undefined"`                                                                                                                                                                                                                                                       |    no    |
| <a name="input_s3_bucket_name"></a> [s3_bucket_name](#input_s3_bucket_name)                               | Name for S3 bucket into which static website will be placed                                                                                                       | `string`       | `"s3-bucket-my-static-site"`                                                                                                                                                                                                                                        |    no    |
| <a name="input_skip_acl"></a> [skip_acl](#input_skip_acl)                                                 | Skips creation of the ACL for accounts in which this is disallowed                                                                                                | `bool`         | `false`                                                                                                                                                                                                                                                             |    no    |
| <a name="input_staticsite_name"></a> [staticsite_name](#input_staticsite_name)                            | Descriptive name for static site                                                                                                                                  | `string`       | `"My Static Site"`                                                                                                                                                                                                                                                  |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                                                             | Optional tags                                                                                                                                                     | `map(string)`  | <pre>{<br/> "pizza": "Pepperoni"<br/>}</pre>                                                                                                                                                                                                                        |    no    |

## Outputs

| Name                                                                             | Description                                                                                                             |
| -------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| <a name="output_deployer_creds"></a> [deployer_creds](#output_deployer_creds)    | Credentials for the deployer user. Useful as an output for programmatic processes to grab via the Terraform state JSON. |
| <a name="output_distribution_id"></a> [distribution_id](#output_distribution_id) | Cloudfront distribution ID                                                                                              |

## Authors

- [Nicholas Santiago](https://github.com/santiagon610)

## License

[Unlicense](LICENSE)
