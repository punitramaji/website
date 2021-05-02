resource "aws_s3_bucket" "website" {
  bucket        = var.bucket_name
  acl           = "private"
  force_destroy = true
  tags          = local.tags
  
  server_side_encryption_configuration {
    rule {
      apply_servier_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3block" {
  bucket                  = aws_s3_bucket.website.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_distribution" "cf" {
  enable  = true
  aliases = [var.endpiont]
  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.website.bucket_regional_domain_name
    
    s3_origin_config {
      origin_access_identity = "???"
    }
  }
  
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = ??
    viewer_protocol_policy = "redirect-to-https"
    
    forwarded_values {
      headers      = []
      query_string = true

      cookies {
        forward = "all"
      }
    }
  }
  
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  tags = local.tags
}
