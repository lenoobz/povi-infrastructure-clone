/**********************************************************
 * Define local variables
 **********************************************************/

locals {
  prefix              = var.prefix != "" ? "${var.prefix}." : "www."
  website_domain_name = "${local.prefix}${var.domain_name}"
  website_bucket_name = "${local.prefix}${var.domain_name}"
  origin_id           = "origin-${local.website_domain_name}"
}

/*locals {
  domain_validation_option = element(tolist(aws_acm_certificate.cert.domain_validation_options), 0)
}*/

data "aws_route53_zone" "zone" {
  name = var.domain_name
}

/**********************************************************
 * S3 storage for website
 **********************************************************/

data "aws_iam_policy_document" "policy" {
  statement {
    actions = [
      "s3:GetObject"
    ]
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    resources = [
      "arn:aws:s3:::${local.website_bucket_name}/*"
    ]
  }
}

resource "aws_s3_bucket" "povi_ui_bucket" {
  bucket = local.website_bucket_name
  acl    = "public-read"
  policy = data.aws_iam_policy_document.policy.json

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_public_access_block" "access_control" {
  bucket             = aws_s3_bucket.povi_ui_bucket.id
  block_public_acls  = true
  ignore_public_acls = true
}

/**********************************************************
 * Route53
 **********************************************************/

resource "aws_route53_record" "a_record" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = local.website_domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }

  depends_on = [
    aws_cloudfront_distribution.main
  ]
}

/*resource "aws_route53_record" "cert_validation" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = local.domain_validation_option.resource_record_name
  type    = local.domain_validation_option.resource_record_type
  records = [local.domain_validation_option.resource_record_value]
  ttl     = 60
}*/

/**********************************************************
 * SSL certificate
 **********************************************************/

/*resource "aws_acm_certificate" "cert" {
  domain_name       = local.website_domain_name
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}*/

/**********************************************************
 * Cloudfront distribution for website
 **********************************************************/

resource "aws_cloudfront_distribution" "main" {
  http_version = "http2"

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = [local.website_domain_name]

  default_cache_behavior {
    target_origin_id = local.origin_id
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    compress         = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 300
    max_ttl                = 1200
  }

  origin {
    origin_id   = local.origin_id
    domain_name = aws_s3_bucket.povi_ui_bucket.website_endpoint

    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port              = "80"
      https_port             = "443"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "N/A" # aws_acm_certificate_validation.cert_validation.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
}
