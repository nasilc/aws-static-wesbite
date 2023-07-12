terraform {
  required_version = ">=1.5.2"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>5.7.0"
    }
  }
}

# provider initiating
#-----------------------------------------
provider "aws" {
  region = "ap-southeast-2"
  access_key = var.accessKey
  secret_key = var.secretKey
}

# s3 Bucket
#-----------------------------------------
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucketName
}

# static website conf
#-----------------------------------------
resource "aws_s3_bucket_website_configuration" "s3-conf" {
  bucket = aws_s3_bucket.bucket.bucket
  index_document {
    suffix = "index.html"
  }
}

# public Bucket
#-----------------------------------------
resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# ownership
#-----------------------------------------
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.public]
}

# acl
#-----------------------------------------
resource "aws_s3_bucket_acl" "acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "public-read"
  depends_on = [aws_s3_bucket_ownership_controls.ownership]
}

# index.html object
#-----------------------------------------
resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.bucket.id
  key    = "index.html"
  source = "${path.module}/index.html"
  acl    = "public-read"
  content_type = "text/html"
  depends_on = [aws_s3_bucket_acl.acl]
}