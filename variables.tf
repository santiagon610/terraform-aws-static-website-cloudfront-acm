variable "aws_region" {
  type        = string
  description = "AWS region for region-specific resources"
  default     = "us-east-1"
}

variable "staticsite_name" {
  type        = string
  description = "Descriptive name for static site"
  default     = "My Static Site"
}
variable "oai_comment" {
  type        = string
  description = "Descriptive string for Origin Access Identity"
  default     = "undefined"
}

variable "domain_list" {
  type        = list(string)
  description = "List of domains for Cloudfront distribution and ACM certificate"
  default = [
    "example.com",
    "www.example.com",
    "mysite.example.com"
  ]
}

variable "s3_bucket_name" {
  type        = string
  description = "Name for S3 bucket into which static website will be placed"
  default     = "s3-bucket-my-static-site"
}

variable "tags" {
  type        = map(string)
  description = "Optional tags"
  default = {
    pizza = "Pepperoni"
  }
}

variable "index_document" {
  type        = string
  description = "Default index document for static website"
  default     = "index.html"
}

variable "error_document" {
  type        = string
  description = "Default error document for static website"
  default     = "error.html"
}

variable "dns_zone_id" {
  type        = string
  description = "AWS Route 53 zone ID for DNS zone into which records will be placed"
  default     = ""
}

variable "dns_ttl" {
  type        = number
  description = "Time to live for DNS records"
  default     = 60
}

variable "deployer_iam_user" {
  type        = bool
  description = "Create an IAM user with ability to deploy to the newly created S3 bucket"
  default     = false
}

variable "deployer_iam_user_name" {
  type        = string
  description = "Create an IAM user with ability to deploy to the newly created S3 bucket"
  default     = "my-static-site-deployer"
}

variable "cloudfront_index_handler" {
  type        = bool
  description = "Create Lambda@Edge function to handle index files for subdirectories"
  default     = true
}

variable "allowed_countries" {
  type        = list(string)
  description = "Allowed countries to access Cloudfront hosted resources"
  default     = ["US", "CA", "GB", "MX", "IN", "DE", "NL", "FR", "BR", "JP", "SG", "TW", "KR", "CO", "ES", "AU", "CH", "IT", "PH", "HK", "SE", "CR"]
}

variable "skip_acl" {
  type        = bool
  description = "Skips creation of the ACL for accounts in which this is disallowed"
  default     = false
}

variable "ip_allow_list" {
  type        = list(string)
  description = "List of IP addresses allowed to access Cloudfront hosted resources. If an empty list, all IPs within the allowed countries are allowed to access the static site."
  default     = []
}
